import Foundation
import WordPressShared
import CocoaLumberjack

public class PlanServiceRemote: ServiceRemoteWordPressComREST {
    public typealias AvailablePlans = (plans: [RemoteWpcomPlan], groups: [RemotePlanGroup], features: [RemotePlanFeature])

    typealias EndpointResponse =  [String: AnyObject]

    public enum ResponseError: Int, Error {
        // Error decoding JSON
        case decodingFailure
        // Depricated. An unsupported plan.
        case unsupportedPlan
        // Deprecated. No active plan identified in the results.
        case noActivePlan
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


    func parseWpcomPlans(_ response: EndpointResponse) -> [RemoteWpcomPlan] {
        var parsedResult = [RemoteWpcomPlan]()
        guard let json = response["plans"] as? [EndpointResponse] else {
            return parsedResult
        }

        for item in json {
            if let RemoteWpcomPlan = parseWpcomPlan(item) {
                parsedResult.append(RemoteWpcomPlan)
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


    func parseWpcomPlan(_ item: EndpointResponse) -> RemoteWpcomPlan? {
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

        return RemoteWpcomPlan(groups: groups,
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
