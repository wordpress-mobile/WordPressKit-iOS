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
    

    func testExtractHTMLTextOutput() {
        let plugin = pluginDirectoryEntryJetpack
        let expectedDescription = extractHTMLText(jetpackPluginDescriptionHTML)
        let expectedInstallationText = extractHTMLText(jetpackInstallationHTML)
        let expectedFAQText = extractHTMLText(jetpackFaqHTML)
        let expectedChangeLogText = extractHTMLText(jetpackChangeLogHTML)
        
        XCTAssertEqual(plugin.descriptionText, expectedDescription)
        XCTAssertEqual(plugin.installationText, expectedInstallationText)
        XCTAssertEqual(plugin.faqText, expectedFAQText)
        XCTAssertEqual(plugin.changelogText, expectedChangeLogText)
    }
    
    
    func testDirectoryEntryStarRatingOutput() {
        let plugin = pluginDirectoryEntryJetpack
        
        let starRating = plugin.starRating
        let expected: Double = 4.0
        
        XCTAssertEqual(starRating, expected)
    }
    
    func testTrimChangeLogReturnsFirstOccurence() {
        let jetpack = pluginDirectoryEntryJetpack
        let changeLog = jetpack.changelogHTML
        
        let firstOccurence = trimChangelog(changeLog)
        let expectation = jetpackChangeLogFirstOccurence
        
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
        let plugin = pluginDirectoryEntryJetpack
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
        let plugin = pluginDirectoryEntryJetpack
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

private let pluginDirectoryEntryJetpack = PluginDirectoryEntry(name: "Jetpack by WordPress.com",
                                                       slug: "jetpack",
                                                       version: "5.5.1",
                                                       lastUpdated: nil,
                                                       icon: URL(string: "https://ps.w.org/jetpack/assets/icon-256x256.png?rev=969908"),
                                                       banner: URL(string: "https://ps.w.org//jetpack//assets//banner-1544x500.png?rev=1791404"),
                                                       author: "Automattic",
                                                       authorURL: URL(string: "https://profiles.wordpress.org/automattic"),
                                                       descriptionHTML: jetpackPluginDescriptionHTML,
                                                       installationHTML: jetpackInstallationHTML,
                                                       faqHTML: jetpackFaqHTML,
                                                       changelogHTML: jetpackChangeLogHTML,
                                                       rating: 82)

private let jetpackPluginDescriptionHTML = "<p>Keep any WordPress site secure, increase traffic, and engage your readers.</p>\n<h4>Traffic and SEO Tools</h4>\n<p>Traffic is the lifeblood of any website. Jetpack includes:</p>\n<ul>\n<li>[free] Site stats and analytics</li>\n<li>[free] Automatic sharing on Facebook, Twitter, LinkedIn, Tumblr, Reddit, and WhatsApp</li>\n<li>[free] Related posts</li>\n<li>[paid] Search engine optimization tools for Google, Bing, Twitter, Facebook, and WordPress.com</li>\n<li>[paid] Advertising program that includes the best of AdSense, Facebook Ads, AOL, Amazon, Google AdX, and Yahoo</li>\n</ul>\n<h4>Security and Backup Services</h4>\n<p>Stop worrying about data loss, downtime, and hacking. Jetpack provides:</p>\n<ul>\n<li>[free] Brute force attack protection</li>\n<li>[free] Downtime and uptime monitoring</li>\n<li>[free] Secured logins and two-factor authentication</li>\n<li>[paid] Malware scanning, code scanning, and threat resolution</li>\n<li>[paid] Site backups, restores, and migrations</li>\n</ul>\n<h4>Content Creation</h4>\n<p>Add rich, beautifully-presented media &#8212; no graphic design expertise necessary:</p>\n<ul>\n<li>[free] A high-speed CDN for your images</li>\n<li>[free] Carousels, slideshows, and tiled galleries</li>\n<li>[free] Simple embeds from YouTube, Google Documents, Spotify and more</li>\n<li>[free] Sidebar customization including Facebook, Twitter, and RSS feeds</li>\n<li>[free] Extra sidebar widgets including blog stats, calendar, and author widgets</li>\n<li>[paid] High-speed, ad-free, and high-definition video hosting</li>\n</ul>\n<h4>Discussion and Community</h4>\n<p>Create a connection with your readers and keep them coming back to your site with:</p>\n<ul>\n<li>[free] Email subscriptions</li>\n<li>[free] Comment login with Facebook, Twitter, and Google</li>\n<li>[free] Fully-customizable contact forms</li>\n<li>[free] Infinite scroll for your posts</li>\n</ul>\n<h4>Expert Support</h4>\n<p>We have an entire team of Happiness Engineers ready to help you. Ask your questions in the support forum, or <a href=\"https://jetpack.com/contact-support\" rel=\"nofollow\">contact us directly</a>.</p>\n<h4>Paid Services</h4>\n<p>Most of Jetpack&#8217;s features and services are free. Jetpack also provides advanced security and backup services, video hosting, site monetization, priority support, and more SEO tools in three <a href=\"https://jetpack.com/pricing?from=wporg\" rel=\"nofollow\">simple and affordable plans</a>.</p>\n<h4>Get Started</h4>\n<p>Installation is free, quick, and easy. Set up <a href=\"https://jetpack.com/install?from=wporg\" rel=\"nofollow\">the free plan</a> in minutes.</p>\n"

private let jetpackInstallationHTML = "<h4>Automated Installation</h4>\n<p>Installation is free, quick, and easy. <a href=\"https://jetpack.com/install?from=wporg\" rel=\"nofollow\">Install Jetpack from our site</a> in minutes.</p>\n<h4>Manual Alternatives</h4>\n<p>Alternatively, install Jetpack via the plugin directory, or upload the files manually to your server and follow the on-screen instructions. If you need additional help <a href=\"https://jetpack.com/support/installing-jetpack/\" rel=\"nofollow\">read our detailed instructions</a>.</p>\n"

private let jetpackFaqHTML = "\n<h4>Installation Instructions</h4>\n<p>\n<h4>Automated Installation</h4>\n<p>Installation is free, quick, and easy. <a href=\"https://jetpack.com/install?from=wporg\" rel=\"nofollow\">Install Jetpack from our site</a> in minutes.</p>\n<h4>Manual Alternatives</h4>\n<p>Alternatively, install Jetpack via the plugin directory, or upload the files manually to your server and follow the on-screen instructions. If you need additional help <a href=\"https://jetpack.com/support/installing-jetpack/\" rel=\"nofollow\">read our detailed instructions</a>.</p>\n</p>\n<h4>Is Jetpack Free?</h4>\n<p>\n<p>Yes! Jetpack&#8217;s core features are and always will be free.</p>\n<p>These include: <a href=\"https://jetpack.com/features/traffic/site-stats\" rel=\"nofollow\">site stats</a>, a <a href=\"https://jetpack.com/features/writing/content-delivery-network/\" rel=\"nofollow\">high-speed CDN</a> for images, <a href=\"https://jetpack.com/features/traffic/related-posts\" rel=\"nofollow\">related posts</a>, <a href=\"https://jetpack.com/features/security/downtime-monitoring\" rel=\"nofollow\">downtime monitoring</a>, brute force <a href=\"https://jetpack.com/features/security/brute-force-attack-protection\" rel=\"nofollow\">attack protection</a>, <a href=\"https://jetpack.com/features/traffic/automatic-publishing/\" rel=\"nofollow\">automated sharing</a> to social networks, <a href=\"https://jetpack.com/features/writing/sidebar-customization/\" rel=\"nofollow\">sidebar customization</a>, and many more.</p>\n</p>\n<h4>Should I purchase a paid plan?</h4>\n<p>\n<p>Jetpack&#8217;s paid services include automated backups, security scanning, spam filtering, video hosting, site monetization, SEO tools, and priority support.</p>\n<p>If you&#8217;re interested in learning more about the extra layers of protection and advanced tools available, learn more about our <a href=\"https://jetpack.com/pricing?from=wporg\" rel=\"nofollow\">paid plans</a>.</p>\n</p>\n<h4>Why do I need a WordPress.com account?</h4>\n<p>\n<p>Since Jetpack and its services are provided and hosted by WordPress.com, a WordPress.com account is required for Jetpack to function.</p>\n</p>\n<h4>I already have a WordPress account, but Jetpack isn&#8217;t working. What&#8217;s going on?</h4>\n<p>\n<p>A WordPress.com account is different from the account you use to log into your self-hosted WordPress. If you can log into <a href=\"https://wordpress.com\" rel=\"nofollow\">WordPress.com</a>, then you already have a WordPress.com account. If you can&#8217;t, you can easily create one <a href=\"https://jetpack.com/install?from=wporg\" rel=\"nofollow\">during installation</a>.</p>\n</p>\n<h4>How do I view my stats?</h4>\n<p>\n<p>Once you&#8217;ve installed Jetpack your stats will be available on <a href=\"https://wordpress.com/stats\" rel=\"nofollow\">WordPress.com/Stats</a>, on the official <a href=\"https://apps.wordpress.com/mobile/\" rel=\"nofollow\">WordPress mobile apps</a>, and on your Jetpack dashboard.</p>\n</p>\n<h4>How do I contribute to Jetpack?</h4>\n<p>\n<p>There are opportunities for developers at all levels to contribute. <a href=\"https://jetpack.com/contribute\" rel=\"nofollow\">Learn more about contributing to Jetpack</a> or consider <a href=\"https://jetpack.com/beta\" rel=\"nofollow\">joining our beta program</a>.</p>\n</p>\n\n"

private let jetpackChangeLogHTML = "<h4>5.5.1</h4>\n<ul>\n<li>Release date: November 21, 2017</li>\n<li>Release post: https://wp.me/p1moTy-6Bd</li>\n</ul>\n<p><strong>Bug fixes</strong><br />\n* In Jetpack 5.5 we made some changes that created errors if you were using other plugins that added custom links to the Plugins menu. This is now fixed.<br />\n* We have fixed a problem that did not allow to upload plugins using API requests.<br />\n* Open Graph links in post headers are no longer invalid in some special cases.<br />\n* We fixed warnings happening when syncing users with WordPress.com.<br />\n* We updated the way the Google+ button is loaded to match changes made by Google, to ensure the button is always displayed properly.<br />\n* We fixed conflicts between Jetpack&#8217;s Responsive Videos and the updates made to Video players in WordPress 4.9.<br />\n* We updated Publicize&#8217;s message length to match Twitter&#8217;s new 280 character limit.</p>\n"

private let jetpackChangeLogFirstOccurence = ">5.5.1</h4>\n<ul>\n<li>Release date: November 21, 2017</li>\n<li>Release post: https://wp.me/p1moTy-6Bd</li>\n</ul>\n<p><strong>Bug fixes</strong><br />\n* In Jetpack 5.5 we made some changes that created errors if you were using other plugins that added custom links to the Plugins menu. This is now fixed.<br />\n* We have fixed a problem that did not allow to upload plugins using API requests.<br />\n* Open Graph links in post headers are no longer invalid in some special cases.<br />\n* We fixed warnings happening when syncing users with WordPress.com.<br />\n* We updated the way the Google+ button is loaded to match changes made by Google, to ensure the button is always displayed properly.<br />\n* We fixed conflicts between Jetpack&#8217;s Responsive Videos and the updates made to Video players in WordPress 4.9.<br />\n* We updated Publicize&#8217;s message length to match Twitter&#8217;s new 280 character limit.</p>\n"
