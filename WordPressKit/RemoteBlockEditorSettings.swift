import Foundation

public class RemoteBlockEditorSettings: Codable {
    enum CodingKeys: String, CodingKey {
        case isFSETheme = "__unstableEnableFullSiteEditingBlocks"
        case rawGlobalStylesBaseStyles = "__experimentalGlobalStylesBaseStyles"
        case colors
        case gradients
    }

    public let isFSETheme: Bool
    public let rawGlobalStylesBaseStyles: String?
    public let colors: [[String: String]]?
    public let gradients: [[String: String]]?

    public lazy var checksum: String = {
        return ChecksumUtil.checksum(from: self)
    }()

    required public init(from decoder: Decoder) throws {
        let map = try decoder.container(keyedBy: CodingKeys.self)
        self.isFSETheme = (try? map.decode(Bool.self, forKey: .isFSETheme)) ?? false
        self.rawGlobalStylesBaseStyles = {
            // Swift cuurently doesn't support type conversions from Dictionaries to strings while decoding. So we need to
            // parse the reponse then convert it to a string.
            guard
                let jsonGlobalStylesBaseStyles = try? map.decode([String: Any].self, forKey: .rawGlobalStylesBaseStyles),
                let data = try? JSONSerialization.data(withJSONObject: jsonGlobalStylesBaseStyles, options: [.sortedKeys])
            else {
                return nil
            }
            return String(data: data, encoding: .utf8)
        }()
        self.colors = try? map.decode([[String: String]].self, forKey: .colors)
        self.gradients = try? map.decode([[String: String]].self, forKey: .gradients)
    }
}

// MARK: EditorTheme
public class RemoteEditorTheme: Codable {
    enum CodingKeys: String, CodingKey {
        case themeSupport = "theme_supports"
    }

    public let themeSupport: RemoteEditorThemeSupport?
    public lazy var checksum: String = {
        return ChecksumUtil.checksum(from: themeSupport)
    }()
}

public struct RemoteEditorThemeSupport: Codable {
    enum CodingKeys: String, CodingKey {
        case colors = "editor-color-palette"
        case gradients = "editor-gradient-presets"
    }

    public let colors: [[String: String]]?
    public let gradients: [[String: String]]?

    public init(from decoder: Decoder) throws {
        let map = try decoder.container(keyedBy: CodingKeys.self)
        self.colors = try? map.decode([[String: String]].self, forKey: .colors)
        self.gradients = try? map.decode([[String: String]].self, forKey: .gradients)
    }
}
