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
    
    func testPluginFeedPageDirectoryEquatable() {
        let popularFeedMockPath = Bundle(for: type(of: self)).path(forResource: "plugin-directory-popular", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: popularFeedMockPath))
        let endpoint = PluginDirectoryFeedEndpoint(feedType: .popular)
        
        do {
            let response = try endpoint.parseResponse(data: data)
            let sameResponse = try endpoint.parseResponse(data: data)
            XCTAssertTrue(response == sameResponse)
        } catch {
            XCTFail("Equal Equatable check failed")
        }
    }
    
    func testPluginFeedPageDirectoryNotEquatable() {
        let popularFeedMockPath = Bundle(for: type(of: self)).path(forResource: "plugin-directory-popular", ofType: "json")!
        let popularData = try! Data(contentsOf: URL(fileURLWithPath: popularFeedMockPath))
        let popularEndpoint = PluginDirectoryFeedEndpoint(feedType: .popular)
        let newFeedMockPath = Bundle(for: type(of: self)).path(forResource: "plugin-directory-new", ofType: "json")!
        let newData = try! Data(contentsOf: URL(fileURLWithPath: newFeedMockPath))
        let neWEndpoint = PluginDirectoryFeedEndpoint(feedType: .newest)
        
        do {
            let popularResponse = try popularEndpoint.parseResponse(data: popularData)
            let newResponse = try neWEndpoint.parseResponse(data: newData)
            XCTAssertFalse(popularResponse == newResponse)
        } catch {
            XCTFail("Equal Equatable check failed")
        }
    }
    
    func testDescriptionTextVariableReturnsConvertedHTML() {
        //Not very good... return to this one after thinking about it
        let jetpack = getJetpackPluginDirectoryEntry()
        
        let descriptionText = jetpack.descriptionText!.attributedSubstring(from: NSRange(location: 0, length: 74))
        
        let expected = NSAttributedString(string: "Keep any WordPress site secure, increase traffic, and engage your readers.")
        
        XCTAssertEqual(descriptionText.string, expected.string)
    
    }
    
    func testDirectoryEntryStarRatingOutput() {
        let jetpack = getJetpackPluginDirectoryEntry()
        
        let expected: Double = 4.0
        
        XCTAssertEqual(jetpack.starRating, expected)
    }
    
    func testTrimChangeLogReturnsFirstOccurence() {
        let jetpack = getJetpackPluginDirectoryEntry()
        let changeLog = jetpack.changelogHTML
        
        let firstOccurence = trimChangelog(changeLog)
        
        XCTAssertNotEqual(firstOccurence, ">5.5.1</h4>\n<ul>\n<li>Release date: November 21, 2017</li>\n<li>Release post: https://wp.me/p1moTy-6Bd</li>\n</ul>\n<p><strong>Bug fixes</strong><br />\n* In Jetpack 5.5 we made some changes that created errors if you were using other plugins that added custom links to the Plugins menu. This is now fixed.<br />\n* We have fixed a problem that did not allow to upload plugins using API requests.<br />\n* Open Graph links in post headers are no longer invalid in some special cases.<br />\n* We fixed warnings happening when syncing users with WordPress.com.<br />\n* We updated the way the Google+ button is loaded to match changes made by Google, to ensure the button is always displayed properly.<br />\n* We fixed conflicts between Jetpack&#8217;s Responsive Videos and the updates made to Video players in WordPress 4.9.<br />\n* We updated Publicize&#8217;s message length to match Twitter&#8217;s new 280 character limit.</p>\n")
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
        let jetpackPlugin = getJetpackPluginDirectoryEntry()
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try! encoder.encode(jetpackPlugin)
        let decoded = try! decoder.decode(PluginDirectoryEntry.self, from: data)
        
        XCTAssertEqual(jetpackPlugin.name, decoded.name)
        XCTAssertEqual(jetpackPlugin.slug, decoded.slug)
        XCTAssertEqual(jetpackPlugin.version, decoded.version)
        XCTAssertEqual(jetpackPlugin.lastUpdated, decoded.lastUpdated)
        XCTAssertEqual(jetpackPlugin.icon, decoded.icon)
        XCTAssertEqual(jetpackPlugin.banner, decoded.banner)
        XCTAssertEqual(jetpackPlugin.author, decoded.author)
        XCTAssertEqual(jetpackPlugin.authorURL, decoded.authorURL)
        XCTAssertEqual(jetpackPlugin.descriptionHTML, decoded.descriptionHTML)
        XCTAssertEqual(jetpackPlugin.installationHTML, decoded.installationHTML)
        XCTAssertEqual(jetpackPlugin.faqHTML, decoded.faqHTML)
        XCTAssertEqual(jetpackPlugin.changelogHTML, decoded.changelogHTML)
        XCTAssertEqual(jetpackPlugin.rating, decoded.rating)
        
    }
}

extension PluginDirectoryTests {
    func getJetpackPluginDirectoryEntry() -> PluginDirectoryEntry {
        var plugin: PluginDirectoryEntry!
        
        let jetpackMockPath = Bundle(for: type(of: self)).path(forResource: "plugin-directory-jetpack", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: jetpackMockPath))
        let endpoint = PluginDirectoryGetInformationEndpoint(slug: "jetpack")

        do {
            plugin = try endpoint.parseResponse(data: data)
        } catch {
            print("Couldn't decode Plugin \(error)")
        }
        
        return plugin
    }
}
