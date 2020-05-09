import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(iperf3RunnerTests.allTests),
    ]
}
#endif
