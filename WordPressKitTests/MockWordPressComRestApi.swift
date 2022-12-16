import Foundation
@testable import WordPressKit

class MockWordPressComRestApi: WordPressComRestApi {
    @objc var getMethodCalled = false
    @objc var postMethodCalled = false
    @objc var URLStringPassedIn: String?
    @objc var parametersPassedIn: AnyObject?
    @objc var successBlockPassedIn: ((AnyObject, HTTPURLResponse?) -> Void)?
    @objc var failureBlockPassedIn: ((NSError, HTTPURLResponse?) -> Void)?

    override func GET(_ URLString: String?, parameters: [String: AnyObject]?, success: @escaping ((AnyObject, HTTPURLResponse?) -> Void), failure: @escaping ((NSError, HTTPURLResponse?) -> Void)) -> Progress? {
        getMethodCalled = true
        URLStringPassedIn = URLString
        parametersPassedIn = parameters as AnyObject?
        successBlockPassedIn = success
        failureBlockPassedIn = failure

        return Progress()
    }

    override func GETData(_ URLString: String, parameters: [String: AnyObject]?, completion: @escaping (Result<(Data, HTTPURLResponse?), Error>) -> Void) {
        getMethodCalled = true
        URLStringPassedIn = URLString
        parametersPassedIn = parameters as AnyObject?
    }

    override func POST(_ URLString: String, parameters: [String: AnyObject]?, completion: @escaping (Result<(Data, HTTPURLResponse?), Error>) -> Void) {
        postMethodCalled = true
        URLStringPassedIn = URLString
        parametersPassedIn = parameters as AnyObject?
    }

    override func POST(_ URLString: String?, parameters: [String: AnyObject]?, success: @escaping ((AnyObject, HTTPURLResponse?) -> Void), failure: @escaping ((NSError, HTTPURLResponse?) -> Void)) -> Progress? {
        postMethodCalled = true
        URLStringPassedIn = URLString
        parametersPassedIn = parameters as AnyObject?
        successBlockPassedIn = success
        failureBlockPassedIn = failure

        return Progress()
    }

    override func multipartPOST(_ URLString: String,
                                parameters: [String: AnyObject]?,
                                fileParts: [FilePart],
                                requestEnqueued: RequestEnqueuedBlock? = nil,
                                success: @escaping SuccessResponseBlock,
                                failure: @escaping FailureReponseBlock) -> Progress? {

        postMethodCalled = true
        URLStringPassedIn = URLString
        parametersPassedIn = parameters as AnyObject?
        successBlockPassedIn = success
        failureBlockPassedIn = failure
        return Progress()
    }

    @objc func methodCalled() -> String {

        var method = "Unknown"
        if getMethodCalled {
            method = "GET"
        } else if postMethodCalled {
            method = "POST"
        }

        return method
    }
}

class MockWordPressOrgRestApi: WordPressOrgRestApi {
    var getMethodCalled = false
    var URLStringPassedIn: String?
    var parametersPassedIn: AnyObject?
    var completionPassedIn: WordPressOrgRestApi.Completion?

    init() {
        super.init(apiBase: URL(string: "https://example.com")!)
    }

    override func GET(_ path: String, parameters: [String: AnyObject]?, completion: @escaping WordPressOrgRestApi.Completion) -> Progress? {
        getMethodCalled = true
        URLStringPassedIn = path
        parametersPassedIn = parameters as AnyObject?
        completionPassedIn = completion

        return Progress()
    }

    @objc func methodCalled() -> String {

        var method = "Unknown"
        if getMethodCalled {
            method = "GET"
        }

        return method
    }
}
