
public protocol FormattableContentStyles {
    var attributes: [NSAttributedStringKey: Any] { get }
    var quoteStyles: [NSAttributedStringKey: Any]? { get }
    var rangeStylesMap: [FormattableContentRange.Kind: [NSAttributedStringKey: Any]]? { get }
    var linksColor: UIColor? { get }
}
