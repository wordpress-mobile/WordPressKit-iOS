import Foundation
import wpxmlrpc

typealias XMLRPCDictionary = NSDictionary

extension XMLRPCDictionary {
    func integerValue(for key: String) throws -> Int {
        guard let object = self.object(forKey: key) as? Int else {
            throw CocoaError(.coderInvalidValue)
        }

        return object
    }

    func integerValue(for key: TermMember) throws -> Int {
        try integerValue(for: key.rawValue)
    }

    func stringIntegerValue(for key: String) throws -> Int {
        guard
            let object = self.object(forKey: key) as? String,
            let intValue = Int(object)
        else {
            throw CocoaError(.coderInvalidValue)
        }

        return intValue
    }

    func dateValue(for key: String) throws -> Date {
        guard let object = self.object(forKey: key) as? Date else {
            throw CocoaError(.coderInvalidValue)
        }

        return object
    }

    func stringIntegerValue(for key: TermMember) throws -> Int {
        try stringIntegerValue(for: key.rawValue)
    }

    func stringValue(for key: String) throws -> String {
        guard let string = self.object(forKey: key) as? String else {
            throw CocoaError(.coderInvalidValue)
        }

        return string
    }

    func stringValue(for key: String) throws -> String? {
        self.object(forKey: key) as? String
    }

    func stringValue(for key: TermMember) throws -> String {
        try stringValue(for: key.rawValue)
    }

    func stringValue(for key: TermMember) throws -> String? {
        try stringValue(for: key.rawValue)
    }

    func nilIfEmptyStringValue(for key: String) throws -> String? {
        guard
            let value = try stringValue(for: key),
            !value.isEmpty else {
            return nil
        }

        return value
    }
}

public struct PostResponseProcessor {

    enum Errors: Error {
        case invalidData
        case xmlDecodeError
    }

    public init(){}

    public func process(_ data: Data) throws -> [WPPost] {
        guard let decoder = WPXMLRPCDecoder(data: data) else {
            throw Errors.xmlDecodeError
        }

        if let error = decoder.error() {
            throw error
        }

        guard let rawPosts = decoder.object() as? NSArray else {
            throw Errors.invalidData
        }

        return try rawPosts.compactMap(self.convertPost)
    }

    func convertPost(_ rawPostData: Any) throws -> WPPost? {
        guard
            let dictionary = rawPostData as? XMLRPCDictionary,
            let postID = dictionary.object(forKey: "post_id") as? String,
            let date = dictionary.object(forKey: "post_date") as? Date,
            let dateGMT = dictionary.object(forKey: "post_date_gmt") as? Date,
            let dateModified = dictionary.object(forKey: "post_modified_gmt") as? Date,
            let dateModifiedGMT = dictionary.object(forKey: "post_modified_gmt") as? Date,
            let status = dictionary.object(forKey: "post_status") as? String,
            let postType = dictionary.object(forKey: "post_type") as? String,
            let authorID = dictionary.object(forKey: "post_author") as? String,
            let parentID = dictionary.object(forKey: "post_parent") as? String,
            let link = dictionary.object(forKey: "link") as? String,
            let guid = dictionary.object(forKey: "guid") as? String,
            let menuOrder = dictionary.object(forKey: "menu_order") as? Int,
            let commentStatus = dictionary.object(forKey: "comment_status") as? String,
            let pingStatus = dictionary.object(forKey: "ping_status") as? String,
            let isSticky = dictionary.object(forKey: "sticky") as? Bool,
            let format = dictionary.object(forKey: "post_format") as? String,

            let postIdIntValue = Int(postID),
            let authorIdIntValue = Int(authorID),
            let parentIdIntValue = Int(parentID)
        else {
            return nil
        }

        return try WPPost(
            id: postIdIntValue,
            title: dictionary.stringValue(for: "post_title"),
            date: date,
            dateGMT: dateGMT,
            modified: dateModified,
            modifiedGMT: dateModifiedGMT,
            status: status,
            type: postType,
            name: dictionary["slug"] as? String,
            authorID: authorIdIntValue,
            password: dictionary.nilIfEmptyStringValue(for: "post_password"),
            excerpt: dictionary.stringValue(for: "post_excerpt"),
            content: dictionary.stringValue(for: "post_content"),
            parentID: parentIdIntValue,
            mimeType: nil,
            link: link,
            guid: guid,
            menuOrder: menuOrder,
            commentStatus: commentStatus,
            pingStatus: pingStatus,
            sticky: isSticky,
            postThumbnail: [],
            format: format,
            terms: dictionary.mutableArrayValue(forKey: "terms").compactMap(self.convertTerm)
        )
    }

    func convertTerm(rawTermData: Any) throws -> WPTerm? {
        guard let dictionary = rawTermData as? XMLRPCDictionary else {
            return nil
        }

        return try WPTerm(
            termID: dictionary.stringIntegerValue(for: .term_id),
            name: dictionary.stringValue(for: .name),
            slug: dictionary.stringValue(for: .slug),
            termGroup: dictionary.stringIntegerValue(for: .term_group),
            termTaxonomyID: dictionary.stringIntegerValue(for: .term_taxonomy_id),
            taxonomy: dictionary.stringValue(for: .taxonomy),
            description: dictionary.stringValue(for: .description),
            parent: dictionary.stringIntegerValue(for: .parent),
            count: dictionary.integerValue(for: .count),
            filter: dictionary.stringValue(for: .filter),
            customFields: []
        )
    }
}
