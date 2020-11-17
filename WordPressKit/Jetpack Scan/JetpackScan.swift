import Foundation

public struct JetpackScan: Decodable {
    public enum JetpackScanState: String {
        case idle
        case scanning
        case unavailable
        case provisioning
        case unknown
    }

    /// Whether the scan feature is available or not
    public var isEnabled: Bool = false

    /// The state of the current scan
    public var state: JetpackScanState = .idle

    /// If there is a scan in progress, this will return its status
    public var current: JetpackScanStatus? = nil

    /// Scan Status for the most recent scan
    /// This will be nil if there is currently a scan taking place
    public var mostRecent: JetpackScanStatus? = nil

    /// An array of the current threats
    /// During a scan this will return the previous scans threats
    public var threats: [JetpackScanThreat]? = nil

    /// A limited representation of the users credientals for each role
    public var credentials: [JetpackScanCredentials]? = nil

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let stateString = try container.decode(String.self, forKey: .state)
        state = JetpackScanState(rawValue: stateString) ?? .unknown
        isEnabled = (state != .unavailable) && (state != .unknown)

        current = try? container.decode(JetpackScanStatus.self, forKey: .current)
        mostRecent = try? container.decode(JetpackScanStatus.self, forKey: .mostRecent)
        threats = try? container.decode([JetpackScanThreat].self, forKey: .threats)
        credentials = try? container.decode([JetpackScanCredentials].self, forKey: .credentials)
    }

    // MARK: - Private: Decodable
    private enum CodingKeys: String, CodingKey {
        case isEnabled = "has_cloud"
        case state
        case current
        case mostRecent = "most_recent"
        case threats
        case credentials
    }
}

// MARK: - JetpackScanStatus
public struct JetpackScanStatus: Decodable {
    public var isInitial: Bool = false

    /// The date the scan started
    public var startDate: Date? = nil

    /// The progress of the scan from 0 - 100
    public var progress: Int

    /// How long the scan took / is taking
    public var duration: TimeInterval? = nil

    /// If there was an error finishing the scan
    /// This will only be available for past scans
    public var error: Bool?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        isInitial = try container.decode(Bool.self, forKey: .isInitial)
        progress = try container.decode(Int.self, forKey: .progress)
        startDate = try container.decode(ISO8601Date.self, forKey: .timestamp)
        duration = try container.decodeIfPresent(TimeInterval.self, forKey: .duration)

        if duration == nil, let date = startDate {
            duration = NSDate().timeIntervalSince(date)
        }

        error = try? container.decode(Bool.self, forKey: .error)
    }

    private enum CodingKeys: String, CodingKey {
        case isInitial = "is_initial"
        case timestamp
        case duration
        case progress
        case error
    }
}
