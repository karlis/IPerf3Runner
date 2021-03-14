import XCTest
@testable import IPerf3Runner

final class IPerf3RunnerTests: XCTestCase {
  func testExample() {
    let configuration = IPerf3Runner.Configuration(
    hostname: "192.168.195.168", // This is an IP where iperf3 server is running.
    port: 5201,
    duration: 8,
    streams: 4,
    omit: 2,
    type: .download)
    guard let test = IPerf3Runner(configuration: configuration)
      else {
        XCTFail()
        return
    }

    let exp = expectation(description: "Run test")
    test.start { status in
      self.parseResult(exp: exp, status: status)
    }

    // wait for the test to finish
    waitForExpectations(timeout: 15) { _ in }

    // Sleep before starting upload.
    sleep(1)
    // TODO:
    // There must be some way to notify we can start upload.
    // Starting right after download returns a refused connection "sometimes"

    let upload = IPerf3Runner.Configuration(
      hostname: "192.168.118.168",
      port: 5201,
      duration: 8,
      streams: 4,
      omit: 2,
      type: .upload)
    let testUpload = IPerf3Runner(configuration: upload)

    let uploadExpectation = expectation(description: "Run test upload")
    testUpload?.start { status in
      self.parseResult(exp: uploadExpectation, status: status)
    }

    // wait for the test to finish
    waitForExpectations(timeout: 15) { _ in }
  }

  private func parseResult(
    exp: XCTestExpectation,
    status: IPerf3Runner.Status
  ) {
    switch status {
      case .next(let bandwith):
        print("🏎", bandwith)
      case .completed(let bandwith):
        print("🏁", bandwith)
        XCTAssert(true)
        exp.fulfill()
      case .error:
        perror("Failed: ")
        exp.fulfill()
        XCTFail()
    }
  }

  static var allTests = [
    ("testExample", testExample),
  ]
}
