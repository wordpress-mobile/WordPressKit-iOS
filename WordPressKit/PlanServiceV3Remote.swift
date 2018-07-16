import Foundation
import WordPressShared
import CocoaLumberjack

@objc public class PlanServiceV3Remote: ServiceRemoteWordPressComREST {

    public typealias SitePlans = (activePlan: RemotePlanDetail, availablePlans: [RemotePlanDetail])

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
                    try success(PlanServiceV3Remote.mapPlansResponse(response))
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
    
    private static func mapPlansResponse(
        _ response: AnyObject
        ) throws
        -> (activePlan: RemotePlanDetail, availablePlans: [RemotePlanDetail]) {

        guard let json = response as? [String: AnyObject] else {
            throw PlanServiceRemote.ResponseError.decodingFailure
        }

        var activePlans: [RemotePlanDetail] = []
        var currentlyActivePlan: RemotePlanDetail?

        try json.forEach { (key, value) in
            let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
            do {
                let decodedResult = try JSONDecoder.apiDecoder.decode(RemotePlanDetail.self, from: data)
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
