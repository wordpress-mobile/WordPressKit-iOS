import Foundation

protocol XMLRPCParserDelegate {

    func didStartParsingDocument()

    func didStartParsingMember(with keyPath: XMLKeyPath)
    func didStartParsingStruct(with keyPath: XMLKeyPath)
    func didStartParsingArray(with keyPath: XMLKeyPath)

    func process(value: XMLRPCValue, for keyPath: XMLKeyPath)

    func didFinishParsingMember(with keyPath: XMLKeyPath)
    func didFinishParsingStruct(with keyPath: XMLKeyPath)
    func didFinishParsingArray(with keyPath: XMLKeyPath)

    func didEndParsingDocument()
}

//enum XMLRPCValue {
//    case boolean(Bool?)
//    case date(Date?)
//    case int(Int?)
//    case string(String?)
//}

typealias XMLRPCValue = String

struct XMLKeyPath: CustomStringConvertible {
    private var items: [String]

    mutating func push(_ value: String) {
        items.append(value)
    }

    @discardableResult
    mutating func pop() -> String {
        items.removeLast()
    }

    var peek: String? {
        items.last
    }

    static let empty: XMLKeyPath = XMLKeyPath(items: [])

    var isEmpty: Bool {
        items.isEmpty
    }

    var description: String {
        items.joined(separator: ".")
    }
}

class XMLRPCParser: NSObject {
    let xmlParser: XMLParser

    var keyPath = XMLKeyPath.empty

    var delegate: XMLRPCParserDelegate?

    init(data: Data) {
        self.xmlParser = XMLParser(data: data)
        super.init()
        self.xmlParser.delegate = self
    }

    func parse() throws {
        self.xmlParser.parse()

        if let error = self.xmlParser.parserError {
            throw error
        }
    }

    // Parser Variables
    var currentElementName: String?
    var currentMemberName: String?
    var currentValueType: ParserValue?
}

extension XMLRPCParser: XMLParserDelegate {

    enum ParserElement: String {
        case `struct`
        case array
        case member
    }

    enum ParserValue: String {
        case name

        case boolean
        case int
        case string

        case date = "dateTime.iso8601"
    }

    func parserDidStartDocument(_ parser: XMLParser) {
        self.delegate?.didStartParsingDocument()
    }

    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {

        self.currentElementName = elementName

        guard let element = ParserElement(rawValue: elementName) else {
            return
        }

        switch element {
        case .member:
            self.delegate?.didStartParsingMember(with: self.keyPath)
        case .array:
            self.delegate?.didStartParsingArray(with: self.keyPath)
        case .struct:
            self.delegate?.didStartParsingStruct(with: self.keyPath)
        }
    }

    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch ParserElement(rawValue: elementName) {
            case .member:
            self.delegate?.didFinishParsingMember(with: self.keyPath)
                self.keyPath.pop()
            case .array :
            self.delegate?.didFinishParsingArray(with: self.keyPath)
            case .struct:
            self.delegate?.didFinishParsingStruct(with: self.keyPath)
            case .none:
                break
        }

        self.currentElementName = nil
    }

    public func parser(_ parser: XMLParser, foundCharacters string: String) {

        /// If we encounter text outside of an element, we don't care about it – let's move on
        guard let leafNodeName = self.currentElementName else {
            return
        }

        switch ParserValue(rawValue: leafNodeName) {
        case .name:
            self.keyPath.push(string)
        case .boolean, .int, .date, .string:
            self.delegate?.process(value: string, for: self.keyPath)
        case .none:
            return
        }
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        self.delegate?.didEndParsingDocument()
    }
}
