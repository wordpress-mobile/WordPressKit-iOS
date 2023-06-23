import Foundation

enum Param {
    case int(Int)
    case string(String)
    case stringArray([String])
    case `struct`(ConvertableToStruct)

    var dataType: String {
        switch self {
        case .int(_):
            return "int"
        case .string(_):
            return "string"
        case .stringArray(_):
            return "string"
        case .struct(_):
            return "struct"
        }
    }

    var value: String {
        switch self {
        case .int(let value):
            return "\(value)"
        case .string(let value):
            return value
        case .stringArray(let value):
            return ArrayFormatter.strings(value)
        case .struct(let value):
            return value.toStruct().build()
        }
    }
}

struct ArrayFormatter: Builder {
    static func strings(_ strings: [String]) -> String {
        var string: String = ""
        string += TAB + TAB + "<value>" + NEWLINE
        string += TAB + TAB + TAB + "<array>" + NEWLINE
        string += TAB + TAB + TAB + TAB + "<data>" + NEWLINE

        for _string in strings {
            string += TAB + TAB + TAB + TAB + TAB
            string += "<value>" + "<string>" + _string + "</string>" + "</value>" + NEWLINE
        }

        string += TAB + TAB + TAB + TAB + "</data>" + NEWLINE
        string += TAB + TAB + TAB + "</array>" + NEWLINE
        string += TAB + TAB + "</value>" + NEWLINE

        return string
    }
}
