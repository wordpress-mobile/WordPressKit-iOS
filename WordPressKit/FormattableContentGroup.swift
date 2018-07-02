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
    public func blockOfType<ContentType: FormattableContent>(_ aType: ContentType.Type) -> ContentType? {
        return FormattableContentGroup.blockOfType(aType, from: blocks)
    }

    /// Returns the First Block of a specified kind.
    ///
    public class func blockOfType<ContentType: FormattableContent>(_ aType: ContentType.Type, from blocks: [FormattableContent]) -> ContentType? {
        for block in blocks where block is ContentType {
            return block as? ContentType
        }

        return nil
    }
}
