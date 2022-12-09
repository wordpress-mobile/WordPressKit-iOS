import Foundation

@objcMembers public class RemotePostTag: NSObject {

    public var tagID: NSNumber?
    public var name: String?
    public var slug: String?
    public var tagDescription: String?
    public var postCount: NSNumber?

    public override var debugDescription: String {
        "\(super.description) (\(allProperties))"
    }

    public override var description: String {
        return "\(super.description) \(String(describing: name))[\(String(describing: tagID))]"
    }

}
