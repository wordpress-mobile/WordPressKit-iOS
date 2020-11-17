import Foundation

public struct JetpackScanThreat: Decodable {
    public enum ThreatStatus: String {
        case fixed
        case ignored
        case current
    }

    /// The ID of the threat
    var id: Int

    /// The name of the threat signature
    var signature: String

    /// The description of the threat signature
    var description: String

    /// The date the threat was first detected
    var firstDetected: Date

    /// Whether the threat can be automatically fixed
    var fixable: JetpackScanThreatFixer? = nil

    /// The filename
    var fileName: String? = nil

    /// The status of the threat (fixed, ignored, current)
    var status: ThreatStatus? = nil

    /// The date the threat was fixed on
    var fixedOn: Date? = nil

    /// More information if the threat is a extension type (plugin or theme)
    var `extension`: JetpackThreatExtension? = nil

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        type = .unknown
        id = try container.decode(Int.self, forKey: .id)
        signature = try container.decode(String.self, forKey: .signature)
        description = try container.decode(String.self, forKey: .description)
        firstDetected = try container.decode(ISO8601Date.self, forKey: .firstDetected)
        signature = try container.decode(String.self, forKey: .signature)
        fixable = try? container.decode(JetpackScanThreatFixer.self, forKey: .fixable)
        `extension` = try? container.decode(JetpackThreatExtension.self, forKey: .extension)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case signature
        case description
        case firstDetected = "first_detected"
        case fixable
        case `extension`
/// An object that describes how a threat can be fixed
public struct JetpackScanThreatFixer: Decodable {
    public enum ThreatFixType: String {
        case replace
        case delete
        case update
        case edit

        case unknown
    }

    /// The suggested threat fix type
    var type: ThreatFixType

    /// The file path of the file to be fixed
    var file: String? = nil

    /// The target version to fix to
    var target: String? = nil

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let typeString = try container.decode(String.self, forKey: .type)
        type = ThreatFixType(rawValue: typeString) ?? .unknown

        file = try? container.decode(String.self, forKey: .file)
        target = try? container.decode(String.self, forKey: .target)
    }

    private enum CodingKeys: String, CodingKey {
        case type = "fixer"
        case file
        case target
    }
}

/// Represents plugin or theme additional metadata
public struct JetpackThreatExtension: Decodable {
    public enum JetpackThreatExtensionType: String {
        case plugin
        case theme

        case unknown
    }

    var slug: String
    var name: String
    var type: JetpackThreatExtensionType
    var isPremium: Bool = false
    var version: String

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        slug = try container.decode(String.self, forKey: .slug)
        name = try container.decode(String.self, forKey: .name)
        version = try container.decode(String.self, forKey: .version)
        isPremium = try container.decode(Bool.self, forKey: .isPremium)
        
        let typeString = try container.decode(String.self, forKey: .type)
        type = JetpackThreatExtensionType(rawValue: typeString) ?? .unknown
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case slug
        case name
        case version
        case isPremium
    }
}
    }
}
