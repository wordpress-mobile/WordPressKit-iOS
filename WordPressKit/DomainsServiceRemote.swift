import Foundation
import CocoaLumberjack

public struct DomainSuggestion: Codable {
    public let domainName: String
    public let productID: Int?
    public let supportsPrivacy: Bool?

    public init(json: [String: AnyObject]) throws {
        guard let domain = json["domain_name"] as? String else {
             throw DomainsServiceRemote.ResponseError.decodingFailed
        }

        self.domainName = domain
        self.productID = json["product_id"] as? Int ?? nil
        self.supportsPrivacy = json["supports_privacy"] as? Bool ?? nil
    }
}

/// Allows the construction of a request for domain suggestions.
///
public struct DomainSuggestionRequest: Encodable {
    public let query: String
    public let segmentID: Int64
    
    public init(query: String, segmentID: Int64) {
        self.query = query
        self.segmentID = segmentID
    }
}

public class DomainsServiceRemote: ServiceRemoteWordPressComREST {
    public enum ResponseError: Error {
        case decodingFailed
    }

    public enum DomainSuggestionType {
        case noWordpressDotCom
        case includeWordPressDotCom
        case onlyWordPressDotCom
        case wordPressDotComAndDotBlogSubdomains
        case whitelistedTopLevelDomains([String])
        
        fileprivate func parameters() -> [String: AnyObject] {
            switch self {
            case .noWordpressDotCom:
                return ["include_wordpressdotcom": false as AnyObject]
            case .includeWordPressDotCom:
                return ["include_wordpressdotcom": true as AnyObject,
                        "only_wordpressdotcom": false as AnyObject]
            case .onlyWordPressDotCom:
                return  ["only_wordpressdotcom": true as AnyObject]
            case .wordPressDotComAndDotBlogSubdomains:
                return ["include_dotblogsubdomain": true as AnyObject,
                        "vendor": "dot" as AnyObject,
                        "only_wordpressdotcom": true as AnyObject,
                        "include_wordpressdotcom": true as AnyObject]
            case .whitelistedTopLevelDomains(let whitelistedTLDs):
                return ["tlds": whitelistedTLDs.joined(separator: ",") as AnyObject]
            }
        }
    }
    
    public func getDomainsForSite(_ siteID: Int, success: @escaping ([RemoteDomain]) -> Void, failure: @escaping (Error) -> Void) {
        let endpoint = "sites/\(siteID)/domains"
        let path = self.path(forEndpoint: endpoint, withVersion: ._1_1)

        wordPressComRestApi.GET(path, parameters: nil,
            success: {
                response, _ in
                do {
                    try success(mapDomainsResponse(response))
                } catch {
                    DDLogError("Error parsing domains response (\(error)): \(response)")
                    failure(error)
                }
            }, failure: {
                error, _ in
                failure(error)
        })
    }

    public func setPrimaryDomainForSite(siteID: Int, domain: String, success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        let endpoint = "sites/\(siteID)/domains/primary"
        let path = self.path(forEndpoint: endpoint, withVersion: ._1_1)

        let parameters: [String: AnyObject] = ["domain": domain as AnyObject]

        wordPressComRestApi.POST(path, parameters: parameters,
                                success: { response, _ in

            success()
        }, failure: { error, _ in

            failure(error)
        })
    }

    @objc public func getStates(for countryCode: String,
                                success: @escaping ([State]) -> Void,
                                failure: @escaping (Error) -> Void) {
        let endPoint = "domains/supported-states/\(countryCode)"
        let servicePath = path(forEndpoint: endPoint, withVersion: ._1_1)
        
        wordPressComRestApi.GET(
            servicePath,
            parameters: nil,
            success: {
                response, _ in
                do {
                    guard let json = response as? [AnyObject] else {
                        throw ResponseError.decodingFailed
                    }
                    let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                    let decodedResult = try JSONDecoder.apiDecoder.decode([State].self, from: data)
                    success(decodedResult)
                } catch {
                    DDLogError("Error parsing State list for country code (\(error)): \(response)")
                    failure(error)
                }
        }, failure: { error, _ in
            failure(error)
        })
    }
    
    public func getDomainContactInformation(success: @escaping (DomainContactInformation) -> Void,
                                            failure: @escaping (Error) -> Void) {
        let endPoint = "me/domain-contact-information"
        let servicePath = path(forEndpoint: endPoint, withVersion: ._1_1)
        
        wordPressComRestApi.GET(
            servicePath,
            parameters: nil,
            success: { (response, _) in
                do {
                    let data = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
                    let decodedResult = try JSONDecoder.apiDecoder.decode(DomainContactInformation.self, from: data)
                    success(decodedResult)
                } catch {
                    DDLogError("Error parsing DomainContactInformation  (\(error)): \(response)")
                    failure(error)
                }
        }) { (error, _) in
            failure(error)
        }
    }
    
    public func validateDomainContactInformation(contactInformation: [String: String],
                                                 domainNames: [String],
                                                 success: @escaping (ValidateDomainContactInformationResponse) -> Void,
                                                 failure: @escaping (Error) -> Void) {
        let endPoint = "me/domain-contact-information/validate"
        let servicePath = path(forEndpoint: endPoint, withVersion: ._1_1)
        
        let parameters: [String: AnyObject] = ["contact_information": contactInformation as AnyObject,
                                               "domain_names": domainNames as AnyObject]
        wordPressComRestApi.POST(
            servicePath,
            parameters: parameters,
            success: { response,_ in
                do {
                    let data = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
                    let decodedResult = try JSONDecoder.apiDecoder.decode(ValidateDomainContactInformationResponse.self, from: data)
                    success(decodedResult)
                } catch {
                    DDLogError("Error parsing ValidateDomainContactInformationResponse  (\(error)): \(response)")
                    failure(error)
                }
        }) { (error, response) in
            failure(error)
        }
    }

    public func getDomainSuggestions(request: DomainSuggestionRequest,
                                     success: @escaping ([DomainSuggestion]) -> Void,
                                     failure: @escaping (Error) -> Void) {
        let endPoint = "domains/suggestions"
        let servicePath = path(forEndpoint: endPoint, withVersion: ._1_1)
        let parameters: [String: AnyObject] = [
            "segment_id": request.segmentID as AnyObject,
            "query": request.query as AnyObject
        ]

        wordPressComRestApi.GET(servicePath,
                                parameters: parameters,
                                success: {
                                    response, _ in
                                    do {
                                        let suggestions = try map(suggestions: response)
                                        success(suggestions)
                                    } catch {
                                        DDLogError("Error parsing domains response (\(error)): \(response)")
                                        failure(error)
                                    }
        }, failure: {
            error, _ in
            failure(error)
        })
    }

    public func getDomainSuggestions(base query: String,
                                     domainSuggestionType: DomainSuggestionType = .onlyWordPressDotCom,
                                     success: @escaping ([DomainSuggestion]) -> Void,
                                     failure: @escaping (Error) -> Void) {
        let endPoint = "domains/suggestions"
        let servicePath = path(forEndpoint: endPoint, withVersion: ._1_1)
        var parameters: [String: AnyObject] = domainSuggestionType.parameters()
        parameters["query"] = query as AnyObject
        
        wordPressComRestApi.GET(servicePath,
                                parameters: parameters,
                                success: {
                                    response, _ in
                                    do {
                                        let suggestions = try map(suggestions: response)
                                        success(suggestions)
                                    } catch {
                                        DDLogError("Error parsing domains response (\(error)): \(response)")
                                        failure(error)
                                    }
        }, failure: {
            error, _ in
            failure(error)
        })
    }
}

private func map(suggestions response: AnyObject) throws -> [DomainSuggestion] {
    guard let jsonSuggestions = response as? [[String: AnyObject]] else {
        throw DomainsServiceRemote.ResponseError.decodingFailed
    }
    
    var suggestions: [DomainSuggestion] = []
    for jsonSuggestion in jsonSuggestions {
        do {
            let suggestion = try DomainSuggestion(json: jsonSuggestion)
            suggestions.append(suggestion)
        }
    }
    return suggestions
}

private func mapDomainsResponse(_ response: AnyObject) throws -> [RemoteDomain] {
    guard let json = response as? [String: AnyObject],
        let domainsJson = json["domains"] as? [[String: AnyObject]] else {
            throw DomainsServiceRemote.ResponseError.decodingFailed
    }

    let domains = try domainsJson.map { domainJson -> RemoteDomain in

        guard let domainName = domainJson["domain"] as? String,
            let isPrimary = domainJson["primary_domain"] as? Bool else {
                throw DomainsServiceRemote.ResponseError.decodingFailed
        }

        return RemoteDomain(domainName: domainName, isPrimaryDomain: isPrimary, domainType: domainTypeFromDomainJSON(domainJson))
    }

    return domains
}

private func domainTypeFromDomainJSON(_ domainJson: [String: AnyObject]) -> DomainType {
    if let type = domainJson["type"] as? String, type == "redirect" {
        return .siteRedirect
    }

    if let wpComDomain = domainJson["wpcom_domain"] as? Bool, wpComDomain == true {
        return .wpCom
    }

    if let hasRegistration = domainJson["has_registration"] as? Bool, hasRegistration == true {
        return .registered
    }

    return .mapped
}
