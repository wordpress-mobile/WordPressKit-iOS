import Foundation

struct Struct: Buildable, Builder {
    struct Member: Buildable {
        let name: String
        let value: Param

        func build() -> String {
            var string = ""
            string += TAB + TAB + TAB + TAB + TAB + "<member>" + NEWLINE
            string += TAB + TAB + TAB + TAB + TAB + TAB + "<name>" + self.name + "</name>" + NEWLINE
            string += TAB + TAB + TAB + TAB + TAB + TAB + "<value>" + NEWLINE
            string += TAB + TAB + TAB + TAB + TAB + TAB + TAB + "<\(value.dataType)>\(value.value)</\(value.dataType)>" + NEWLINE
            string += TAB + TAB + TAB + TAB + TAB + TAB + "</value>" + NEWLINE
            string += TAB + TAB + TAB + TAB + TAB + "</member>" + NEWLINE
            return string
        }
    }

    var members: [Member] = []

    var isEmpty: Bool {
        members.isEmpty
    }

    static let empty = Struct(members: [])

    private init(members: [Member]) {
        self.members = members
    }

    func add(member: Member) -> Struct {
        Struct(members: self.members + [member])
    }

    func add(members: [Member]) -> Struct {
        Struct(members: self.members + members)
    }

    func add(memberFrom value: Int?, withName name: String) -> Struct {
        guard let value else {
            return self
        }

        return add(member: .init(name: name, value: .int(value)))
    }

    func add(memberFrom value: String?, withName name: String) -> Struct {
        guard let value else {
            return self
        }

        return add(member: .init(name: name, value: .string(value)))
    }

    static func from(members: [Member]) -> Struct {
        Struct(members: members)
    }

    func build() -> String {
        // Don't print an empty struct
        guard !members.isEmpty else {
            return ""
        }

        var string = ""
        string += TAB + TAB + TAB + TAB + "<struct>" + NEWLINE
        string += members.map { $0.build() }.joined()
        string += TAB + TAB + TAB + TAB + "</struct>" + NEWLINE
        return string
    }
}

/// Helpers for building a struct – these helpers can take a nullable value and conditionally add the key/value pair
/// if there is a value present. If no value is present, the original key/value pairs are returned.
///
/// This makes it easy to build up a `Struct` over time.
extension Struct {
    func add(membersFrom: SomeNumberOf<String>, withName name: String) -> Struct {
        switch membersFrom {
            case .one(let string):
                return add(member: .init(name: name, value: .string(string)))
            case .many(let strings):
                let members = strings.map { Member(name: name, value: .string($0)) }
                return add(members: members)
            case .zero:
                return self
        }
    }

    func add(membersFrom: SomeNumberOf<PostStatus>, withName name: String) -> Struct {
        switch membersFrom {
            case .one(let convertible):
                return add(member: .init(name: name, value: .string(convertible.description)))
            case .many(let convertibles):
                let members = convertibles.map { Member(name: name, value: .string($0.description)) }
                return add(members: members)
            case .zero:
                return self
        }
    }

}

protocol ConvertableToStruct {
    func toStruct() -> Struct
}
