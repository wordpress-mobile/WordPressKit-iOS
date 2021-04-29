import Foundation

public class RemoteBlockEditorSettings: Codable {
    enum CodingKeys: String, CodingKey {
        case isFSETheme = "__unstableEnableFullSiteEditingBlocks"
        case globalStylesBaseStyles = "__experimentalGlobalStylesBaseStyles"
        case colors
        case gradients
    }

    public let isFSETheme: Bool
    public let globalStylesBaseStyles: GlobalStylesBaseStyles?
    public let colors: [[String: String]]?
    public let gradients: [[String: String]]?

    public lazy var checksum: String = {
        return ChecksumUtil.checksum(from: self)
    }()

    required public init(from decoder: Decoder) throws {
        let map = try decoder.container(keyedBy: CodingKeys.self)
        self.isFSETheme = (try? map.decode(Bool.self, forKey: .isFSETheme)) ?? false
        self.globalStylesBaseStyles = try? map.decode(GlobalStylesBaseStyles.self, forKey: .globalStylesBaseStyles)
        self.colors = try? map.decode([[String: String]].self, forKey: .colors)
        self.gradients = try? map.decode([[String: String]].self, forKey: .gradients)
    }
}

public struct GlobalStylesBaseStyles: Codable {
    enum CodingKeys: String, CodingKey {
        case colorSettings = "color"
    }

    public let colorSettings: GlobalStylesColorSettings
}

public struct GlobalStylesColorSettings: Codable {
    enum CodingKeys: String, CodingKey {
        case colors = "palette"
        case gradients
    }

    public let colors: [[String: String]]?
    public let gradients: [[String: String]]?

    public init(from decoder: Decoder) throws {
        let map = try decoder.container(keyedBy: CodingKeys.self)
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
