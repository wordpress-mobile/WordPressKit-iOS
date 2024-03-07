import Foundation

public final class RemotePostUpdateParameters: NSObject, Encodable {
    public var ifNotModifiedSince: Date??
    public var status: String??
    public var date: Date??
    public var content: String??
    public var slug: String??

    @objc public func makeRESTParameters() -> [String: Any]? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .formatted(NSDate.rfc3339DateFormatter())
        guard let data = try? encoder.encode(self),
              let object = try? JSONSerialization.jsonObject(with: data) else {
            return nil // Should never happen
        }
        return object as? [String: Any]
    }
}
