import Foundation
import XCTest
@testable import WordPressKit

class WordPressAPIErrorTests: XCTestCase {

    func testLocalizedMessage() {
        struct TestError: LocalizedError {
            var errorDescription: String? = "this is a test error"
        }

        let error = WordPressAPIError.endpointError(TestError())
        XCTAssertEqual((error as NSError).localizedDescription, "this is a test error")
    }

    func testNilErrorDescription() {
        struct TestError: LocalizedError {
            var errorDescription: String? = nil
        }

        let error = WordPressAPIError.endpointError(TestError())
        XCTAssertEqual(error.localizedDescription, WordPressAPIError<TestError>.unknownErrorMessage)
        XCTAssertEqual((error as NSError).localizedDescription, WordPressAPIError<TestError>.unknownErrorMessage)
    }

}
