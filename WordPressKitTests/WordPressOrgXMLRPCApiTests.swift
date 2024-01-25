import Foundation
import XCTest
import OHHTTPStubs
import wpxmlrpc
@testable import WordPressKit

class WordPressOrgXMLRPCApiTests: XCTestCase {

    let xmlrpcEndpoint = "http://wordpress.org/xmlrpc.php"

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        HTTPStubs.removeAllStubs()
    }

    private func isXmlRpcAPIRequest() -> HTTPStubsTestBlock {
        return { request in
            return request.url?.absoluteString == self.xmlrpcEndpoint
        }
    }

    func testSuccessfullCall() {
        stub(condition: isXmlRpcAPIRequest()) { _ in
            let stubPath = OHPathForFile("xmlrpc-response-getpost.xml", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type" as NSObject: "application/xml" as AnyObject])
        }

        let expect = self.expectation(description: "One callback should be invoked")
        let api = WordPressOrgXMLRPCApi(endpoint: URL(string: xmlrpcEndpoint)! as URL)
        api.callMethod("wp.getPost", parameters: nil, success: { (responseObject: AnyObject, _: HTTPURLResponse?) in
            expect.fulfill()
            XCTAssert(responseObject is [String: AnyObject], "The response should be a dictionary")
            }, failure: { (_, _) in
                expect.fulfill()
                XCTFail("This call should be successfull")
            }
        )
        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func test404() {
        stub(condition: isXmlRpcAPIRequest()) { _ in
            HTTPStubsResponse(data: Data(), statusCode: 404, headers: ["Content-Type": "application/xml"])
        }

        let expect = self.expectation(description: "One callback should be invoked")
        let api = WordPressOrgXMLRPCApi(endpoint: URL(string: xmlrpcEndpoint)! as URL)
        api.callMethod(
            "wp.getPost",
            parameters: nil,
            success: { (responseObject: AnyObject, _: HTTPURLResponse?) in
                expect.fulfill()
                XCTFail("This call should fail")
            },
            failure: { (error, _) in
                expect.fulfill()

                XCTAssertEqual(error.domain, WordPressOrgXMLRPCApiErrorDomain)
                XCTAssertEqual(error.code, WordPressOrgXMLRPCApiError.httpErrorStatusCode.rawValue)
            }
        )
        wait(for: [expect], timeout: 0.1)
    }

    func test403() {
        stub(condition: isXmlRpcAPIRequest()) { _ in
            HTTPStubsResponse(data: Data(), statusCode: 403, headers: ["Content-Type": "application/xml"])
        }

        let expect = self.expectation(description: "One callback should be invoked")
        let api = WordPressOrgXMLRPCApi(endpoint: URL(string: xmlrpcEndpoint)! as URL)
        api.callMethod(
            "wp.getPost",
            parameters: nil,
            success: { (responseObject: AnyObject, _: HTTPURLResponse?) in
                expect.fulfill()
                XCTFail("This call should fail")
            },
            failure: { (error, _) in
                expect.fulfill()

                XCTAssertFalse(error is WordPressOrgXMLRPCApiError)
                XCTAssertEqual(error.domain, WordPressOrgXMLRPCApiErrorDomain)
                XCTAssertEqual(error.code, 403)
            }
        )
        wait(for: [expect], timeout: 0.1)
    }

    func test403WithoutContentTypeHeader() {
        stub(condition: isXmlRpcAPIRequest()) { _ in
            HTTPStubsResponse(data: Data(), statusCode: 403, headers: nil)
        }

        let expect = self.expectation(description: "One callback should be invoked")
        let api = WordPressOrgXMLRPCApi(endpoint: URL(string: xmlrpcEndpoint)! as URL)
        api.callMethod(
            "wp.getPost",
            parameters: nil,
            success: { (responseObject: AnyObject, _: HTTPURLResponse?) in
                expect.fulfill()
                XCTFail("This call should fail")
            },
            failure: { (error, _) in
                expect.fulfill()

                XCTAssertTrue(error is WordPressOrgXMLRPCApiError)
                XCTAssertEqual(error.domain, WordPressOrgXMLRPCApiErrorDomain)
                XCTAssertEqual(error.code, WordPressOrgXMLRPCApiError.unknown.rawValue)
            }
        )
        wait(for: [expect], timeout: 0.1)
    }

    func testConnectionError() {
        stub(condition: isXmlRpcAPIRequest()) { _ in
            HTTPStubsResponse(error: URLError(.timedOut))
        }

        let expect = self.expectation(description: "One callback should be invoked")
        let api = WordPressOrgXMLRPCApi(endpoint: URL(string: xmlrpcEndpoint)! as URL)
        api.callMethod(
            "wp.getPost",
            parameters: nil,
            success: { (responseObject: AnyObject, _: HTTPURLResponse?) in
                expect.fulfill()
                XCTFail("This call should fail")
            },
            failure: { (error, _) in
                expect.fulfill()

                XCTAssertTrue(error is URLError)
                XCTAssertEqual(error.domain, URLError.errorDomain)
                XCTAssertEqual(error.code, URLError.Code.timedOut.rawValue)
            }
        )
        wait(for: [expect], timeout: 0.1)
    }

    func testFault() throws {
        let responseFile = try XCTUnwrap(OHPathForFile("xmlrpc-bad-username-password-error.xml", WordPressOrgXMLRPCApiTests.self))
        stub(condition: isXmlRpcAPIRequest()) { _ in
            fixture(filePath: responseFile, headers: ["Content-Type": "application/xml"])
        }

        let expect = self.expectation(description: "One callback should be invoked")
        let api = WordPressOrgXMLRPCApi(endpoint: URL(string: xmlrpcEndpoint)! as URL)
        api.callMethod(
            "wp.getPost",
            parameters: nil,
            success: { (responseObject: AnyObject, _: HTTPURLResponse?) in
                expect.fulfill()
                XCTFail("This call should fail")
            },
            failure: { (error, _) in
                expect.fulfill()

                XCTAssertEqual(error.domain, WPXMLRPCFaultErrorDomain)
                // 403 is the 'faultCode' in the HTTP response xml.
                XCTAssertEqual(error.code, 403)
            }
        )
        wait(for: [expect], timeout: 0.1)
    }

    func testFault401() throws {
        let responseFile = try XCTUnwrap(OHPathForFile("xmlrpc-bad-username-password-error.xml", WordPressOrgXMLRPCApiTests.self))
        stub(condition: isXmlRpcAPIRequest()) { _ in
            fixture(filePath: responseFile, status: 401, headers: ["Content-Type": "application/xml"])
        }

        let expect = self.expectation(description: "One callback should be invoked")
        let api = WordPressOrgXMLRPCApi(endpoint: URL(string: xmlrpcEndpoint)! as URL)
        api.callMethod(
            "wp.getPost",
            parameters: nil,
            success: { (responseObject: AnyObject, _: HTTPURLResponse?) in
                expect.fulfill()
                XCTFail("This call should fail")
            },
            failure: { (error, _) in
                expect.fulfill()

                XCTAssertEqual(error.domain, WPXMLRPCFaultErrorDomain)
                // 403 is the 'faultCode' in the HTTP response xml.
                XCTAssertEqual(error.code, 403)
            }
        )
        wait(for: [expect], timeout: 0.1)
    }

    func testMalformedXML() throws {
        stub(condition: isXmlRpcAPIRequest()) { _ in
            HTTPStubsResponse(
                data: #"<?xml version="1.0" encoding="UTF-8"?><methodRespons"#.data(using: .utf8)!,
                statusCode: 200,
                headers: ["Content-Type": "application/xml"]
            )
        }

        let expect = self.expectation(description: "One callback should be invoked")
        let api = WordPressOrgXMLRPCApi(endpoint: URL(string: xmlrpcEndpoint)! as URL)
        api.callMethod(
            "wp.getPost",
            parameters: nil,
            success: { (responseObject: AnyObject, _: HTTPURLResponse?) in
                expect.fulfill()
                XCTFail("This call should fail")
            },
            failure: { (error, _) in
                expect.fulfill()

                XCTAssertEqual(error.domain, XMLParser.errorDomain)
            }
        )
        wait(for: [expect], timeout: 0.1)
    }

    func testInvalidXML() throws {
        let responseFile = try XCTUnwrap(OHPathForFile("xmlrpc-response-invalid.html", WordPressOrgXMLRPCApiTests.self))
        stub(condition: isXmlRpcAPIRequest()) { _ in
            fixture(filePath: responseFile, headers: ["Content-Type": "application/xml"])
        }

        let expect = self.expectation(description: "One callback should be invoked")
        let api = WordPressOrgXMLRPCApi(endpoint: URL(string: xmlrpcEndpoint)! as URL)
        api.callMethod(
            "wp.getPost",
            parameters: nil,
            success: { (responseObject: AnyObject, _: HTTPURLResponse?) in
                expect.fulfill()
                XCTFail("This call should fail")
            },
            failure: { (error, _) in
                expect.fulfill()

                XCTAssertEqual(error.domain, WPXMLRPCErrorDomain)
                XCTAssertEqual(error.code, WPXMLRPCError.invalidInputError.rawValue)
            }
        )
        wait(for: [expect], timeout: 0.1)
    }

}
