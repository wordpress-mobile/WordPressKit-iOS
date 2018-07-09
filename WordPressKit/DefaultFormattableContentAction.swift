class DefaultFormattableContentAction: FormattableContentAction {
    var enabled: Bool
    var on: Bool
    var command: FormattableContentActionCommand?

    var identifier: Identifier {
        return type(of: self).actionIdentifier()
    }

    init(on: Bool) {
        self.on = on
        self.enabled = true
    }

    func setCommand(_ command: FormattableContentActionCommand) {
        self.command = command
    }

    func execute(context: ActionContext) {
        command?.execute(context: context)
    }
}
