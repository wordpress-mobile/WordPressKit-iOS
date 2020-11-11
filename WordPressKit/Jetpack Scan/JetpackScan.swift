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
    var isEnabled: Bool = false

    /// The state of the current scan
    var state: JetpackScanState = .idle

    /// If there is a scan in progress, this will return its status
    var current: JetpackScanStatus? = nil

    /// Scan Status for the most recent scan
    /// This will be nil if there is currently a scan taking place
    var mostRecent: JetpackScanStatus? = nil

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let stateString = try container.decode(String.self, forKey: .state)
        state = JetpackScanState(rawValue: stateString) ?? .unknown
        isEnabled = (state != .unavailable) && (state != .unknown)

        current = try? container.decode(JetpackScanStatus.self, forKey: .current)
        mostRecent = try? container.decode(JetpackScanStatus.self, forKey: .mostRecent)
    }

    // MARK: - Private: Decoable
    private enum CodingKeys: String, CodingKey {
        case isEnabled = "has_cloud"
        case state
        case current
        case mostRecent = "most_recent"
        case unknown
    }
}

// MARK: - JetpackScanStatus
public struct JetpackScanStatus: Decodable {
    var isInitial: Bool = false

    /// The date the scan started
    var startDate: Date? = nil

    /// The progress of the scan from 0 - 100
    var progress: Int

    /// How long the scan took / is taking
    var duration: TimeInterval? = nil

    /// If there was an error finishing the scan
    /// This will only be available for past scans
    var error: Bool?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        isInitial = try container.decode(Bool.self, forKey: .isInitial)
        progress = try container.decode(Int.self, forKey: .progress)

        let dateString = try container.decode(String.self, forKey: .timestamp)
        startDate = dateFormatter.date(from: dateString)

        duration = try? container.decode(TimeInterval.self, forKey: .duration)

        if duration == nil, let date = startDate {
            duration = NSDate().timeIntervalSince(date)
        }

        error = try? container.decode(Bool.self, forKey: .error)
    }

    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter
    }

    // MARK: - Private: Decoable
    private enum CodingKeys: String, CodingKey {
        case isInitial = "is_initial"
        case timestamp
        case duration
        case progress
        case error
    }
}
