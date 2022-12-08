import Foundation

@objcMembers public class RemoteReaderTopic: NSObject {

    public var isMenuItem: Bool = false
    public var isRecommended: Bool = false
    public var isSubscribed: Bool = false
    public var path: String?
    public var slug: String?
    public var title: String?
    public var topicDescription: String?
    public var topicID: NSNumber?
    public var type: String?
    public var owner: String?
    public var organizationID: NSNumber?

}
