import Foundation

protocol InfoDictionaryObjectProvider {
    func object(forInfoDictionaryKey key: String) -> Any?
}

extension Bundle: InfoDictionaryObjectProvider {

}

struct AppTransportSecuritySettings {

    private let infoDictionaryObjectProvider: InfoDictionaryObjectProvider

    private var settings: NSDictionary? {
        infoDictionaryObjectProvider.object(forInfoDictionaryKey: "NSAppTransportSecurity") as? NSDictionary
    }

    private var exceptionDomains: NSDictionary? {
        settings?["NSExceptionDomains"] as? NSDictionary
    }

    init(_ infoDictionaryObjectProvider: InfoDictionaryObjectProvider = Bundle.main) {
        self.infoDictionaryObjectProvider = infoDictionaryObjectProvider
    }

    func secureAccessOnly(for siteURL: URL) -> Bool {
        if let exceptionDomain = self.exceptionDomain(for: siteURL) {
            let allowsInsecureHTTPLoads =
                exceptionDomain["NSExceptionAllowsInsecureHTTPLoads"] as? Bool ?? false
            return !allowsInsecureHTTPLoads
        }

        guard let settings = settings else {
            return true
        }

        // From Apple: The value of the `NSAllowsArbitraryLoads` key is ignored—and the default value of
        // NO used instead—if any of the following keys are present:
        guard settings["NSAllowsLocalNetworking"] == nil &&
                settings["NSAllowsArbitraryLoadsForMedia"] == nil &&
                settings["NSAllowsArbitraryLoadsInWebContent"] == nil else {
            return true
        }

        let allowsArbitraryLoads = settings["NSAllowsArbitraryLoads"] as? Bool ?? false
        return !allowsArbitraryLoads
    }

    private func exceptionDomain(for siteURL: URL) -> NSDictionary? {
        guard let domain = siteURL.host?.lowercased() else {
            return nil
        }

        return exceptionDomains?[domain] as? NSDictionary
    }
}
