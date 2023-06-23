import Foundation

public struct WPPost {
    public let id: Int
    public let title: String?
    public let date: Date
    public let dateGMT: Date
    public let modified: Date
    public let modifiedGMT: Date
    public let status: String
    public let type: String
    public let name: String?
    public let authorID: Int
    public let password: String?
    public let excerpt: String?
    public let content: String?
    public let parentID: Int
    public let mimeType: String?
    public let link: String
    public let guid: String
    public let menuOrder: Int
    public let commentStatus: String
    public let pingStatus: String
    public let sticky: Bool
    public let postThumbnail: [URL]
    public let format: String
    public let terms: [WPTerm]

    var description: String {
        return """
============================================================
Post ID                 : \(id)
Post Title              : \(title ?? "")
"Post Date              : \(date)
Post Date (GMT)         : \(dateGMT)
Post Modified Date      : \(modified)
Post Modified Date (GMT): \(modifiedGMT)
Post Status             : \(status)
Post Type               : \(type)
Post Name               : \(name ?? "")
Post Author             : \(authorID)
Post Password           : \(password ?? "")
Post Excerpt            : \(excerpt ?? "")
Post Content            : \(content ?? "")
Post Parent             : \(parentID)
Post MIME Type          : \(mimeType ?? "")
Post Link               : \(link)
Post Terms              : \(terms.count) Terms (See Below)
============================================================
"""
    }
}

public extension [WPPost] {
    func post(withID id: Int) -> WPPost? {
        self.first { $0.id == id }
    }
}
