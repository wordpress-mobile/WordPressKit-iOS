import Foundation

extension DomainsServiceRemote {

    // MARK: - API

    public func getAllDomains(params: GetAllDomainsParams? = nil, completion: @escaping (Result<[AllDomainsResultDomain], Error>) -> Void) {
        let path = self.getAllDomainsPath(params: params)
        self.wordPressComRestApi.GET(path, parameters: nil) { result, _ in
            do {
                switch result {
                case .success(let result):
                    let data = try JSONSerialization.data(withJSONObject: result, options: [])
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let result = try decoder.decode(AllDomainsResult.self, from: data)
                    completion(.success(result.domains))
                case .failure(let error):
                    throw error
                }
            } catch let error {
                completion(.failure(error))
            }
        }
    }

    private func getAllDomainsPath(params: GetAllDomainsParams?) -> String {
        let endpoint = "all-domains"
        let path = self.path(forEndpoint: endpoint, withVersion: ._1_1)
        var components = URLComponents(string: path)
        var queryItems = [URLQueryItem]()
        if let resolveStatus = params?.resolveStatus {
            queryItems.append(.init(name: "resolve_status", value: "\(resolveStatus)"))
        }
        if let locale = params?.locale {
            queryItems.append(.init(name: "locale", value: locale))
        }
        components?.queryItems = queryItems
        return components?.url?.absoluteString ?? path
    }

    // MARK: - Types

    public struct GetAllDomainsParams {
        public var resolveStatus: Bool?
        public var locale: String?
        public init() {}
    }

    private struct AllDomainsResult: Decodable {
        let domains: [AllDomainsResultDomain]
    }

    public struct AllDomainsResultDomain {
        struct Status {
            let status: String
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
}

extension DomainsServiceRemote.AllDomainsResultDomain.Status: Decodable {
    enum CodingKeys: String, CodingKey {
        case status
        case type = "status_type"
    }
}

extension DomainsServiceRemote.AllDomainsResultDomain: Decodable {

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
