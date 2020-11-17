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


    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        type = .unknown
        id = try container.decode(Int.self, forKey: .id)
        signature = try container.decode(String.self, forKey: .signature)
        description = try container.decode(String.self, forKey: .description)
        firstDetected = try container.decode(ISO8601Date.self, forKey: .firstDetected)
        signature = try container.decode(String.self, forKey: .signature)
        fixable = try? container.decode(JetpackScanThreatFixer.self, forKey: .fixable)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case signature
        case description
        case firstDetected = "first_detected"
        case fixable
    }
}
