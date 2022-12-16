import Foundation

@objcMembers public class RemotePostType: NSObject {

    public var apiQueryable: NSNumber?
    public var name: String?
    public var label: String?

    public override var debugDescription: String {
        "\(super.description) (\(allProperties))"
    }

    public override var description: String {
        return "\(super.description) \(String(describing: name))[\(String(describing: label))] apiQueryable=\(String(describing: apiQueryable))"
    }

}
