import Foundation

@objcMembers public class RemotePostCategory: NSObject {
    public var categoryID: NSNumber?
    public var name: String?
    public var parentID: NSNumber?

    public override var debugDescription: String {
        "\(super.description) (\(allProperties))"
    }

    public override var description: String {
        return "\(super.description) \(String(describing: name))[\(String(describing: categoryID))]"
    }
}
