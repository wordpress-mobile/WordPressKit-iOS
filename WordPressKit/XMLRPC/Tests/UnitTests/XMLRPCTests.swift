import XCTest
@testable import XMLRPC

final class XMLRPCTests: XCTestCase {

}

extension XCTestCase {
    func sampleData(named name: String) throws -> Data {
        guard let url = Bundle.module.url(forResource: name, withExtension: "xml") else {
            preconditionFailure("\(name).xml not found – did you remember to add it to the package manifest?")
        }

        return try Data(contentsOf: url)
    }

}
