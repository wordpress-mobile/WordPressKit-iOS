extension NSObject {

    var allProperties: [String: Any] {
        let properties = Mirror(reflecting: self)
            .children
            .compactMap { child in
                if let label = child.label {
                    return (label, child.value)
                } else {
                    return nil
                }
            }
        return Dictionary(properties) { (_, new) in new }
    }

}
