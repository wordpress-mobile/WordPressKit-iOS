@testable import WordPressKit
import XCTest

// This is an incomplete test for implementing RFC 3339.
// It's purpose is to ensure our code "works".
//
// See also:
//
// - https://datatracker.ietf.org/doc/html/rfc3339
class NSDateRFC3339Tests: XCTestCase {

    func testDateFormatterConfiguration() throws {
        let rfc3339Formatter = try XCTUnwrap(NSDate.rfc3339DateFormatter())

        XCTAssertEqual(rfc3339Formatter.timeZone, TimeZone(secondsFromGMT: 0))
        XCTAssertEqual(rfc3339Formatter.locale, Locale(identifier: "en_US_POSIX"))
        XCTAssertEqual(rfc3339Formatter.dateFormat, "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ")
    }

    func testValidRFC3339DateFromString() {
        XCTAssertEqual(
            NSDate(wordPressComJSONString: "2023-03-19T15:00:00Z"),
            NSDate(timeIntervalSince1970: 1_679_238_000)
        )
    }

    func testInvalidRFC3339DateFromString() {
        XCTAssertNil(NSDate(wordPressComJSONString: "2024-01-01"))
    }

    func testInvalidDateFromString() {
        XCTAssertNil(NSDate(wordPressComJSONString: "not a date"))
    }

    func testValidRFC3339StringFromDate() {
        XCTAssertEqual(
            NSDate(timeIntervalSince1970: 1_679_238_000).wordPressComJSONString(),
            // Apparently, NSDateFormatter doesn't offer a way to specify Z vs +0000.
            // This might go all the way back to the ISO 8601 and RFC 3339 specs overlap.
            "2023-03-19T15:00:00+0000"
        )
    }
}
