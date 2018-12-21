
import XCTest
@testable import WordPressKit

class SiteCreationServiceTests: RemoteTestCase, RESTTestable {

    func testSiteCreationRequest_Succeeds() {
        // Given
        let endpoint = "sites/new"
        let fileName = "site-creation-success.json"
        stubRemoteResponse(endpoint, filename: fileName, contentType: .ApplicationJSON)

        let request = SiteCreationRequest(
            segmentIdentifier: 1,
            verticalIdentifier: "p2v10",
            title: "Come on in",
            tagline: "This is a site I like",
            siteURLString: "Cool Restaurant",
            isPublic: true,
            languageIdentifier: "TEST-ENGLISH",
            shouldValidate: true,
            clientIdentifier: "TEST-ID",
            clientSecret: "TEST-SECRET"
        )

        // When, Then
        let siteCreationExpectation = expectation(description: "Initiate site creation request")
        let remote = WordPressComServiceRemote(wordPressComRestApi: getRestApi())
        remote.createWPComSite(request: request) { result in
            siteCreationExpectation.fulfill()

            switch result {
            case .success(let response):
                XCTAssertTrue(response.success)

                let site = response.createdSite
                XCTAssertEqual(site.identifier, "156355635")
                XCTAssertEqual(site.title, "10711c")
                XCTAssertEqual(site.urlString, "https://10711c.wordpress.com/")
                XCTAssertEqual(site.xmlrpcString, "https://10711c.wordpress.com/xmlrpc.php")
            case .failure(_):
                XCTFail()
            }
        }

        waitForExpectations(timeout: timeout)
    }
}
