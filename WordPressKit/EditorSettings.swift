private struct RemoteEditorSettings: Codable {
    let editorMobile: String
    let editorWeb: String
}

public struct EditorSettings {
    public enum Mobile: String {
        case gutenberg
        case aztec
        static let `default` = Mobile.aztec
    }

    public enum Web: String {
        case classic
        case gutenberg
        static let `default` = Web.classic
    }

    let mobile: Mobile
    let web: Web
}

extension EditorSettings {
    init(with response: AnyObject) throws {
        guard let response = response as? [String: AnyObject] else {
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: nil)
        }

        let data = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
        let editorPreferenesRemote = try JSONDecoder.apiDecoder.decode(RemoteEditorSettings.self, from: data)
        self.init(with: editorPreferenesRemote)
    }

    private init(with remote: RemoteEditorSettings) {
        let mobile = Mobile(rawValue: remote.editorMobile) ?? .default
        let web = Web(rawValue: remote.editorWeb) ?? .default
        self = EditorSettings(mobile: mobile, web: web)
    }
}
