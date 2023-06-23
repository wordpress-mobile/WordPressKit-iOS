import Foundation

struct ParserStateMachine {
    enum State {
        case start
        case posts
        case postTerms
        case postTermCustomFields
        case postCustomFields
        case end
    }

    var state: State = .start

    mutating func startParsingPosts() {
        precondition([State.start, State.postTerms].contains(self.state))
        self.state = .posts
    }

    mutating func startParsingPostTerms() {
        precondition(self.state == .posts)
        self.state = .postTerms
    }

    mutating func startParsingPostTermCustomFields() {
        precondition(self.state == .postTerms)
        self.state = .postTermCustomFields
    }

    mutating func stopParsingPostTermCustomFields() {
        precondition(self.state == .postTermCustomFields)
        self.state = .postTerms
    }

    mutating func stopParsingPostTerms() {
        precondition(self.state == .postTerms)
        self.state = .posts
    }

    mutating func startParsingPostCustomFields() {
        precondition(self.state == .posts)
        self.state = .postCustomFields
    }

    mutating func end() {
        precondition(self.state == .posts)
        self.state = .end
    }

    func didReceiveValue(_ value: XMLRPCValue, for keyPath: XMLKeyPath) {
        if self.state == .posts {
            self.didReceivePostValue(value, keyPath)
        }

        if self.state == .postTerms {
            self.didReceiveTermValue(value, keyPath)
        }
    }

    var didReceivePostValue: (XMLRPCValue, XMLKeyPath) -> Void
    var didReceiveTermValue: (XMLRPCValue, XMLKeyPath) -> Void

    var didFinishParsingPost: () -> Void
    var didFinishParsingPostTerm: () -> Void
}

public class PostsResponseParser: NSObject {

    enum ParserState {
        case parsingPost
    }

    let xmlParser: XMLRPCParser

    public init(response: Data) {
        self.xmlParser = XMLRPCParser(data: response)
        super.init()
        self.xmlParser.delegate = self
    }

    public func parse() throws -> [WPPost] {
        try self.xmlParser.parse()
        return self.posts
    }

    // Parser Variables
    var postMember: PostMember?
    var termMember: TermMember?
    var termCustomFieldMemberName: String?
    var postCustomFieldMemberName: String?

    var members: [Struct.Member] = []

    private let dateFormatter = {
        let dateFormatter = DateFormatter()
        if #available(macOS 13, iOS 16, *) {
            dateFormatter.timeZone = .gmt
        } else {
            dateFormatter.timeZone = .init(secondsFromGMT: 0)
        }
        dateFormatter.dateFormat = "yyyyMMdd'T'HH:mm:ss"

        return dateFormatter
    }()

    //=================
    //
    // Parser State Variables
    //
    //=================
    private var posts: [WPPost] = []
    private var isParsingArray: Bool = false

    lazy var stateMachine = {
        ParserStateMachine(
            didReceivePostValue: self.processPostMember,
            didReceiveTermValue: self.processTermMember,
            didFinishParsingPost: self.processPost,
            didFinishParsingPostTerm: self.processTerm
        )
    }()

    //=================
    // Post Fields
    //=================
    private var postID: String?
    private var postTitle: String?
    private var postDate: Date?
    private var postDateGMT: Date?
    private var postModified: Date?
    private var postModifiedGMT: Date?
    private var postStatus: String?
    private var postType: String?
    private var postName: String?
    private var postAuthor: String?
    private var postPassword: String?
    private var postExcerpt: String?
    private var postContent: String?
    private var postParent: String?
    private var postMimeType: String?
    private var postLink: String?
    private var postGuid: String?
    private var postMenuOrder: Int?
    private var postCommentStatus: String?
    private var postPingStatus: String?
    private var postSticky: Bool?
    private var postThumbnail: [String] = []
    private var postFormat: String?
    private var postTerms: [WPTerm] = []
    private var postCustomFields: [String] = []

    //=================
    // Term Fields
    //=================
    private var termID: String?
    private var termName: String?
    private var termSlug: String?
    private var termGroup: String?
    private var termTaxonomyID: String?
    private var termTaxonomy: String?
    private var termDescription: String?
    private var termParent: String?
    private var termCount: Int?
    private var termFilter: String?
    private var termCustomFields: [String] = []
}

extension PostsResponseParser: XMLRPCParserDelegate {
    func didStartParsingMember(with keyPath: XMLKeyPath) {
        //
    }

    func didStartParsingStruct(with keyPath: XMLKeyPath) {
        if keyPath.isEmpty {
            self.stateMachine.startParsingPosts()
        }
    }

    func didStartParsingArray(with keyPath: XMLKeyPath) {
        if keyPath.description == "terms" {
            self.stateMachine.startParsingPostTerms()
        }
    }

    func didFinishParsingMember(with keyPath: XMLKeyPath) {
        //
    }

    func didFinishParsingStruct(with keyPath: XMLKeyPath) {
        if keyPath.isEmpty {
            self.stateMachine.didFinishParsingPost()
        }

        if keyPath.description == "terms" {
            self.stateMachine.didFinishParsingPostTerm()
        }
    }

    func didFinishParsingArray(with keyPath: XMLKeyPath) {
        //
    }

    func didFinishParsingMember() {
        //
    }

    func didStartParsingStruct() {
        //
    }

    func didFinishParsingStruct() {
        //
    }

    func process(value: XMLRPCValue, for keyPath: XMLKeyPath) {
        self.stateMachine.didReceiveValue(value, for: keyPath)
    }

    func didStartParsingDocument() {
//        self.stateMachine.startParsingPosts()
    }

    func didEndParsingDocument() {
//        self.stateMachine.end()
    }
}

/// Our own lifecycle callbacks
extension PostsResponseParser {



    func processPostMember(_ value: XMLRPCValue, for keyPath: XMLKeyPath) {

        guard let leafNode = keyPath.peek, let member = PostMember(rawValue: leafNode) else {
            return
        }

        switch(member) {
        case .post_id:
            self.postID = value
        case .post_title:
            self.postTitle = value
        case .post_date:
            self.postDate = dateFormatter.date(from: value)
        case .post_date_gmt:
            self.postDateGMT = dateFormatter.date(from: value)
        case .post_modified:
            self.postModified = dateFormatter.date(from: value)
        case .post_modified_gmt:
            self.postModifiedGMT = dateFormatter.date(from: value)
        case .post_status:
            self.postStatus = value
        case .post_type:
            self.postType = value
        case .post_name:
            self.postName = value
        case .post_author:
            self.postAuthor = value
        case .post_password:
            self.postPassword = value
        case .post_excerpt:
            self.postExcerpt = value
        case .post_content:
            self.postContent = value
        case .post_parent:
            self.postParent = value
        case .post_mime_type:
            self.postMimeType = value
        case .link:
            self.postLink = value
        case .guid:
            self.postGuid = value
        case .menu_order:
            self.postMenuOrder = Int(value)
        case .comment_status:
            self.postCommentStatus = value
        case .ping_status:
            self.postPingStatus = value
        case .sticky:
            self.postSticky = false
        case .post_thumbnail:
            self.postThumbnail = [] // TODO
        case .post_format:
            self.postFormat = value
        case .terms: break
        case .custom_fields: break
        }
    }

    func processTermMember(_ value: XMLRPCValue, for keyPath: XMLKeyPath) {

        guard let leafNode = keyPath.peek, let member = TermMember(rawValue: leafNode) else {
            return
        }

        switch(member){
        case .term_id:
            self.termID = value
        case .name:
            self.termName = value
        case .slug:
            self.termSlug = value
        case .term_group:
            self.termGroup = value
        case .term_taxonomy_id:
            self.termTaxonomyID = value
        case .taxonomy:
            self.termTaxonomy = value
        case .description:
            self.termDescription = value
        case .parent:
            self.termParent = value
        case .count:
            self.termCount = Int(value)
        case .filter:
            self.termFilter = value
        case .custom_fields:
            debugPrint("NOT YET IMPLEMENTED: `custom_fields`")
        }

        self.termMember = nil
    }

    func processTermCustomFieldMember() {

    }

    func processPost() {
        guard
            let postID = self.postID,
            let postDate = self.postDate,
            let postDateGMT = self.postDateGMT,
            let postModified = self.postModified,
            let postModifiedGMT = self.postModifiedGMT,
            let postStatus = self.postStatus,
            let postType = self.postType,
            let postAuthor = self.postAuthor,
            let postParent = self.postParent,
            let postLink = self.postLink,
            let postGuid = self.postGuid,
            let postMenuOrder = self.postMenuOrder,
            let postCommentStatus = self.postCommentStatus,
            let postPingStatus = self.postPingStatus,
            let postSticky = self.postSticky,
            let postFormat = self.postFormat,

            /// Non-string fields
            let postIdIntValue = Int(postID),
            let authorIdIntValue = Int(postAuthor),
            let postParentIntValue = Int(postParent)
        else {
            return
        }

        let post = WPPost(
            id: postIdIntValue,
            title: self.postTitle,
            date: postDate,
            dateGMT: postDateGMT,
            modified: postModified,
            modifiedGMT: postModifiedGMT,
            status: postStatus,
            type: postType,
            name: self.postName,
            authorID: authorIdIntValue,
            password: self.postPassword,
            excerpt: self.postExcerpt,
            content: self.postContent,
            parentID: postParentIntValue,
            mimeType: self.postMimeType,
            link: postLink,
            guid: postGuid,
            menuOrder: postMenuOrder,
            commentStatus: postCommentStatus,
            pingStatus: postPingStatus,
            sticky: postSticky,
            postThumbnail: [],
            format: postFormat,
            terms: self.postTerms
        )

        self.posts.append(post)

        self.postID = nil
        self.postTitle = nil
        self.postDate = nil
        self.postDateGMT = nil
        self.postModified = nil
        self.postModifiedGMT = nil
        self.postStatus = nil
        self.postType = nil
        self.postName = nil
        self.postAuthor = nil
        self.postPassword = nil
        self.postExcerpt = nil
        self.postContent = nil
        self.postParent = nil
        self.postMimeType = nil
        self.postLink = nil
        self.postGuid = nil
        self.postMenuOrder = nil
        self.postCommentStatus = nil
        self.postPingStatus = nil
        self.postSticky = nil
        self.postThumbnail = []
        self.postFormat = nil
        self.postTerms = []
    }

    func processTerm() {
        guard
            let termID = self.termID,
            let termName = self.termName,
            let termSlug = self.termSlug,
            let termGroup = self.termGroup,
            let termTaxonomyID = self.termTaxonomyID,
            let termTaxonomy = self.termTaxonomy,
            let termParent = self.termParent,
            let termCount = self.termCount,
            let termFilter = self.termFilter,

            /// Non-string fields
            let termIntValue = Int(termID),
            let termGroupIntValue = Int(termGroup),
            let termTaxonomyIDIntValue = Int(termTaxonomyID),
            let termParentIntValue = Int(termParent)
        else {
            return
        }

        let term = WPTerm(
            termID: termIntValue,
            name: termName,
            slug: termSlug,
            termGroup: termGroupIntValue,
            termTaxonomyID: termTaxonomyIDIntValue,
            taxonomy: termTaxonomy,
            description: self.termDescription,
            parent: termParentIntValue,
            count: termCount,
            filter: termFilter,
            customFields: []
        )

        self.postTerms.append(term)

        self.termID = nil
        self.termName = nil
        self.termSlug = nil
        self.termGroup = nil
        self.termTaxonomyID = nil
        self.termTaxonomy = nil
        self.termDescription = nil
        self.termParent = nil
        self.termCount = nil
        self.termFilter = nil
        self.termCustomFields = []
    }
}
