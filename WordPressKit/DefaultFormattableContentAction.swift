public class DefaultFormattableContentAction: FormattableContentAction {
    public var enabled: Bool
    public var on: Bool
    public var command: FormattableContentActionCommand?

    public var identifier: Identifier {
        return type(of: self).actionIdentifier()
    }

    init(on: Bool) {
        self.on = on
        self.enabled = true
    }

    public func setCommand(_ command: FormattableContentActionCommand) {
        self.command = command
    }

    public func execute(context: ActionContext) {
        command?.execute(context: context)
    }
}
