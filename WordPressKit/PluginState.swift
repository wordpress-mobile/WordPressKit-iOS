import Foundation

public struct PluginState: Equatable, Codable {
    public enum UpdateState: Equatable, Codable {
        public static func ==(lhs: PluginState.UpdateState, rhs: PluginState.UpdateState) -> Bool {
            switch (lhs, rhs) {
            case (.updated, .updated):
                return true
            case (.available(let lhsValue), .available(let rhsValue)):
                return lhsValue == rhsValue
            case (.updating(let lhsValue), .updating(let rhsValue)):
                return lhsValue == rhsValue
            default:
                return false
            }
        }

        private enum CodingKeys: String, CodingKey {
            case updated
            case available
            case updating
        }

        case updated
        case available(String)
        case updating(String)

        public func encode(to encoder: Encoder) throws {
            var encoder = encoder.container(keyedBy: CodingKeys.self)

            switch self {
            case .updated:
                try encoder.encode(true, forKey: .updated)
            case .available(let value):
                try encoder.encode(value, forKey: .available)
            case .updating(let value):
                try encoder.encode(value, forKey: .updating)
            }
        }

        public init(from decoder: Decoder) throws {
            let decoder = try decoder.container(keyedBy: CodingKeys.self)

            if let _ = try decoder.decodeIfPresent(Bool.self, forKey: .updated) {
                self = .updated
                return
            }

            if let value = try decoder.decodeIfPresent(String.self, forKey: .available) {
                self = .available(value)
                return
            }

            if let value = try decoder.decodeIfPresent(String.self, forKey: .updating) {
                self = .updating(value)
                return
            }

            self = .updated
        }
    }

    public let id: String
    public let slug: String
    public var active: Bool
    public let name: String
    public let author: String
    public let version: String?
    public var updateState: UpdateState
    public var autoupdate: Bool
    public var automanaged: Bool
    public let url: URL?
    public let settingsURL: URL?

    public init(id: String, slug: String, active: Bool, name: String, author: String, version: String?, updateState: PluginState.UpdateState, autoupdate: Bool, automanaged: Bool, url: URL?, settingsURL: URL?) {
        self.id = id
        self.slug = slug
        self.active = active
        self.name = name
        self.author = author
        self.version = version
        self.updateState = updateState
        self.autoupdate = autoupdate
        self.automanaged = automanaged
        self.url = url
        self.settingsURL = settingsURL
    }

    public static func ==(lhs: PluginState, rhs: PluginState) -> Bool {
        return lhs.id == rhs.id
            && lhs.slug == rhs.slug
            && lhs.active == rhs.active
            && lhs.name == rhs.name
            && lhs.version == rhs.version
            && lhs.updateState == rhs.updateState
            && lhs.autoupdate == rhs.autoupdate
            && lhs.automanaged == rhs.automanaged
            && lhs.url == rhs.url
    }
}

public extension PluginState {
    var stateDescription: String {
        if automanaged {
            return NSLocalizedString("Auto-managed on this site", comment: "The plugin can not be manually updated or deactivated")
        }
        switch (active, autoupdate) {
        case (false, false):
            return NSLocalizedString("Inactive, Autoupdates off", comment: "The plugin is not active on the site and has not enabled automatic updates")
        case (false, true):
            return NSLocalizedString("Inactive, Autoupdates on", comment: "The plugin is not active on the site and has enabled automatic updates")
        case (true, false):
            return NSLocalizedString("Active, Autoupdates off", comment: "The plugin is active on the site and has not enabled automatic updates")
        case (true, true):
            return NSLocalizedString("Active, Autoupdates on", comment: "The plugin is active on the site and has enabled automatic updates")
        }
    }

    var homeURL: URL? {
        return url
    }

    var directoryURL: URL? {
        return URL(string: "https://wordpress.org/plugins/\(slug)")
    }

    var deactivateAllowed: Bool {
        return !isJetpack && !automanaged
    }

    var isJetpack: Bool {
        return slug == "jetpack"
            || slug == "jetpack-dev"
    }
}
