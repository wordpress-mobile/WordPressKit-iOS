import Foundation
import XCTest
import OHHTTPStubs
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

    func testProgressUpdate() {
        stub(condition: isXmlRpcAPIRequest()) { _ in
            let stubPath = OHPathForFile("xmlrpc-response-getpost.xml", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type" as NSObject: "application/xml" as AnyObject])
        }

        let success = self.expectation(description: "The success callback should be invoked")
        let api = WordPressOrgXMLRPCApi(endpoint: URL(string: xmlrpcEndpoint)! as URL)
        let progress = api.callMethod(
            "wp.getPost",
            parameters: nil,
            success: { (_, _) in success.fulfill() },
            failure: { (_, _) in }
        )

        let observerCalled = expectation(description: "Progress observer is called")
        observerCalled.assertForOverFulfill = false
        let observer = progress?.observe(\.fractionCompleted, options: .new, changeHandler: { _, _ in
            XCTAssertTrue(Thread.isMainThread)
            observerCalled.fulfill()
        })

        wait(for: [success, observerCalled], timeout: 0.1)
        observer?.invalidate()

        XCTAssertEqual(progress?.fractionCompleted, 1)
    }

    func testProgressUpdateFailure() {
        stub(condition: isXmlRpcAPIRequest()) { _ in
            let stubPath = OHPathForFile("xmlrpc-bad-username-password-error.xml", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type" as NSObject: "application/xml" as AnyObject])
        }

        let failure = self.expectation(description: "The failure callback should be invoked")
        let api = WordPressOrgXMLRPCApi(endpoint: URL(string: xmlrpcEndpoint)! as URL)
        let progress = api.callMethod(
            "wp.getPost",
            parameters: nil,
            success: { (_, _) in },
            failure: { (_, _) in failure.fulfill() }
        )

        let observerCalled = expectation(description: "Progress observer is called")
        observerCalled.assertForOverFulfill = false
        let observer = progress?.observe(\.fractionCompleted, options: .new, changeHandler: { _, _ in
            XCTAssertTrue(Thread.isMainThread)
            observerCalled.fulfill()
        })

        wait(for: [failure, observerCalled], timeout: 0.1)
        observer?.invalidate()

        XCTAssertEqual(progress?.fractionCompleted, 1)
    }

    func testProgressUpdateStreamAPI() {
        stub(condition: isXmlRpcAPIRequest()) { _ in
            let stubPath = OHPathForFile("xmlrpc-response-getpost.xml", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type" as NSObject: "application/xml" as AnyObject])
        }

        let success = self.expectation(description: "The success callback should be invoked")
        let api = WordPressOrgXMLRPCApi(endpoint: URL(string: xmlrpcEndpoint)! as URL)
        let progress = api.streamCallMethod(
            "wp.getPost",
            parameters: nil,
            success: { (_, _) in success.fulfill() },
            failure: { (_, _) in }
        )

        let observerCalled = expectation(description: "Progress observer is called")
        observerCalled.assertForOverFulfill = false
        let observer = progress?.observe(\.fractionCompleted, options: .new, changeHandler: { _, _ in
            XCTAssertTrue(Thread.isMainThread)
            observerCalled.fulfill()
        })

        wait(for: [success, observerCalled], timeout: 0.1)
        observer?.invalidate()

        XCTAssertEqual(progress?.fractionCompleted, 1)
    }

    func testProgressUpdateStreamAPIFailure() {
        stub(condition: isXmlRpcAPIRequest()) { _ in
            let stubPath = OHPathForFile("xmlrpc-bad-username-password-error.xml", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type" as NSObject: "application/xml" as AnyObject])
        }

        let failure = self.expectation(description: "The failure callback should be invoked")
        let api = WordPressOrgXMLRPCApi(endpoint: URL(string: xmlrpcEndpoint)! as URL)
        let progress = api.streamCallMethod(
            "wp.getPost",
            parameters: nil,
            success: { (_, _) in },
            failure: { (_, _) in failure.fulfill() }
        )

        let observerCalled = expectation(description: "Progress observer is called")
        observerCalled.assertForOverFulfill = false
        let observer = progress?.observe(\.fractionCompleted, options: .new, changeHandler: { _, _ in
            XCTAssertTrue(Thread.isMainThread)
            observerCalled.fulfill()
        })

        wait(for: [failure, observerCalled], timeout: 0.1)
        observer?.invalidate()

        XCTAssertEqual(progress?.fractionCompleted, 1)
    }

}
