import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(IPerf3RunnerTests.allTests),
    ]
}
#endif
