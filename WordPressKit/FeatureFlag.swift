import Foundation

public struct FeatureFlag {
    let title: String
    let value: Bool
}

// Codable Conformance is used to create mock objects in testing
extension FeatureFlag: Codable {

    struct DynamicKey: CodingKey {
        var stringValue: String
        init(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int?

        init(intValue: Int) {
            self.intValue = intValue
            self.stringValue = "\(intValue)"
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicKey.self)
        try container.encode(self.value, forKey: DynamicKey(stringValue: self.title))
    }
}

// Equatable Conformance is used to compare mock objects in testing
extension FeatureFlag: Equatable {}

public typealias FeatureFlagList = [FeatureFlag]
