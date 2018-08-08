import Foundation
import WordPressShared
import CocoaLumberjack

@objc public class TransactionsServiceRemote: ServiceRemoteWordPressComREST {
    
    public enum ResponseError: Error {
        case decodingFailure
    }
    
    @objc public func getSupportedCountries(success: @escaping ([Country]) -> Void,
                                            failure: @escaping (Error) -> Void) {
        let endPoint = "me/transactions/supported-countries/"
        let servicePath = path(forEndpoint: endPoint, withVersion: ._1_1)
        
        wordPressComRestApi.GET(servicePath,
                                parameters: nil,
                                success: {
                                    response, _ in
                                    do {
                                        guard let json = response as? [AnyObject] else {
                                            throw ResponseError.decodingFailure
                                        }
                                        let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                                        let decodedResult = try JSONDecoder.apiDecoder.decode([Country].self, from: data)
                                        success(decodedResult)
                                    } catch {
                                        DDLogError("Error parsing Supported Countries (\(error)): \(response)")
                                        failure(error)
                                    }
        }, failure: { error, _ in
            failure(error)
        })
    }
}
