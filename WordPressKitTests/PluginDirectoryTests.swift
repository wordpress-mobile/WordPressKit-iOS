import XCTest
@testable import WordPressKit

class PluginDirectoryTests: XCTestCase {
    
    func testPluginDirectoryEntryDecodingJetpack() {
        let jetpackMockPath = Bundle(for: type(of: self)).path(forResource: "plugin-directory-jetpack", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: jetpackMockPath))
        let endpoint = PluginDirectoryGetInformationEndpoint(slug: "jetpack")

        do {
            let plugin = try endpoint.parseResponse(data: data)
            XCTAssertEqual(plugin.name, "Jetpack by WordPress.com")
            XCTAssertEqual(plugin.slug, "jetpack")
            XCTAssertEqual(plugin.version, "5.5.1")
            XCTAssertEqual(plugin.author, "Automattic")
            XCTAssertEqual(plugin.authorURL, URL(string:"https://jetpack.com"))
            XCTAssertNotNil(plugin.icon)
            XCTAssertNotNil(plugin.banner)

        } catch {
            XCTFail("Failed decoding plugin \(error)")
        }
    }

    func testPluginDirectoryEntryDecodingRenameXmlrpc() {
        let jetpackMockPath = Bundle(for: type(of: self)).path(forResource: "plugin-directory-rename-xml-rpc", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: jetpackMockPath))
        let endpoint = PluginDirectoryGetInformationEndpoint(slug: "rename-xml-rpc")

        do {
            let plugin = try endpoint.parseResponse(data: data)
            XCTAssertEqual(plugin.name, "Rename XMLRPC")
            XCTAssertEqual(plugin.slug, "rename-xml-rpc")
            XCTAssertEqual(plugin.version, "1.1")
            XCTAssertEqual(plugin.author, "Jorge Bernal")
            XCTAssertEqual(plugin.authorURL, URL(string: "http://koke.me"))
            XCTAssertNil(plugin.icon)
            XCTAssertNil(plugin.banner)
        } catch {
            XCTFail("Failed decoding plugin \(error)")
        }
    }

    func testPluginInformationRequest() {
        let endpoint = PluginDirectoryGetInformationEndpoint(slug: "jetpack")
        do {
            let request = try endpoint.buildRequest()
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url?.absoluteString, "https://api.wordpress.org/plugins/info/1.0/jetpack.json?fields=icons%2Cbanners")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testValidateResponseFound() {
        let jetpackMockPath = Bundle(for: type(of: self)).path(forResource: "plugin-directory-rename-xml-rpc", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: jetpackMockPath))
        let endpoint = PluginDirectoryGetInformationEndpoint(slug: "jetpack")
        do {
            let request = try endpoint.buildRequest()
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "1.1", headerFields: nil)!
            XCTAssertNoThrow(try endpoint.validate(request: request, response: response, data: data))
        } catch {
            XCTFail(error.localizedDescription)
        }

    }

    func testValidateResponseNotFound() {
        let endpoint = PluginDirectoryGetInformationEndpoint(slug: "howdy")
        do {
            let request = try endpoint.buildRequest()
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "1.1", headerFields: nil)!
            XCTAssertThrowsError(try endpoint.validate(request: request, response: response, data: "null".data(using: .utf8)))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testValidatePluginDirectoryFeedResponseSucceeds() {
        let endpoint = PluginDirectoryFeedEndpoint(feedType: .popular)
        do {
            let request = try endpoint.buildRequest()
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "1.1", headerFields: nil)!
            XCTAssertNoThrow(try endpoint.validate(request: request, response: response, data: "null".data(using: .utf8)))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testValidatePluginDirectoryFeedResponseFails() {
        let endpoint = PluginDirectoryFeedEndpoint(feedType: .popular)
        do {
            let request = try endpoint.buildRequest()
            let response = HTTPURLResponse(url: request.url!, statusCode: 403, httpVersion: "1.1", headerFields: nil)!
            XCTAssertThrowsError(try endpoint.validate(request: request, response: response, data: "null".data(using: .utf8)))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testNewDirectoryFeedRequest() {
        let endpoint = PluginDirectoryFeedEndpoint(feedType: .newest)
        do {
            let request = try endpoint.buildRequest()
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url?.absoluteString, "https://api.wordpress.org/plugins/info/1.1/?action=query_plugins&request%5Bbrowse%5D=new&request%5Bfields%5D%5Bbanners%5D=1&request%5Bfields%5D%5Bicons%5D=1&request%5Bfields%5D%5Bsections%5D=0&request%5Bpage%5D=1&request%5Bper_page%5D=50")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testPopularDirectoryFeedRequest() {
        let endpoint = PluginDirectoryFeedEndpoint(feedType: .popular)
        do {
            let request = try endpoint.buildRequest()
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url?.absoluteString, "https://api.wordpress.org/plugins/info/1.1/?action=query_plugins&request%5Bbrowse%5D=popular&request%5Bfields%5D%5Bbanners%5D=1&request%5Bfields%5D%5Bicons%5D=1&request%5Bfields%5D%5Bsections%5D=0&request%5Bpage%5D=1&request%5Bper_page%5D=50")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testPopularDirectoryFeedDecoding() {
        let popularFeedMockPath = Bundle(for: type(of: self)).path(forResource: "plugin-directory-popular", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: popularFeedMockPath))
        let endpoint = PluginDirectoryFeedEndpoint(feedType: .popular)

        do {
            let response = try endpoint.parseResponse(data: data)
            XCTAssertEqual(response.pageMetadata.page, 1)
            XCTAssertEqual(response.plugins.count, 50)
            XCTAssertEqual(response.pageMetadata.pluginSlugs.count, 50)
            XCTAssertEqual(response.plugins.first!.name, "Contact Form 7")
            XCTAssertNotNil(response.plugins.first!.icon)

            let slugs = response.plugins.map { $0.slug }
            XCTAssertEqual(response.pageMetadata.pluginSlugs, slugs)

        } catch {
            XCTFail("Failed decoding plugin \(error)")
        }
    }

    func testNewDirectoryFeedDecoding() {
        // This also tests parsing the "broken" response where `plugins` is a [Int: Object] Dictionary, instead of an Array.

        let newFeedMockPath = Bundle(for: type(of: self)).path(forResource: "plugin-directory-new", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: newFeedMockPath))
        let endpoint = PluginDirectoryFeedEndpoint(feedType: .newest)

        do {
            let response = try endpoint.parseResponse(data: data)
            XCTAssertEqual(response.pageMetadata.page, 1)
            XCTAssertEqual(response.plugins.count, 48)
            XCTAssertEqual(response.pageMetadata.pluginSlugs.count, 48)
            XCTAssertEqual(response.plugins.first!.name, "NapoleonCat Chat Widget for Facebook")
            XCTAssertEqual(response.plugins.last!.name, "Woomizer")

            let slugs = response.plugins.map { $0.slug }
            XCTAssertEqual(response.pageMetadata.pluginSlugs, slugs)

        } catch {
            XCTFail("Failed decoding plugin \(error)")
        }
    }
    
    func testPluginDirectoryFeedPageDecoderSucceeds() {
        let newFeedMockPath = Bundle(for: type(of: self)).path(forResource: "plugin-directory-new", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: newFeedMockPath))

        do {
             let response = try JSONDecoder().decode(PluginDirectoryFeedPage.self, from: data)
            XCTAssertEqual(response.pageMetadata.page, 1)
            XCTAssertEqual(response.plugins.count, 48)
            XCTAssertEqual(response.pageMetadata.pluginSlugs.count, 48)
            XCTAssertEqual(response.plugins.first!.name, "NapoleonCat Chat Widget for Facebook")
            XCTAssertEqual(response.plugins.last!.name, "Woomizer")

            let slugs = response.plugins.map { $0.slug }
            XCTAssertEqual(response.pageMetadata.pluginSlugs, slugs)
            
        } catch {
            XCTFail("Failed decoding plugin \(error)")
        }
    }
    
    func testPluginFeedPageDirectoryEquatable() {
        let jetpackMockPath = Bundle(for: type(of: self)).path(forResource: "plugin-directory-jetpack", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: jetpackMockPath))
        let endpoint = PluginDirectoryGetInformationEndpoint(slug: "jetpack")
        
        do {
            let response = try endpoint.parseResponse(data: data)
            let sameResponse = try endpoint.parseResponse(data: data)
            XCTAssertTrue(response == sameResponse)
        } catch {
            XCTFail("Could not fetch Plugin Directory")
        }
    }

    func testPluginFeedPageDirectoryNotEquatable() {
        let popularFeedMockPath = Bundle(for: type(of: self)).path(forResource: "plugin-directory-popular", ofType: "json")!
        let popularData = try! Data(contentsOf: URL(fileURLWithPath: popularFeedMockPath))
        let popularEndpoint = PluginDirectoryFeedEndpoint(feedType: .popular)
        
        let newFeedMockPath = Bundle(for: type(of: self)).path(forResource: "plugin-directory-new", ofType: "json")!
        let newData = try! Data(contentsOf: URL(fileURLWithPath: newFeedMockPath))
        let newEndpoint = PluginDirectoryFeedEndpoint(feedType: .newest)
        
        do {
            let popularPluginFeedPage = try popularEndpoint.parseResponse(data: popularData)
            let newestPluginFeedPage = try newEndpoint.parseResponse(data: newData)
            
            XCTAssertFalse(popularPluginFeedPage == newestPluginFeedPage)
        } catch {
            XCTFail("Couldn't decode feed pages")
        }

        
    }


    func testExtractHTMLTextOutput() {
        let plugin = MockPluginDirectoryProvider.getPluginDirectoryEntry()
        let expectedInstallationText = extractHTMLText(MockPluginDirectoryProvider.getJetpackInstallationHTML())
        let expectedFAQText = extractHTMLText(MockPluginDirectoryProvider.getJetpackFAQHTML())

        XCTAssertEqual(plugin.installationText, expectedInstallationText)
        XCTAssertEqual(plugin.faqText, expectedFAQText)
    }


    func testDirectoryEntryStarRatingOutput() {
        let plugin = MockPluginDirectoryProvider.getPluginDirectoryEntry()

        let starRating = plugin.starRating
        let expected: Double = 4.0

        XCTAssertEqual(starRating, expected)
    }

    func testTrimChangeLogReturnsFirstOccurence() {
        let jetpack = MockPluginDirectoryProvider.getPluginDirectoryEntry()
        let changeLog = jetpack.changelogHTML

        let firstOccurence = trimChangelog(changeLog)
        let expectation = MockPluginDirectoryProvider.getJetackLogFistOccurence()

        XCTAssertNotEqual(firstOccurence, expectation)
    }

    func testInitFromResponseObjectOutput() {
        let jetpackPluginMockPath = Bundle(for: type(of: self)).path(forResource: "plugin-directory-jetpack", ofType: "json")!
        let json = JSONLoader().loadFile(jetpackPluginMockPath) as AnyObject
        guard let response = json as? [String : AnyObject] else {
            return
        }

        do {
            let directoryEntry = try PluginDirectoryEntry(responseObject: response)

            XCTAssertEqual(directoryEntry.name, "Jetpack by WordPress.com")
            XCTAssertEqual(directoryEntry.slug, "jetpack")
            XCTAssertEqual(directoryEntry.authorURL, nil)
            XCTAssertEqual(directoryEntry.lastUpdated, nil)
            XCTAssertEqual(directoryEntry.faqText, nil)
        } catch {
            XCTFail("Could not convert plugin \(error)")
        }
    }

    func testEcodeableDecodeableReturnsCorrectly(){
        let plugin = MockPluginDirectoryProvider.getPluginDirectoryEntry()
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try! encoder.encode(plugin)
        let decoded = try! decoder.decode(PluginDirectoryEntry.self, from: data)

        XCTAssertEqual(plugin.name, decoded.name)
        XCTAssertEqual(plugin.slug, decoded.slug)
        XCTAssertEqual(plugin.version, decoded.version)
        XCTAssertEqual(plugin.lastUpdated, decoded.lastUpdated)
        XCTAssertEqual(plugin.icon, decoded.icon)
        XCTAssertEqual(plugin.banner, decoded.banner)
        XCTAssertEqual(plugin.author, decoded.author)
        XCTAssertEqual(plugin.authorURL, decoded.authorURL)
        XCTAssertEqual(plugin.descriptionHTML, decoded.descriptionHTML)
        XCTAssertEqual(plugin.installationHTML, decoded.installationHTML)
        XCTAssertEqual(plugin.faqHTML, decoded.faqHTML)
        XCTAssertEqual(plugin.changelogHTML, decoded.changelogHTML)
        XCTAssertEqual(plugin.rating, decoded.rating)
    }

    func testPluginStateDirectoryEncodeNoThrow() {
        let plugin = MockPluginDirectoryProvider.getPluginDirectoryEntry()
        let encoder = JSONEncoder()

        do {
            XCTAssertNoThrow(try encoder.encode(plugin), "Could not encode plugin to Json")
            let data = try encoder.encode(plugin)
        } catch {
            XCTFail("Convert to JSON Failed")
        }
    }

    func testPluginDirectoryFeedTypeSlugReturn() {
        let pluginDirectoryFeedTypeNewest = PluginDirectoryFeedType.newest
        let pluginDirectoryFeedTypePopular = PluginDirectoryFeedType.popular
        let pluginDirectoryFeedTypeSearch = PluginDirectoryFeedType.search(term: "blocks")

        let expectedNewest = "newest"
        let expectedPopular = "popular"
        let expectedSearch = "search:blocks"

        XCTAssertEqual(pluginDirectoryFeedTypeNewest.slug, expectedNewest)
        XCTAssertEqual(pluginDirectoryFeedTypePopular.slug, expectedPopular)
        XCTAssertEqual(pluginDirectoryFeedTypeSearch.slug, expectedSearch)
    }

    func testPluginDirectoryFeedTypeEquatable() {
        let lhs = PluginDirectoryFeedType.newest
        let rhs = PluginDirectoryFeedType.newest

        XCTAssertTrue(lhs == rhs)
    }
}

