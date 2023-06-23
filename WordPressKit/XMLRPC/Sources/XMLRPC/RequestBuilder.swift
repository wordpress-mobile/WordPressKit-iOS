import Foundation

protocol Builder {
    var TAB: String { get }
    var NEWLINE: String { get }

    static var TAB: String { get }
    static var NEWLINE: String { get }
}

extension Builder {
    var TAB: String { "  " }
    var NEWLINE: String { "\n" }

    static var TAB: String { "  " }
    static var NEWLINE: String { "\n" }
}

struct RequestBuilder: Builder {

    private var methodCall: String = ""
    private var params: [Param] = []

    public init(){}

    init(methodCall: String, params: [Param]) {
        self.methodCall = methodCall
        self.params = params
    }

    func set(methodCall: String) -> RequestBuilder {
        RequestBuilder(methodCall: methodCall, params: self.params)
    }

    func add(value: Param) -> RequestBuilder {
        add(values: [value])
    }

    func add(values: [Param]) -> RequestBuilder {
        RequestBuilder(methodCall: self.methodCall, params: self.params + values)
    }

    func addLoginDetails(_ loginValues: Login) -> RequestBuilder {
        add(values: [
            .int(loginValues.blogID),
            .string(loginValues.username),
            .string(loginValues.password)
        ])
    }

    func build() -> String {
        var string = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" + NEWLINE
        string += "<methodCall>" + NEWLINE + TAB + "<methodName>" + methodCall + "</methodName>" + NEWLINE

        string += TAB + "<params>" + NEWLINE

        for param in params {
            string += build(param: param)
        }

        string += TAB + "</params>" + NEWLINE
        string += "</methodCall>"

        return string
    }

    private func build(param: Param) -> String {
        // Don't output a `<param>` element at all if there's no value
        guard !param.value.isEmpty else {
            return ""
        }

        var string = ""
        string += TAB + TAB + "<param>" + NEWLINE
        string += TAB + TAB + TAB + "<value>" + NEWLINE

        if case .struct = param {
            string += param.value
        } else {
            string += TAB + TAB + TAB + TAB + "<\(param.dataType)>\(param.value)</\(param.dataType)>" + NEWLINE
        }

        string += TAB + TAB + TAB + "</value>" + NEWLINE
        string += TAB + TAB + "</param>" + NEWLINE
        return string
    }
}
