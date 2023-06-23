import Foundation

public struct PostQuery: ConvertableToStruct {

    public enum Orderable: String {
        case id = "post_id"
        case date = "post_date"
    }

    /// The post type(s) to search for
    let types: SomeNumberOf<String>

    /// The post status(es) to search for
    let status: SomeNumberOf<PostStatus>

    let count: Int?

    let offset: Int?

    let orderBy: Orderable?
    let orderDirection: OrderDirection?

    let fields: [PostField]?

    public init(
        types: SomeNumberOf<String> = .zero,
        status: SomeNumberOf<PostStatus> = .zero,
        count: Int? = nil,
        offset: Int? = nil,
        orderBy: Orderable? = nil,
        orderDirection: OrderDirection? = nil,
        fields: [PostField]? = nil
    ) {
        self.types = types
        self.status = status
        self.count = count
        self.offset = offset
        self.orderBy = orderBy
        self.orderDirection = orderDirection
        self.fields = fields
    }

    public static let empty = PostQuery()

    func toStruct() -> Struct {
        Struct.empty
            .add(membersFrom: self.types, withName: "post_type")
            .add(membersFrom: self.status, withName: "post_status")
            .add(memberFrom: self.count, withName: "number")
            .add(memberFrom: self.offset, withName: "offset")
            .add(memberFrom: self.orderBy?.rawValue, withName: "orderby")
            // TODO: the `s` parameter
            .add(memberFrom: self.orderDirection?.rawValue, withName: "order")
    }

    public static func with(count: Int) -> PostQuery {
        PostQuery(count: count)
    }

    public static func with(postType: String) -> PostQuery {
        PostQuery(types: .one(postType))
    }
}
