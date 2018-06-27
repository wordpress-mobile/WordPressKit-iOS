import Foundation

// MARK: - FormattableContentGroup: Adapter to match 1 View <> 1 BlockGroup
//
open class FormattableContentGroup {
    /// Grouped Blocks
    ///
    public let blocks: [FormattableContent]

    /// Designated Initializer
    ///
    public init(blocks: [FormattableContent]) {
        self.blocks = blocks
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

    /// Returns the First Block of a specified kind.
    ///
    public class func blockOfKind(_ kind: FormattableContent.Kind, from blocks: [FormattableContent]) -> FormattableContent? {
        for block in blocks where block.kind == kind {
            return block
        }

        return nil
    }

    /// Extracts all of the imageUrl's for the blocks of the specified kinds
    ///
    public func imageUrlsFromBlocksInKindSet(_ kindSet: Set<FormattableContent.Kind>) -> Set<URL> {
        let filtered = blocks.filter { kindSet.contains($0.kind) }
        let imageUrls = filtered.flatMap { $0.imageUrls }
        return Set(imageUrls) as Set<URL>
    }
}
