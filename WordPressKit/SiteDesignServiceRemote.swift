import Foundation

public struct SiteDesignRequest: Encodable {
    public let previewSize: CGSize?
    public let scale: CGFloat?

    public init(previewSize: CGSize? = nil, scale: CGFloat? = nil) {
        self.previewSize = previewSize
        self.scale = scale
    }

    public func asParameters() -> [String: AnyObject] {
        var parameters: [String: AnyObject] = [:]

        if let previewWidth = previewSize?.width {
            parameters["preview_width"] = previewWidth as AnyObject
        }

        if let scale = scale {
            parameters["scale"] = scale as AnyObject
        }

        return parameters
    }
}

public class SiteDesignServiceRemote {

    public typealias CompletionHandler = (Swift.Result<[RemoteSiteDesign], Error>) -> Void

    static let endpoint = "/rest/v1.1/nux/starter-designs"
    static let parameters: [String: AnyObject] = [
        "type": ("mobile" as AnyObject)
    ]

    private static func joinParameters(_ parameters: [String : AnyObject], additionalParameters: [String : AnyObject]?) -> [String: AnyObject] {
        guard let additionalParameters = additionalParameters else { return parameters }
        return parameters.reduce(into: additionalParameters, { (result, element) in
            result[element.key] = element.value
        })
    }

    public static func fetchSiteDesigns(_ api: WordPressComRestApi, request: SiteDesignRequest? = nil, completion: @escaping CompletionHandler) {
        let combinedParameters: [String: AnyObject] = joinParameters(parameters, additionalParameters: request?.asParameters())
        api.GET(endpoint, parameters: combinedParameters, success: { (responseObject, _) in
            do {
                let result = try parseLayouts(fromResponse: responseObject)
                completion(.success(result))
            } catch let error {
                completion(.failure(error))
            }
        }, failure: { (error, _) in
            completion(.failure(error))
        })
    }

    private static func parseLayouts(fromResponse response: Any) throws -> [RemoteSiteDesign] {
        let data = try JSONSerialization.data(withJSONObject: response)
        return try JSONDecoder().decode([RemoteSiteDesign].self, from: data)
    }
}
