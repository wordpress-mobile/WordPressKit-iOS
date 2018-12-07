import Foundation
import WordPressShared
import CocoaLumberjack

public class PlanServiceRemote: ServiceRemoteWordPressComREST {
    public typealias SitePlans = (activePlan: RemotePlan?, availablePlans: [RemotePlan])
    public typealias AvailablePlans = (plans: [RemotePlanDescription], groups: [RemotePlanGroup], features: [RemotePlanFeature])

    typealias EndpointResponse =  [String: AnyObject]

    public enum ResponseError: Int, Error {
        // Error decoding JSON
        case decodingFailure
        // Depricated. An unsupported plan.
        case unsupportedPlan
        // Deprecated. No active plan identified in the results.
        case noActivePlan
    }

    public func getPlansForSite(_ siteID: Int, success: @escaping (SitePlans) -> Void, failure: @escaping (Error) -> Void) {
        let endpoint = "sites/\(siteID)/plans"
        let path = self.path(forEndpoint: endpoint, withVersion: ._1_2)
        let locale = WordPressComLanguageDatabase().deviceLanguage.slug
        let parameters = ["locale": locale]

        wordPressComRestApi.GET(path,
            parameters: parameters as [String : AnyObject]?,
            success: {
                response, _ in
                do {
                    try success(mapPlansResponse(response))
                } catch {
                    DDLogError("Error parsing plans response for site \(siteID)")
                    DDLogError("\(error)")
                    DDLogDebug("Full response: \(response)")
                    failure(error)
                }
            }, failure: {
                error, _ in
                failure(error)
        })
    }


    public func getWpcomPlans(_ success: @escaping (AvailablePlans) -> Void, failure: @escaping (Error) -> Void) {
        let endpoint = "plans/mobile"
        let path = self.path(forEndpoint: endpoint, withVersion: ._2_0)
        let locale = WordPressComLanguageDatabase().deviceLanguage.slug
        let parameters = ["locale": locale]

        wordPressComRestApi.GET(path,
                                parameters: parameters as [String : AnyObject]?,
                                success: {
                                    response, _ in

                                    guard let response = response as? EndpointResponse else {
                                        failure(PlanServiceRemote.ResponseError.decodingFailure)
                                        return
                                    }

                                    let plans = self.parseWpcomPlans(response)
                                    let groups = self.parseWpcomPlanGroups(response)
                                    let features = self.parseWpcomPlanFeatures(response)

                                    success((plans, groups, features))
        }, failure: {
            error, _ in
            failure(error)
        })
    }


    func parseWpcomPlans(_ response: EndpointResponse) -> [RemotePlanDescription] {
        var parsedResult = [RemotePlanDescription]()
        guard let json = response["plans"] as? [EndpointResponse] else {
            return parsedResult
        }

        for item in json {
            if let remotePlanDescription = parseWpcomPlan(item) {
                parsedResult.append(remotePlanDescription)
            }
        }

        return parsedResult
    }


    func parseWpcomPlanProducts(_ products: [EndpointResponse]) -> String {
        var parsedResult = [String]()
        for item in products {
            if let planId = item["plan_id"] as? String {
                parsedResult.append(planId)
            }
        }
        return parsedResult.joined(separator: ",")
    }


    func parseWpcomPlanGroups(_ response: EndpointResponse) -> [RemotePlanGroup] {
        var parsedResult = [RemotePlanGroup]()
        guard let json = response["groups"] as? [EndpointResponse] else {
            return parsedResult
        }

        for item in json {
            if let remoteGroup = parsePlanGroup(item) {
                parsedResult.append(remoteGroup)
            }
        }

        return parsedResult
    }


    func parseWpcomPlanFeatures(_ response: EndpointResponse) -> [RemotePlanFeature] {
        var parsedResult = [RemotePlanFeature]()
        guard let json = response["features"] as? [EndpointResponse] else {
            return parsedResult
        }

        for item in json {
            if let remoteFeature = parsePlanFeature(item) {
                parsedResult.append(remoteFeature)
            }
        }

        return parsedResult
    }


    func parseWpcomPlan(_ item: EndpointResponse) -> RemotePlanDescription? {
        guard
            let groups = (item["groups"] as? [String])?.joined(separator: ","),
            let productsArray = item["products"] as? [EndpointResponse],
            let name = item["name"] as? String,
            let shortname = item["short_name"] as? String,
            let tagline = item["tagline"] as? String,
            let description = item["description"] as? String,
            let features = (item["features"] as? [String])?.joined(separator: ",") else {
                return nil
        }

        let products = parseWpcomPlanProducts(productsArray)

        return RemotePlanDescription(groups: groups,
                                     products: products,
                                     name: name,
                                     shortname: shortname,
                                     tagline: tagline,
                                     description: description,
                                     features: features)
    }


    func parsePlanGroup(_ item: EndpointResponse) -> RemotePlanGroup? {
        guard
            let slug = item["slug"] as? String,
            let name = item["name"] as? String else {
                return nil
        }
        return RemotePlanGroup(slug: slug, name: name)
    }


    func parsePlanFeature(_ item: EndpointResponse) -> RemotePlanFeature? {
        guard
            let slug = item["id"] as? String,
            let title = item["name"] as? String,
            let description = item["description"] as? String else {
                return nil
        }
        return RemotePlanFeature(slug: slug, title: title, description: description, iconURL: nil)
    }

}


private func mapPlansResponse(_ response: AnyObject) throws -> (activePlan: RemotePlan?, availablePlans: [RemotePlan]) {
    guard let json = response as? [[String: AnyObject]] else {
        throw PlanServiceRemote.ResponseError.decodingFailure
    }

    let parsedResponse: (RemotePlan?, [RemotePlan]) = try json.reduce((nil, []), {
        (result, planDetails: [String: AnyObject]) in
        guard let planId = planDetails["product_id"] as? Int,
            let title = planDetails["product_name_short"] as? String,
            let fullTitle = planDetails["product_name"] as? String,
            let tagline = planDetails["tagline"] as? String,
            let featureGroupsJson = planDetails["features_highlight"] as? [[String: AnyObject]] else {
            throw PlanServiceRemote.ResponseError.decodingFailure
        }

        guard let icon = planDetails["icon"] as? String,
            let iconUrl = URL(string: icon),
            let activeIcon = planDetails["icon_active"] as? String,
            let activeIconUrl = URL(string: activeIcon) else {
            return result
        }

        let productIdentifier = (planDetails["apple_sku"] as? String).flatMap({ $0.nonEmptyString() })
        let featureGroups = try parseFeatureGroups(featureGroupsJson)

        let plan = RemotePlan(id: planId, title: title, fullTitle: fullTitle, tagline: tagline, iconUrl: iconUrl, activeIconUrl: activeIconUrl, productIdentifier: productIdentifier, featureGroups: featureGroups)

        let plans = result.1 + [plan]
        if let isCurrent = planDetails["current_plan"] as? Bool,
            isCurrent {
            return (plan, plans)
        } else {
            return (result.0, plans)
        }
    })

    let activePlan = parsedResponse.0
    let availablePlans = parsedResponse.1
    return (activePlan, availablePlans)
}

private func parseFeatureGroups(_ json: [[String: AnyObject]]) throws -> [RemotePlanFeatureGroupPlaceholder] {
    return try json.compactMap { groupJson in
        guard let slugs = groupJson["items"] as? [String] else { throw PlanServiceRemote.ResponseError.decodingFailure }
        return RemotePlanFeatureGroupPlaceholder(title: groupJson["title"] as? String, slugs: slugs)
    }
}
