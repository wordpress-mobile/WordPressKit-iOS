import Foundation



// MARK: - FormattableContentGroup: Adapter to match 1 View <> 1 BlockGroup
//
open class FormattableContentGroup {
    /// Grouped Blocks
    ///
    public let blocks: [FormattableContent]

    /// Kind of the current Group
    ///
    public let kind: Kind

    /// Designated Initializer
    ///
    public init(blocks: [FormattableContent], kind: Kind) {
        self.blocks = blocks
        self.kind = kind
    }
}



// MARK: - Helpers Methods
//
extension FormattableContentGroup {
    /// Returns the First Block of a specified kind
    ///
    public func blockOfKind(_ kind: FormattableContent.Kind) -> FormattableContent? {
        return type(of: self).blockOfKind(kind, from: blocks)
    }

    /// Extracts all of the imageUrl's for the blocks of the specified kinds
    ///
    public func imageUrlsFromBlocksInKindSet(_ kindSet: Set<FormattableContent.Kind>) -> Set<URL> {
        let filtered = blocks.filter { kindSet.contains($0.kind) }
        let imageUrls = filtered.flatMap { $0.imageUrls }
        return Set(imageUrls) as Set<URL>
    }
}




// MARK: - Private Parsing Helpers
//
extension FormattableContentGroup {
    /// Returns the First Block of a specified kind.
    ///
    public class func blockOfKind(_ kind: FormattableContent.Kind, from blocks: [FormattableContent]) -> FormattableContent? {
        for block in blocks where block.kind == kind {
            return block
        }

        return nil
    }
}


// MARK: - FormattableContentGroup Types
//
extension FormattableContentGroup {
    /// Known Kinds of Block Groups
    ///
    public enum Kind {
        case text
        case image
        case user
        case comment
        case actions
        case subject
        case header
        case footer

        public static func fromBlockKind(_ blockKind: FormattableContent.Kind) -> Kind {
            switch blockKind {
            case .text:     return .text
            case .image:    return .image
            case .user:     return .user
            case .comment:  return .comment
            }
        }
    }
}
