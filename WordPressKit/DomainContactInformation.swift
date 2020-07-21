import Foundation

public struct ValidateDomainContactInformationResponse: Codable {
    public struct Messages: Codable {
        public var phone: [String]?
        public var email: [String]?
        public var postalCode: [String]?
        public var countryCode: [String]?
        public var city: [String]?
        public var address1: [String]?
        public var address2: [String]?
        public var firstName: [String]?
        public var lastName: [String]?
        public var state: [String]?
    }
    
    public var success: Bool = false
    public var messages: Messages?
    
    public init() {
    }
}

public struct DomainContactInformation: Codable {
    public var phone: String?
    public var email: String?
    public var postalCode: String?
    public var countryCode: String?
    public var city: String?
    public var address1: String?
    public var firstName: String?
    public var lastName: String?
    public var fax: String?
    public var state: String?
    public var organization: String?
    
    public init() {
    }
}
