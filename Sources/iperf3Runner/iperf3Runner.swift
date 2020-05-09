import ciperf3
import Foundation

public struct Iperf3RunnerConfiguration {
  public enum TestType {
    case download, upload, server
  }

  public var hostname: String
  public var port: Int
  public var duration: Int
  public var streams: Int
  public var type: TestType

  public init(
    hostname: String,
    port: Int,
    duration: Int,
    streams: Int,
    type: TestType
  ) {
    self.hostname = hostname
    self.port = port
    self.duration = duration
    self.streams = streams
    self.type = type
  }
}

public enum Iperf3RunnerErrorState: Int {
  case noError = 0
  case couldntInitializeTest = 1
  case serverIsBusy = 2
  case cannotConnectToTheServer = 3
  case unknown = 4
}

public struct Iperf3RunnerStatus {
  public var running: Bool
  public var progress: Double
  public var bandwidth: Double
  public var errorState: Iperf3RunnerErrorState
}

extension String {
  var pointer: UnsafeMutablePointer<Int8>? {
    UnsafeMutablePointer<Int8>(mutating: (self as NSString).utf8String)
  }
}

private var runner: Iperf3Runner?

public class Iperf3Runner {
  var iPerfTest: UnsafeMutablePointer<iperf_test>?
  let configuration: Iperf3RunnerConfiguration
  var callback: ((Iperf3RunnerStatus) -> Void)?

  public init(configuration: Iperf3RunnerConfiguration) {
    self.configuration = configuration
  }

  public func start(callback: @escaping (Iperf3RunnerStatus) -> Void) {
    self.callback = callback

    iPerfTest = nil
    runner = nil

    iPerfTest = iperf_new_test()
    let streamFilePathTemplate = "\(NSTemporaryDirectory())/iperf3.XXXXXX"

    if iperf_defaults(iPerfTest) < 0 {
      return
    }

    guard let test = iPerfTest else { return }

    if configuration.type == .server {
      iperf_set_test_role(test, "s".utf8CString.first!)
    } else {
      iperf_set_test_role(test, "c".utf8CString.first!)
      iperf_set_test_num_streams(test, Int32(configuration.streams))

      if (configuration.type == .download) {
        iperf_set_test_reverse(test, 1)
      }
    }

    iperf_set_test_server_hostname(test, configuration.hostname.pointer)
    iperf_set_test_server_port(test, Int32(configuration.port))
    iperf_set_test_duration(test, Int32(configuration.duration))

    iperf_set_test_template(test, streamFilePathTemplate.pointer)
    test.pointee.settings.pointee.connect_timeout = 3000

    runner = self

    test.pointee.reporter_callback = { testPointer in
      if
        let test = testPointer?.pointee,
        let status = handleStatusCallback(test: test) {
        // static variable
        runner?.callback?(status)
      }
    }

    DispatchQueue(label: "iPerfTestQueue", qos: .userInitiated).async {
      if self.configuration.type == .server {
        iperf_run_server(test)
      } else {
        iperf_run_client(test)
      }
    }
  }

  public func stop() {
    if let t = iPerfTest {
      t.pointee.done = 1
    }
  }

  public func free() {
    if let t = iPerfTest {
      iperf_free_test(t)
    }
  }
}

private func getLastResult(stream: iperf_stream) -> iperf_interval_results? {
  var currentResult: iperf_interval_results? = stream.result.pointee.interval_results.tqh_first.pointee
  var lastResult: iperf_interval_results?

  while currentResult != nil {
    lastResult = currentResult
    currentResult = currentResult?.irlistentries.tqe_next?.pointee
  }

  return lastResult
}

private func getBytes(stream: iperf_stream?) -> Double {
  if
    let stream = stream,
    let result = getLastResult(stream: stream) {
    return Double(result.bytes_transferred)
  }
  return 0
}

private func allStreams(stream: iperf_stream?) -> [iperf_stream] {
  var streams: [iperf_stream] = []

  var currentStream = stream

  while currentStream != nil {
    streams.append(currentStream!)
    currentStream = currentStream?.streams.sle_next?.pointee
  }

  return streams
}

private func sumStreamBytes(stream: iperf_stream?) -> Double {
  let bytes = allStreams(stream: stream).reduce(into: 0) { (result, currentStream) in
    result += getBytes(stream: currentStream)
  }

  return Double(bytes)
}

private func handleStatusCallback(test: iperf_test) -> Iperf3RunnerStatus? {
  var stream: iperf_stream? = test.streams.slh_first.pointee

  let bytes = sumStreamBytes(stream: stream)

  stream = test.streams.slh_first.pointee
  if
    let stream = stream,
    let interval_results = getLastResult(stream: stream) {

    let bandwith = (bytes / Double(interval_results.interval_duration)) * 8 / 1_000_000

    var progress = 1.0
    if let timer = test.timer {
      let duration = UInt32(timer.pointee.usecs / 1_000_000)
      let elapsed = duration - (timer.pointee.time.secs - test.stats_timer.pointee.time.secs)

      progress = Double(elapsed) / Double(duration)
    }

    return Iperf3RunnerStatus(
      running: true,
      progress: progress,
      bandwidth: bandwith,
      errorState: .noError)
  }
  return nil
}
