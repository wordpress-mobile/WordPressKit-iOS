import Foundation

extension DomainsServiceRemote {

    // MARK: - API

    public func fetchAllDomains(params: AllDomainsEndpointParams? = nil, completion: @escaping (AllDomainsEndpointResult) -> Void) {
        let path = self.path(forEndpoint: "all-domains", withVersion: ._1_1)
        var parameters: [String: AnyObject]?

        do {
            parameters = try queryParameters(from: params)
        } catch let error {
            completion(.failure(error))
            return
        }

        self.wordPressComRestApi.GET(path, parameters: parameters) { result, _ in
            do {
                switch result {
                case .success(let result):
                    let data = try JSONSerialization.data(withJSONObject: result, options: [])
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let result = try decoder.decode(AllDomainsEndpointResponse.self, from: data)
                    completion(.success(result.domains))
                case .failure(let error):
                    throw error
                }
            } catch let error {
                completion(.failure(error))
            }
        }
    }

    private func queryParameters(from params: AllDomainsEndpointParams?) throws -> [String: AnyObject]? {
        guard let params else {
            return nil
        }
        let encoder = JSONEncoder()
        let data = try encoder.encode(params)
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject]
        return dict
    }

    // MARK: - Public Types

    public typealias AllDomainsEndpointResult = Result<[AllDomainsListItem], Error>

    public struct AllDomainsEndpointParams {
        public var resolveStatus: Bool?
        public var locale: String?
        public var noWPCOM: Bool?
        public init() {}
    }

    public struct AllDomainsListItem {
        struct Status {
            let value: String
            let type: String
        }
        let domain: String
        let blogId: Int
        let blogName: String
        let type: DomainType
        let isDomainOnlySite: Bool
        let isWpcomStagingDomain: Bool
        let hasRegistration: Bool
        let registrationDate: Date?
        let expiryDate: Date?
        let wpcomDomain: Bool
        let currentUserIsOwner: Bool?
        let siteSlug: String
        let status: Status?
    }

    // MARK: - Private Types

    private struct AllDomainsEndpointResponse: Decodable {
        let domains: [AllDomainsListItem]
    }
}

// MARK: - Encoding / Decoding

extension DomainsServiceRemote.AllDomainsEndpointParams: Encodable {

    enum CodingKeys: String, CodingKey {
        case resolveStatus = "resolve_status"
        case locale
        case noWPCOM = "no_wpcom"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let resolveStatus {
            try container.encodeIfPresent("\(resolveStatus)", forKey: .resolveStatus)
        }
        if let locale {
            try container.encodeIfPresent(locale, forKey: .locale)
        }
        if let noWPCOM {
            try container.encodeIfPresent("\(noWPCOM)", forKey: .noWPCOM)
        }
    }
}

extension DomainsServiceRemote.AllDomainsListItem.Status: Decodable {
    enum CodingKeys: String, CodingKey {
        case value = "status"
        case type = "status_type"
    }
}

extension DomainsServiceRemote.AllDomainsListItem: Decodable {

    enum CodingKeys: String, CodingKey {
        case domain
        case blogId = "blog_id"
        case blogName = "blog_name"
        case type
        case isDomainOnlySite = "is_domain_only_site"
        case isWpcomStagingDomain = "is_wpcom_staging_domain"
        case hasRegistration = "has_registration"
        case registrationDate = "registration_date"
        case expiryDate = "expiry"
        case wpcomDomain = "wpcom_domain"
        case currentUserIsOwner = "current_user_is_owner"
        case siteSlug = "site_slug"
        case status = "domain_status"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.domain = try container.decode(String.self, forKey: .domain)
        self.blogId = try container.decode(Int.self, forKey: .blogId)
        self.blogName = try container.decode(String.self, forKey: .blogName)
        self.isDomainOnlySite = try container.decode(Bool.self, forKey: .isDomainOnlySite)
        self.isWpcomStagingDomain = try container.decode(Bool.self, forKey: .isWpcomStagingDomain)
        self.hasRegistration = try container.decode(Bool.self, forKey: .hasRegistration)
        self.wpcomDomain = try container.decode(Bool.self, forKey: .wpcomDomain)
        self.currentUserIsOwner = try container.decode(Bool?.self, forKey: .currentUserIsOwner)
        self.siteSlug = try container.decode(String.self, forKey: .siteSlug)
        self.registrationDate = try {
            if let timestamp = try? container.decodeIfPresent(String.self, forKey: .registrationDate), !timestamp.isEmpty {
                return try container.decode(Date.self, forKey: .registrationDate)
            }
            return nil
        }()
        self.expiryDate = try {
            if let timestamp = try? container.decodeIfPresent(String.self, forKey: .expiryDate), !timestamp.isEmpty {
                return try container.decode(Date.self, forKey: .expiryDate)
            }
            return nil
        }()
        let type: String = try container.decode(String.self, forKey: .type)
        self.type = .init(type: type, wpComDomain: wpcomDomain, hasRegistration: hasRegistration)
        self.status = try container.decodeIfPresent(Status.self, forKey: .status)
    }
}
