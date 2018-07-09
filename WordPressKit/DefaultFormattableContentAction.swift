class DefaultFormattableContentAction: FormattableContentAction {
    var enabled: Bool

    var on: Bool

    var identifier: Identifier {
        return type(of: self).actionIdentifier()
    }

    init(on: Bool) {
        self.on = on
        self.enabled = true
    }

    func execute(command: FormattableContentActionCommand) { }
}
