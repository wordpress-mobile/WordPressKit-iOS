import XCTest
@testable import XMLRPC

final class PostsParserTests: XCTestCase {

    let emptyInstance = PostsResponseParser(response: Data())

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
        let parser = PostsResponseParser(response: sampleData)
        self.measure {
            do {
                _ = try parser.parse()
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }

    @discardableResult
    private func parsePosts() throws -> [WPPost] {
        try getParser().parse()
    }

    private func getParser() throws -> PostsResponseParser {
        PostsResponseParser(response: try sampleData(named: "posts-response"))
    }

    func XCTAssertDatesAreEqual(_ lhs: Date, _ rhs: Date, file: StaticString = #file, line: UInt = #line) {
        let lhsValue = Int(lhs.timeIntervalSince1970)
        let rhsValue = Int(rhs.timeIntervalSince1970)

        XCTAssertEqual(lhsValue, rhsValue, file: file, line: line)
    }
}
