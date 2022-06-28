import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Activ5_IMUTests.allTests),
    ]
}
#endif
