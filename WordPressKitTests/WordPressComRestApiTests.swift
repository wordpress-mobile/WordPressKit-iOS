import Foundation
import XCTest
import OHHTTPStubs
import WordPressShared
@testable import WordPressKit

class WordPressComRestApiTests: XCTestCase {

    let scheme                          = "https"
    let host                            = "public-api.wordpress.com"
    let wordPressMediaRoutePath         = "/rest/v1.1/sites/0/media/"
    let wordPressMediaNewEndpointPath   = "/rest/v1.1/sites/0/media/new"

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        HTTPStubs.removeAllStubs()
    }

    private func isRestAPIRequest() -> HTTPStubsTestBlock {
        return { request in
            guard let requestURL = request.url, let components = URLComponents(string: requestURL.absoluteString) else {
                return false
            }

            let expectedScheme = self.scheme
            let actualScheme = components.scheme

            let expectedHost = self.host
            let actualHost = components.host

            let expectedPath = self.wordPressMediaRoutePath
            let actualPath = components.path

            let result = expectedScheme == actualScheme && expectedHost == actualHost && expectedPath == actualPath
            return result
        }
    }

    private func isRestAPIMediaNewRequest() -> HTTPStubsTestBlock {
        return { request in
            guard let requestURL = request.url, let components = URLComponents(string: requestURL.absoluteString) else {
                return false
            }

            let expectedScheme = self.scheme
            let actualScheme = components.scheme

            let expectedHost = self.host
            let actualHost = components.host

            let expectedPath = self.wordPressMediaNewEndpointPath
            let actualPath = components.path

            let result = expectedScheme == actualScheme && expectedHost == actualHost && expectedPath == actualPath
            return result
        }
    }

    func testSuccessfullCall() {
        stub(condition: isRestAPIRequest()) { _ in
            let stubPath = OHPathForFile("WordPressComRestApiMedia.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type" as NSObject: "application/json" as AnyObject])
        }

        let expect = self.expectation(description: "One callback should be invoked")
        let api = WordPressComRestApi(oAuthToken: "fakeToken")
        api.GET(wordPressMediaRoutePath, parameters: nil, success: { (responseObject: AnyObject, _: HTTPURLResponse?) in
            expect.fulfill()
            XCTAssert(responseObject is [String: AnyObject], "The response should be a dictionary")
            }, failure: { (_, _) in
                expect.fulfill()
                XCTFail("This call should be successfull")
            }
        )
        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testBaseUrl() {
        let defaultApi = WordPressComRestApi()
        XCTAssertEqual(defaultApi.baseURLString, "https://public-api.wordpress.com/")
        XCTAssertTrue(defaultApi.buildRequestURLFor(path: "/path")!.hasPrefix("https://public-api.wordpress.com/path"))

        let localhostApi = WordPressComRestApi(baseUrlString: "http://localhost:8080")
        XCTAssertEqual(localhostApi.baseURLString, "http://localhost:8080")
        XCTAssertTrue(localhostApi.buildRequestURLFor(path: "/path")!.hasPrefix("http://localhost:8080/path"))
    }

    func testInvalidTokenFailedCall() {
        stub(condition: isRestAPIRequest()) { _ in
            let stubPath = OHPathForFile("WordPressComRestApiFailRequestInvalidToken.json", type(of: self))
            return fixture(filePath: stubPath!, status: 400, headers: ["Content-Type" as NSObject: "application/json" as AnyObject])
        }

        let expect = self.expectation(description: "One callback should be invoked")
        let api = WordPressComRestApi(oAuthToken: "fakeToken")
        api.GET(wordPressMediaRoutePath, parameters: nil, success: { (_: AnyObject, _: HTTPURLResponse?) in
            expect.fulfill()
            XCTFail("This call should fail")
            }, failure: { (error, _) in
                expect.fulfill()
                XCTAssert(error.domain == String(reflecting: WordPressComRestApiError.self), "The error should a WordPressComRestApiError")
                XCTAssert(error.code == Int(WordPressComRestApiError.invalidToken.rawValue), "The error code should be invalid token")
        })
        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testInvalidJSONReceivedFailedCall() {
        stub(condition: isRestAPIRequest()) { _ in
            let stubPath = OHPathForFile("WordPressComRestApiFailInvalidJSON.json", type(of: self))
            return fixture(filePath: stubPath!, status: 200, headers: ["Content-Type" as NSObject: "application/json" as AnyObject])
        }
        let expect = self.expectation(description: "One callback should be invoked")
        let api = WordPressComRestApi(oAuthToken: "fakeToken")
        api.GET(wordPressMediaRoutePath, parameters: nil, success: { (_: AnyObject, _: HTTPURLResponse?) in
            expect.fulfill()
            XCTFail("This call should fail")
            }, failure: { (error, _) in
                expect.fulfill()
                XCTAssert(error.domain == WordPressComRestApiErrorDomain, "The error domain should be WordPressComRestApiErrorDomain")
                XCTAssert(error.code == Int(WordPressComRestApiError.responseSerializationFailed.rawValue), "The code should be invalid response serialization")
        })
        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testInvalidJSONSentFailedCall() {
        stub(condition: isRestAPIMediaNewRequest()) { _ in
            let stubPath = OHPathForFile("WordPressComRestApiFailInvalidInput.json", type(of: self))
            return fixture(filePath: stubPath!, status: 400, headers: ["Content-Type" as NSObject: "application/json" as AnyObject])
        }
        let expect = self.expectation(description: "One callback should be invoked")
        let api = WordPressComRestApi(oAuthToken: "fakeToken")
        api.POST(wordPressMediaNewEndpointPath, parameters: nil, success: { (_: AnyObject, _: HTTPURLResponse?) in
            expect.fulfill()
            XCTFail("This call should fail")
            }, failure: { (error, _) in
                expect.fulfill()
                XCTAssert(error.domain == String(reflecting: WordPressComRestApiError.self), "The error domain should be WordPressComRestApiError")
                XCTAssert(error.code == Int(WordPressComRestApiError.invalidInput.rawValue), "The error code should be invalid input")
        })
        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testUnauthorizedFailedCall() {
        stub(condition: isRestAPIMediaNewRequest()) { _ in
            let stubPath = OHPathForFile("WordPressComRestApiFailUnauthorized.json", type(of: self))
            return fixture(filePath: stubPath!, status: 403, headers: ["Content-Type" as NSObject: "application/json" as AnyObject])
        }
        let expect = self.expectation(description: "One callback should be invoked")
        let api = WordPressComRestApi(oAuthToken: "fakeToken")
        api.POST(wordPressMediaNewEndpointPath, parameters: nil, success: { (_: AnyObject, _: HTTPURLResponse?) in
            expect.fulfill()
            XCTFail("This call should fail")
            }, failure: { (error, _) in
                expect.fulfill()
                XCTAssert(error.domain == String(reflecting: WordPressComRestApiError.self), "The error domain should be WordPressComRestApiError")
                XCTAssert(error.code == Int(WordPressComRestApiError.authorizationRequired.rawValue), "The error code should be AuthorizationRequired")
        })
        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testMultipleErrorsFailedCall() {
        stub(condition: isRestAPIMediaNewRequest()) { _ in
            let stubPath = OHPathForFile("WordPressComRestApiMultipleErrors.json", type(of: self))
            return fixture(filePath: stubPath!, status: 403, headers: ["Content-Type" as NSObject: "application/json" as AnyObject])
        }
        let expect = self.expectation(description: "One callback should be invoked")
        let api = WordPressComRestApi(oAuthToken: "fakeToken")
        api.POST(wordPressMediaNewEndpointPath, parameters: nil, success: { (_: AnyObject, _: HTTPURLResponse?) in
            expect.fulfill()
            XCTFail("This call should fail")
            }, failure: { (error, _) in
                expect.fulfill()
                XCTAssert(error.domain == String(reflecting: WordPressComRestApiError.self), "The error domain should be WordPressComRestApiError")
                XCTAssert(error.code == Int(WordPressComRestApiError.uploadFailed.rawValue), "The error code should be AuthorizationRequired")
        })
        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testMultipleErrorsFailedMultiPartPostCall() {
        stub(condition: isRestAPIMediaNewRequest()) { _ in
            let stubPath = OHPathForFile("WordPressComRestApiMultipleErrors.json", type(of: self))
            return fixture(filePath: stubPath!, status: 403, headers: ["Content-Type" as NSObject: "application/json" as AnyObject])
        }
        let expect = self.expectation(description: "One callback should be invoked")
        let api = WordPressComRestApi(oAuthToken: "fakeToken")
        api.multipartPOST(wordPressMediaNewEndpointPath, parameters: nil, fileParts: [], success: { (_: AnyObject, _: HTTPURLResponse?) in
            expect.fulfill()
            XCTFail("This call should fail")
        }, failure: { (error, _) in
            expect.fulfill()
            XCTAssert(error.domain == String(reflecting: WordPressComRestApiError.self), "The error domain should be WordPressComRestApiError")
            XCTAssert(error.code == Int(WordPressComRestApiError.uploadFailed.rawValue), "The error code should be AuthorizationRequired")
        })
        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testStreamMethodCallWithInvalidFile() {
        stub(condition: isRestAPIMediaNewRequest()) { _ in
            let stubPath = OHPathForFile("WordPressComRestApiMedia.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type" as NSObject: "application/json" as AnyObject])
        }

        let expect = self.expectation(description: "One callback should be invoked")
        let api = WordPressComRestApi(oAuthToken: "fakeToken")
        let filePart = FilePart(parameterName: "file", url: URL(fileURLWithPath: "/a.txt") as URL, filename: "a.txt", mimeType: "image/jpeg")
        api.multipartPOST(wordPressMediaNewEndpointPath, parameters: nil, fileParts: [filePart], success: { (_: AnyObject, _: HTTPURLResponse?) in
            expect.fulfill()
            XCTFail("This call should fail")
            }, failure: { (_, _) in
                expect.fulfill()
            }
        )
        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testStreamMethodParallelCalls() {
        stub(condition: isRestAPIMediaNewRequest()) { _ in
            let stubPath = OHPathForFile("WordPressComRestApiMedia.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type" as NSObject: "application/json" as AnyObject])
        }
        guard
            let mediaPath = OHPathForFile("test-image.jpg", type(of: self))
        else {
            return
        }
        let mediaURL = URL(fileURLWithPath: mediaPath)
        let expect = self.expectation(description: "One callback should be invoked")
        let api = WordPressComRestApi(oAuthToken: "fakeToken")
        let filePart = FilePart(parameterName: "media[]", url: mediaURL as URL, filename: "test-image.jpg", mimeType: "image/jpeg")
        let progress1 = api.multipartPOST(wordPressMediaNewEndpointPath, parameters: nil, fileParts: [filePart], success: { (_: AnyObject, _: HTTPURLResponse?) in
                XCTFail("This call should fail")
            }, failure: { (error, _) in
                print(error)
                XCTAssert(error.domain == NSURLErrorDomain, "The error domain should be NSURLErrorDomain")
                XCTAssert(error.code == NSURLErrorCancelled, "The error code should be NSURLErrorCancelled")
            }
        )
        progress1?.cancel()
        api.multipartPOST(wordPressMediaNewEndpointPath, parameters: nil, fileParts: [filePart], success: { (_: AnyObject, _: HTTPURLResponse?) in
            expect.fulfill()

            }, failure: { (_, _) in
                expect.fulfill()
                XCTFail("This call should succesful")
            }
        )
        self.waitForExpectations(timeout: 5, handler: nil)
    }

    func testCancelationOfRequest() {
        stub(condition: isRestAPIMediaNewRequest()) { _ in
            return HTTPStubsResponse.init(error: NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: nil))
        }
        let expect = self.expectation(description: "One callback should be invoked")
        let api = WordPressComRestApi(oAuthToken: "fakeToken")
        api.POST(wordPressMediaNewEndpointPath, parameters: nil, success: { (_: AnyObject, _: HTTPURLResponse?) in
            expect.fulfill()
            XCTFail("This call should fail")
        }, failure: { (error, _) in
            expect.fulfill()
            XCTAssert(error.domain == NSURLErrorDomain, "The error domain should be NSURLErrorDomain")
            XCTAssert(error.code == NSURLErrorCancelled, "The error code should be NSURLErrorCancelled")
        })
        self.waitForExpectations(timeout: 2, handler: nil)
    }

    // MARK: - WordPressRestApi Interfaces
    func testRequestPathModificationsWPV2() {
        let orgPath = "/wp/v2/themes?status=active"
        let expectedPath = "/wp/v2/sites/1001/themes?status=active"
        let api = WordPressComRestApi(oAuthToken: "fakeToken")
        let result = api.requestPath(fromOrgPath: orgPath, with: 1001)
        XCTAssertEqual(result, expectedPath)
    }

    func testRequestPathModificationsWPBlockEditor() {
        let orgPath = "/wp-block-editor/v1/settings"
        let expectedPath = "/wp-block-editor/v1/sites/1001/settings"
        let api = WordPressComRestApi(oAuthToken: "fakeToken")
        let result = api.requestPath(fromOrgPath: orgPath, with: 1001)
        XCTAssertEqual(result, expectedPath)
    }

    func testSuccessfullCallCommonGETStructure() {
        stub(condition: isRestAPIRequest()) { _ in
            let stubPath = OHPathForFile("WordPressComRestApiMedia.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type" as NSObject: "application/json" as AnyObject])
        }

        let expect = self.expectation(description: "One callback should be invoked")
        let api = WordPressComRestApi(oAuthToken: "fakeToken")

        api.GET(wordPressMediaRoutePath, parameters: nil) { (result, _) in
            expect.fulfill()
            switch result {
            case .success(let responseObject):
                XCTAssert(responseObject is [String: AnyObject], "The response should be a dictionary")
            case .failure:
                XCTFail("This call should be successfull")
            }
        }
        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testFailureCallCommonGETStructure() {
        stub(condition: isRestAPIRequest()) { _ in
            let stubPath = OHPathForFile("WordPressComRestApiFailInvalidJSON.json", type(of: self))
            return fixture(filePath: stubPath!, status: 200, headers: ["Content-Type" as NSObject: "application/json" as AnyObject])
        }
        let expect = self.expectation(description: "One callback should be invoked")
        let api = WordPressComRestApi(oAuthToken: "fakeToken")

        api.GET(wordPressMediaRoutePath, parameters: nil) { (result, _) in
            expect.fulfill()
            switch result {
            case .success:
                XCTFail("This call should fail")
            case .failure(let err):
                let error = err as NSError
                XCTAssert(error.domain == WordPressComRestApiErrorDomain, "The error domain should be WordPressComRestApiErrorDomain")
                XCTAssert(error.code == Int(WordPressComRestApiError.responseSerializationFailed.rawValue), "The code should be invalid response serialization")
            }
        }
        self.waitForExpectations(timeout: 2, handler: nil)
    }
}
