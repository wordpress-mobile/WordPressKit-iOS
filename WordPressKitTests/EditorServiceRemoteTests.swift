import XCTest
@testable import WordPressKit

class EditorServiceRemoteTests: XCTestCase {

    let mockRemoteApi = MockWordPressComRestApi()
    var editorServiceRemote: EditorServiceRemote!
    let siteID = 99999

    override func setUp() {
        super.setUp()
        editorServiceRemote = EditorServiceRemote(wordPressComRestApi: mockRemoteApi)
    }

    func testPostDesignateMobileEditorPostMethodIsCalled() {
        editorServiceRemote.postDesignateMobileEditor(siteID, editor: .gutenberg, success: { _ in }, failure: { _ in })
        XCTAssertTrue(mockRemoteApi.postMethodCalled)
    }

    func testPostDesignateMobileEditorSuccess() {
        let expec = expectation(description: "success")
        let response: [String: String] = [
            "editor_mobile": "gutenberg",
            "editor_web": "gutenberg",
        ]

        editorServiceRemote.postDesignateMobileEditor(siteID, editor: EditorSettings.gutenberg, success: { editor in
            XCTAssertEqual(editor, .gutenberg)
            expec.fulfill()
        }) { (error) in
            XCTFail("This call should succeed. Error: \(error)")
            expec.fulfill()
        }
        mockRemoteApi.successBlockPassedIn?(response as AnyObject, HTTPURLResponse())

        wait(for: [expec], timeout: 0.1)
    }

    func testPostDesignateMobileEditorDoesNotCrashWithBadKeyResponse() {
        let expec = expectation(description: "success")
        let response: [String: String] = [
            "editor_mobile_bad": "gutenberg",
            "editor_web": "gutenberg",
        ]

        editorServiceRemote.postDesignateMobileEditor(siteID, editor: EditorSettings.gutenberg, success: { editor in
            XCTFail("This should fail")
            expec.fulfill()
        }) { (error) in
            let nsError = error as NSError
            XCTAssertEqual(nsError.code, NSCoderValueNotFoundError)
            expec.fulfill()
        }
        mockRemoteApi.successBlockPassedIn?(response as AnyObject, HTTPURLResponse())

        wait(for: [expec], timeout: 0.1)
    }

    func testPostDesignateMobileEditorDefaultsToAztecWithBadValueResponse() {
        let expec = expectation(description: "success")
        let response: [String: String] = [
            "editor_mobile": "guten_BORG",
            "editor_web": "gutenberg",
        ]

        editorServiceRemote.postDesignateMobileEditor(siteID, editor: EditorSettings.gutenberg, success: { editor in
            XCTAssertEqual(editor, .aztec)
            expec.fulfill()
        }) { (error) in
            XCTFail("This should not error")
            expec.fulfill()
        }
        mockRemoteApi.successBlockPassedIn?(response as AnyObject, HTTPURLResponse())

        wait(for: [expec], timeout: 0.1)
    }

    func testPostDesignateMobileEditorError() {
        let expec = expectation(description: "success")
        let errorExpec = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil)
        editorServiceRemote.postDesignateMobileEditor(siteID, editor: EditorSettings.gutenberg, success: { _ in
            XCTFail("This call should error")
            expec.fulfill()
        }) { (error) in
            XCTAssertEqual(error as NSError, errorExpec)
            expec.fulfill()
        }
        mockRemoteApi.failureBlockPassedIn?(errorExpec, nil)
        XCTAssertTrue(mockRemoteApi.postMethodCalled)
        wait(for: [expec], timeout: 0.1)
    }
}
