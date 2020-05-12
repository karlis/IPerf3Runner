import XCTest
@testable import IPerf3Runner

final class IPerf3RunnerTests: XCTestCase {
  func testExample() {
    let configuration = IPerf3Runner.Configuration(hostname: "192.168.118.168", port: 5201, duration: 10, streams: 4, type: .download)
    guard let test = IPerf3Runner(configuration: configuration)
      else {
        XCTFail()
        return
    }

    let exp = expectation(description: "Run test")
    test.start { status in
      switch status {
        case .next(let bandwith):
          print("🏎", bandwith)
        case .completed(let bandwith):
          print("🏁", bandwith)
          XCTAssert(true)
          exp.fulfill()
        case .error:
          XCTFail()
      }
    }

    // wait for the test to finish
    waitForExpectations(timeout: 15) { _ in }
  }

  static var allTests = [
    ("testExample", testExample),
  ]
}
