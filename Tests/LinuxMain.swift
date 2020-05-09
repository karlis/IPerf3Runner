import XCTest

import iperf3RunnerTests

var tests = [XCTestCaseEntry]()
tests += iperf3RunnerTests.allTests()
XCTMain(tests)
