import XCTest
@testable import XMLRPC

final class PostConverterTests: XCTestCase {

    func testThatPostParserWorksForPostsWithNoPassword() throws {
        try XCTAssertNil(XCTUnwrap(parsePosts().post(withID: 1153)).password)
    }

    func testThatPostParserWorksForPostsWithAPassword() throws {
        try XCTAssertEqual(parsePosts().post(withID: 1168)?.password, "enter")
    }

    func testThatPostParserImportsAllPosts() throws {
        try XCTAssertEqual(parsePosts().count, 61)
    }

    func testThatPostParserImportsTerms() throws {
        try XCTAssertEqual(parsePosts().post(withID: 1153)?.terms.count, 3)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        let sampleData =  try sampleData(named: "posts-response")
        let processor = PostResponseProcessor()
        self.measure {
            do {
                _ = try processor.process(sampleData)
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }

    @discardableResult
    private func parsePosts() throws -> [WPPost] {
        try PostResponseProcessor().process(try sampleData(named: "posts-response"))
    }

    func XCTAssertDatesAreEqual(_ lhs: Date, _ rhs: Date, file: StaticString = #file, line: UInt = #line) {
        let lhsValue = Int(lhs.timeIntervalSince1970)
        let rhsValue = Int(rhs.timeIntervalSince1970)

        XCTAssertEqual(lhsValue, rhsValue, file: file, line: line)
    }
}
