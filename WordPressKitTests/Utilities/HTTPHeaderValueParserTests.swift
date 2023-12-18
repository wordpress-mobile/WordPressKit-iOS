import Foundation
import XCTest

@testable import WordPressKit

class HTTPHeaderValueParserTests: XCTestCase {

    func testReturnOriginalCase() {
        XCTAssertEqual(
            HTTPURLResponse.value(ofParameter: "charset", inHeaderValue: "application/json; charset=UtF-8"),
            "UtF-8"
        )
    }

    func testCaseInsensitiveParameter() {
        XCTAssertEqual(
            HTTPURLResponse.value(ofParameter: "CharSet", inHeaderValue: "application/json; charset=utf-8"),
            "utf-8"
        )
    }

    func testFirstParameter() {
        XCTAssertEqual(
            HTTPURLResponse.value(ofParameter: "CharSet", inHeaderValue: "application/json; charset=utf-8;"),
            "utf-8"
        )
    }

    func testMiddleParameter() {
        XCTAssertEqual(
            HTTPURLResponse.value(ofParameter: "CharSet", inHeaderValue: "application/json; charset=utf-8; foo=bar"),
            "utf-8"
        )
    }

    func testLastParameter() {
        XCTAssertEqual(
            HTTPURLResponse.value(ofParameter: "CharSet", inHeaderValue: "application/json; charset=utf-8;"),
            "utf-8"
        )
    }

    func testLastParameterWithoutSemicolon() {
        XCTAssertEqual(
            HTTPURLResponse.value(ofParameter: "CharSet", inHeaderValue: "application/json; charset=utf-8"),
            "utf-8"
        )
    }

    func testNoSpaceBetweenParameters() {
        XCTAssertEqual(
            HTTPURLResponse.value(ofParameter: "CharSet", inHeaderValue: "application/json;charset=utf-8;foo=bar"),
            "utf-8"
        )
    }

    func testParameterValueWithQuotes() {
        XCTAssertEqual(
            HTTPURLResponse.value(ofParameter: "rel", inHeaderValue: "https://wordpress.org/wp-json; rel=\"https://api.w.org\""),
            "https://api.w.org"
        )

        XCTAssertEqual(
            HTTPURLResponse.value(ofParameter: "rel", inHeaderValue: "https://wordpress.org/wp-json; rel=\"https://api.w.org\"", stripQuotes: false),
            "\"https://api.w.org\""
        )
    }

}
