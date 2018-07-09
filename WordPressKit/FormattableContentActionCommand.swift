public protocol FormattableContentActionCommand {
    var identifier: Identifier { get }
    func execute(context: ActionContext)
}
