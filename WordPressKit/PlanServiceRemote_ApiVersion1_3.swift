import Foundation
import WordPressShared
import CocoaLumberjack

@objc public class PlanServiceRemote_ApiVersion1_3: ServiceRemoteWordPressComREST {

    public typealias SitePlans = (activePlan: RemotePlan_ApiVersion1_3, availablePlans: [RemotePlan_ApiVersion1_3])

    @objc public func getPlansForSite(_ siteID: Int,
                                      success: @escaping (SitePlans) -> Void,
                                      failure: @escaping (Error) -> Void) {
        let endpoint = "sites/\(siteID)/plans"
        let path = self.path(forEndpoint: endpoint, withVersion: ._1_3)
        let locale = WordPressComLanguageDatabase().deviceLanguage.slug
        let parameters = ["locale": locale]
        wordPressComRestApi.GET(
            path,
            parameters: parameters as [String : AnyObject]?,
            success: {
                response, _ in
                do {
                    try success(PlanServiceRemote_ApiVersion1_3.mapPlansResponse(response))
                } catch {
                    DDLogError("Error parsing plans response for site \(siteID)")
                    DDLogError("\(error)")
                    DDLogDebug("Full response: \(response)")
                    failure(error)
                }
            },
            failure: {
                error, _ in
                failure(error)
            }
        )
    }
    
    private static func mapPlansResponse(_ response: AnyObject) throws
        -> (activePlan: RemotePlan_ApiVersion1_3, availablePlans: [RemotePlan_ApiVersion1_3]) {

        guard let json = response as? [String: AnyObject] else {
            throw PlanServiceRemote.ResponseError.decodingFailure
        }

        var activePlans: [RemotePlan_ApiVersion1_3] = []
        var currentlyActivePlan: RemotePlan_ApiVersion1_3?

        try json.forEach { (key, value) in
            let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
            do {
                let decodedResult = try JSONDecoder.apiDecoder.decode(RemotePlan_ApiVersion1_3.self, from: data)
                decodedResult.planID = key
                activePlans.append(decodedResult)
                if decodedResult.isCurrentPlan {
                    currentlyActivePlan = decodedResult
                }
            } catch let error {
                DDLogError("Error parsing plans response for site \(error)")
            }
        }

        guard let activePlan = currentlyActivePlan else {
            throw PlanServiceRemote.ResponseError.noActivePlan
        }
        return (activePlan, activePlans)
    }

}
