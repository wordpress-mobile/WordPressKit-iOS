import XCTest
import OHHTTPStubs
import WordPressShared

@testable import WordPressKit

@available(iOS 15.0.0, *)
class WordPressComRestApiAsyncAwaitTests: XCTestCase {

    private let url = "https://public-api.wordpress.com/rest/v1.1/sites/0/media/"

    override func tearDown() {
        HTTPStubs.removeAllStubs()
    }

    func testSuccessfullGetCall() async throws {
        stub(condition: isAbsoluteURLString(url)) { _ in
            let stubPath = OHPathForFile("WordPressComRestApiMedia.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type" as NSObject: "application/json" as AnyObject])
        }

        let api = WordPressComRestApi(oAuthToken: "fakeToken")
        let (data, response) = try await api.get(url)

        XCTAssertNotNil(data)
        XCTAssertEqual(response.mimeType, "application/json")
    }

    func testBadServerResponseGetCall() async throws {
        stub(condition: isAbsoluteURLString(url)) { _ in
            let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.badServerResponse.rawValue)
            return HTTPStubsResponse(error: notConnectedError)
        }

        do {
            let api = WordPressComRestApi(oAuthToken: "fakeToken")
            _ = try await api.get(url)
            XCTFail("Expected to throw while awaiting, but succeeded")
        } catch {
            XCTAssertEqual(error.localizedDescription, "The operation couldn’t be completed. (NSURLErrorDomain error -1011.)")
        }
    }

    struct AnyModel: Decodable {
        let number: Int
    }

    func testSuccessfullGetCodableCall() async throws {
        stub(condition: isAbsoluteURLString(url)) { _ in
            return HTTPStubsResponse(jsonObject: ["number": 123], statusCode: 200, headers: ["Content-Type" as NSObject: "application/json" as AnyObject])
        }

        let api = WordPressComRestApi(oAuthToken: "fakeToken")
        let anyModel = try await api.get(url, ofType: AnyModel.self)

        XCTAssertEqual(anyModel.number, 123)
    }

    func testUnsuccessfullGetCodableCall() async throws {
        stub(condition: isAbsoluteURLString(url)) { _ in
            return HTTPStubsResponse(jsonObject: ["number": "notnumber"], statusCode: 200, headers: ["Content-Type" as NSObject: "application/json" as AnyObject])
        }

        do {
            let api = WordPressComRestApi(oAuthToken: "fakeToken")
            let _ = try await api.get(url, ofType: AnyModel.self)
        } catch {
            XCTAssertNotNil((error as? DecodingError))
        }
    }

    func testSuccessfullGetCodableCalssl() async throws {
        stub(condition: isMethodPOST()) { request in
            let bodyString = String(data: request.ohhttpStubs_httpBody ?? Data(),
                                    encoding: String.Encoding.utf8)

            if bodyString != "foo=bar" {
                XCTFail("Incorrect POST params sent.")
            }

            return HTTPStubsResponse(jsonObject: ["number": 123], statusCode: 200, headers: ["Content-Type" as NSObject: "application/json" as AnyObject])
        }

        let api = WordPressComRestApi(oAuthToken: "fakeToken")
        let anyModel = try await api.post(url, parameters: ["foo": "bar"], ofType: AnyModel.self)

        XCTAssertEqual(anyModel.number, 123)
    }
}
