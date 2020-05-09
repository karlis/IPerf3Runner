//
//  IPerf3Runner.swift
//
//
//  Created by Karlis Lukstins on 10/05/2020.
//

import ciperf3
import Foundation

// Static variable used for reporter_callback.
private var runner: IPerf3Runner?

public class IPerf3Runner {
  var test: UnsafeMutablePointer<iperf_test>
  let configuration: Configuration
  var callback: ((Status) -> Void)?

  var streamFilePathTemplate: String {
    "\(NSTemporaryDirectory())/iperf3.XXXXXX"
  }

  public init?(configuration: Configuration) {
    self.configuration = configuration
    test = iperf_new_test()
    if iperf_defaults(test) < 0 {
      return nil
    }
    configure()
  }

  private func configure() {
    // Client only
    iperf_set_test_role(test, "c".utf8CString.first!)
    iperf_set_test_num_streams(test, Int32(configuration.streams))
    if configuration.type == .download {
      iperf_set_test_reverse(test, 1)
    }
    iperf_set_test_server_hostname(test, configuration.hostname.pointer)
    iperf_set_test_server_port(test, Int32(configuration.port))
    iperf_set_test_duration(test, Int32(configuration.duration))
    iperf_set_test_template(test, streamFilePathTemplate.pointer)
    test.pointee.settings.pointee.connect_timeout = 3000
  }

  public func start(callback: @escaping (Status) -> Void) {
    self.callback = callback
    runner = self

    test.pointee.reporter_callback = { testPointer in
      if let test = testPointer?.pointee {
        DispatchQueue.main.async {
          runner?.handleStatusCallback(test: test)
        }
      }
    }
    DispatchQueue.global(qos: .userInitiated).async {
      if iperf_run_client(self.test) < 0 {
        callback(.error(.cannotConnectToTheServer))
      }
    }
  }

  public func stop() {
    test.pointee.done = 1
  }
}

private extension IPerf3Runner {
  func getLastResult(stream: iperf_stream?) -> iperf_interval_results? {
    var current: iperf_interval_results? = stream?.result.pointee.interval_results.tqh_first.pointee
    var lastResult: iperf_interval_results?
    while current != nil {
      lastResult = current
      current = current?.irlistentries.tqe_next?.pointee
    }
    return lastResult
  }
  
  func getBytes(stream: iperf_stream?) -> Double {
    return Double(getLastResult(stream: stream)?.bytes_transferred ?? 0)
  }

  func allStreams(stream: iperf_stream?) -> [iperf_stream] {
    var streams: [iperf_stream] = []
    var currentStream = stream

    while currentStream != nil {
      streams.append(currentStream!)
      currentStream = currentStream?.streams.sle_next?.pointee
    }

    return streams
  }

  func handleCompletion(test: iperf_test) {
    let result = test.streams.slh_first.pointee.result.pointee

    let totalDuration = Double(result.end_time.secs - result.start_time.secs)
    let bandwidth = Double(result.bytes_sent) / totalDuration * 8 / 1_000_000

    callback?(.completed(bandwidth))
  }

  func handleStatusCallback(test: iperf_test) {
    guard test.done != 1 else { return handleCompletion(test: test) }
    let stream = test.streams.slh_first.pointee

    let bytes = allStreams(stream: stream)
      .reduce(into: 0) { (bytes, current) in bytes += getBytes(stream: current) }

    if let interval_results = getLastResult(stream: stream) {
      let bandwith = (bytes / Double(interval_results.interval_duration)) * 8 / 1_000_000
      callback?(.next(bandwith))
    }
  }
}
