import Foundation

protocol Request {
    var login: Login { get }
    var methodName: String { get }
}

public protocol Buildable: CustomStringConvertible {
    func build() -> String
}

extension Buildable {
    public var description: String {
        build()
    }
}
