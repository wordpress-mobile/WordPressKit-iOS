import Foundation

public struct JetpackScanThreat: Decodable {
    public enum ThreatStatus: String {
        case fixed
        case ignored
        case current

        case unknown
    }

    public enum ThreatType: String {
        case core
        case file
        case plugin
        case theme
        case database

        case unknown

        init?(threat: JetpackScanThreat) {
            // Logic used from https://github.com/Automattic/wp-calypso/blob/5a6b257ad97b361fa6f6a6e496cbfc0ef952b921/client/components/jetpack/threat-item/utils.ts#L11
            if threat.diff != nil {
                self = .core
            }

            if threat.context != nil {
                self =  .file
            }

            if let ext = threat.extension {
                self = ThreatType(rawValue: ext.type.rawValue) ?? .unknown
            }

            if threat.rows != nil || threat.signature.contains(Constants.databaseSignature) {
                self = .database
            }

            return nil
        }

        private struct Constants {
            static let databaseSignature = "Suspicious.Links"
        }
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

    /// The type of threat this is
    var type: ThreatType

    /// If this is a file based threat this will provide code context to be displayed
    /// Context example:
    /// 3: start test
    /// 4: VIRUS_SIG
    /// 5: end test
    /// marks: 4: (0, 9)
    var context: JetpackThreatContext? = nil

    // Core modification threats will contain a git diff string
    var diff: String? = nil

    // Database threats will contain row information
    var rows: [String: Any]? = nil

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Define a placeholder type
        type = .unknown

        id = try container.decode(Int.self, forKey: .id)
        signature = try container.decode(String.self, forKey: .signature)
        fileName = try container.decode(String.self, forKey: .fileName)
        description = try container.decode(String.self, forKey: .description)
        firstDetected = try container.decode(ISO8601Date.self, forKey: .firstDetected)
        fixedOn = try? container.decode(ISO8601Date.self, forKey: .fixedOn)
        fixable = try? container.decode(JetpackScanThreatFixer.self, forKey: .fixable)
        `extension` = try? container.decode(JetpackThreatExtension.self, forKey: .extension)
        diff = try? container.decode(String.self, forKey: .diff)
        rows = try? container.decode([String: Any].self, forKey: .rows)

        let statusString = try container.decode(String.self, forKey: .status)
        status = ThreatStatus(rawValue: statusString) ?? .unknown

        // Context obj can either be:
        // - not present
        // - a dictionary
        // - an empty string
        // we can not just set to nil because the threat type logic needs to know if the
        // context attr was present or not
        if let contextDict = try? container.decode([String: Any].self, forKey: .context) {
            context = JetpackThreatContext(with: contextDict)
        } else if let contextString = try? container.decode(String.self, forKey: .context) {
            context = JetpackThreatContext.emptyObject()
        }

        // Calculate the type of threat last
        type = ThreatType(threat: self) ?? .unknown
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case signature
        case description
        case fileName = "filename"
        case firstDetected = "first_detected"
        case fixable
        case `extension`
        case diff
        case context
        case rows
        case status
        case fixedOn = "fixed_on"
    }
}

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

public struct JetpackThreatContext {
    public struct ThreatContextLine {
        var lineNumber: Int
        var contents: String
        var highlights: [NSRange]? = nil
    }

    let lines: [ThreatContextLine]

    public static func emptyObject() -> JetpackThreatContext {
        return JetpackThreatContext(with: [])
    }

    public init(with lines: [ThreatContextLine]) {
        self.lines = lines
    }

    public init?(with dict: [String: Any]){
        guard let marksDict = dict["marks"] as? [String: Any] else {
            return nil
        }

        var lines: [ThreatContextLine] = []

        // Parse the "lines" which are represented as the keys of the dict
        // "3", "4", "5"
        for key in dict.keys {
            // Since we've already pulled the marks out above, ignore it here
            if key == "marks" {
                continue
            }

            // Validate the incoming object to make sure it contains an integer line, and
            // the string contents
            guard let lineNum = Int(key), let contents = dict[key] as? String else {
                continue
            }

            let highlights: [NSRange]? = Self.highlights(with: marksDict, for: key)

            let context = ThreatContextLine(lineNumber: lineNum,
                                            contents: contents,
                                            highlights: highlights)

            lines.append(context)
        }

        // Since the dictionary keys are unsorted, resort by line number
        self.lines =  lines.sorted { $0.lineNumber < $1.lineNumber }
    }


    /// Parses the marks dictionary and converts them to an array of NSRange's
    private static func highlights(with dict: [String: Any], for key: String) -> [NSRange]? {
        guard let marks = dict[key] as? [[Double]] else {
            return nil
        }

        var highlights: [NSRange] = []

        for rangeArray in marks {
            if let range = Self.range(with: rangeArray) {
                highlights.append(range)
            }
        }

        return (highlights.count > 0) ? highlights : nil
    }

    /// Generates an NSRange from an array
    /// - Parameter array: An array that contains 2 numbers [start, length]
    /// - Returns: Nil if the array fails validation, or an NSRange
    private static func range(with array: [Double]) -> NSRange? {
        guard array.count == 2,
              let location = array.first,
              let length = array.last
        else {
            return nil
        }

        return NSRange(location: Int(location), length: Int(length))
    }
}
