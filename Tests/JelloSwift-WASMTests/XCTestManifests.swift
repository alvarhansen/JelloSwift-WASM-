import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(JelloSwift_WASMTests.allTests),
    ]
}
#endif
