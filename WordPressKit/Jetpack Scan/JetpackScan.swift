import Foundation

public struct JetpackScan: Decodable {
    public enum JetpackScanState: String, Decodable {
        case idle
        case scanning
        case unavailable
        case provisioning
        
        case unknown
    }

    /// Whether the scan feature is available or not
    public var isEnabled: Bool = false

    /// The state of the current scan
    public var state: JetpackScanState

    /// If there is a scan in progress, this will return its status
    public var current: JetpackScanStatus?

    /// Scan Status for the most recent scan
    /// This will be nil if there is currently a scan taking place
    public var mostRecent: JetpackScanStatus?

    /// An array of the current threats
    /// During a scan this will return the previous scans threats
    public var threats: [JetpackScanThreat]?

    /// A limited representation of the users credientals for each role
    public var credentials: [JetpackScanCredentials]?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        state = (try? container.decode(JetpackScanState.self, forKey: .state)) ?? .unknown
        isEnabled = (state != .unavailable) && (state != .unknown)
        current = try? container.decode(JetpackScanStatus.self, forKey: .current)
        mostRecent = try? container.decode(JetpackScanStatus.self, forKey: .mostRecent)
        threats = try? container.decode([JetpackScanThreat].self, forKey: .threats)
        credentials = try? container.decode([JetpackScanCredentials].self, forKey: .credentials)
    }

    // MARK: - Private: Decodable
    private enum CodingKeys: String, CodingKey {
        case isEnabled = "has_cloud"
        case mostRecent = "most_recent"

        case state, current, threats, credentials
    }
}

// MARK: - JetpackScanStatus
public struct JetpackScanStatus: Decodable {
    public var isInitial: Bool

    /// The date the scan started
    public var startDate: Date?

    /// The progress of the scan from 0 - 100
    public var progress: Int

    /// How long the scan took / is taking
    public var duration: TimeInterval?

    /// If there was an error finishing the scan
    /// This will only be available for past scans
    public var error: Bool?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        isInitial = try container.decode(Bool.self, forKey: .isInitial)
        progress = try container.decode(Int.self, forKey: .progress)
        startDate = try container.decode(ISO8601Date.self, forKey: .timestamp)
        duration = try container.decodeIfPresent(TimeInterval.self, forKey: .duration)
        error = try? container.decode(Bool.self, forKey: .error)

        // Scans that are in progress don't have a duration field,
        // calculate how long the scan has been in progress using the start date if available
        if duration == nil, let date = startDate {
            duration = Date().timeIntervalSince(date)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case isInitial = "is_initial"
        case timestamp, duration, progress, error
    }
}
