public class DefaultFormattableContentAction: FormattableContentAction {
    public var enabled: Bool 

    public var on: Bool {
        didSet {
            command?.on = on
        }
    }

    public var command: FormattableContentActionCommand?

    public var identifier: Identifier {
        return type(of: self).actionIdentifier()
    }

    public init(on: Bool) {
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
