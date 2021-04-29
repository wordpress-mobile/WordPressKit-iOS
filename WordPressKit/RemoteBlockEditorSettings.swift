import Foundation

public class RemoteBlockEditorSettings: Codable {
    enum CodingKeys: String, CodingKey {
        case isFSETheme = "__unstableEnableFullSiteEditingBlocks"
        case globalStylesBaseStyles = "__experimentalGlobalStylesBaseStyles"
        case colors
        case gradients
    }

    let isFSETheme: Bool
    let globalStylesBaseStyles: GlobalStylesBaseStyles?
    let colors: [RemoteColor]?
    let gradients: [RemoteGradient]?

    lazy var checksum: String = {
        return ChecksumUtil.checksum(from: self)
    }()

    required public init(from decoder: Decoder) throws {
        let map = try decoder.container(keyedBy: CodingKeys.self)
        self.isFSETheme = (try? map.decode(Bool.self, forKey: .isFSETheme)) ?? false
        self.globalStylesBaseStyles = try? map.decode(GlobalStylesBaseStyles.self, forKey: .globalStylesBaseStyles)
        self.colors = try? map.decode([RemoteColor].self, forKey: .colors)
        self.gradients = try? map.decode([RemoteGradient].self, forKey: .gradients)
    }
}

public struct GlobalStylesBaseStyles: Codable {
    enum CodingKeys: String, CodingKey {
        case colorSettings = "color"
    }

    let colorSettings: GlobalStylesColorSettings
}

public struct GlobalStylesColorSettings: Codable {
    enum CodingKeys: String, CodingKey {
        case colors = "palette"
        case gradients
    }

    let colors: [RemoteColor]?
    let gradients: [RemoteGradient]?

    public init(from decoder: Decoder) throws {
        let map = try decoder.container(keyedBy: CodingKeys.self)
        self.colors = try? map.decode([RemoteColor].self, forKey: .colors)
        self.gradients = try? map.decode([RemoteGradient].self, forKey: .gradients)
    }
}

// MARK: EditorTheme
public class RemoteEditorTheme: Codable {
    enum CodingKeys: String, CodingKey {
        case themeSupport = "theme_supports"
    }

    let themeSupport: RemoteEditorThemeSupport?
    lazy var checksum: String = {
        return ChecksumUtil.checksum(from: themeSupport)
    }()
}

public struct RemoteEditorThemeSupport: Codable {
    enum CodingKeys: String, CodingKey {
        case colors = "editor-color-palette"
        case gradients = "editor-gradient-presets"
    }

    let colors: [RemoteColor]?
    let gradients: [RemoteGradient]?

    public init(from decoder: Decoder) throws {
        let map = try decoder.container(keyedBy: CodingKeys.self)
        self.colors = try? map.decode([RemoteColor].self, forKey: .colors)
        self.gradients = try? map.decode([RemoteGradient].self, forKey: .gradients)
    }
}

// MARK: Common Objects

public struct RemoteColor: Codable {
    let slug: String
    let color: String
    let name: String
}

public struct RemoteGradient: Codable {
    let slug: String
    let gradient: String
    let name: String
}
