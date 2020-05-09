import XCTest
@testable import iperf3Runner

final class iperf3RunnerTests: XCTestCase {
  func testExample() {
    let configuration = Iperf3RunnerConfiguration(hostname: "192.168.118.168", port: 5201, duration: 10, streams: 4, type: .download)
    let test = Iperf3Runner(configuration: configuration)
    var didCall = false

    let exp = expectation(description: "Run test")

    test.start { status in
      if status.progress >= 1 {
        exp.fulfill()
      }
      didCall = true
      XCTAssert(didCall == true)
      print(status.bandwidth)
    }

    waitForExpectations(timeout: 15) { _ in }
  }

  static var allTests = [
    ("testExample", testExample),
  ]
}
