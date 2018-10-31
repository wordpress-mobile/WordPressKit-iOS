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

    public func createShoppingCart(siteID: Int,
                                   domainSuggestion: DomainSuggestion,
                                   success: @escaping (String) -> Void,
                                   failure: @escaping (Error) -> Void) {

        let endPoint = "me/shopping-cart/\(siteID)"
        let urlPath = path(forEndpoint: endPoint, withVersion: ._1_1)

        let productsArray = [["product_id": domainSuggestion.productID,
                              "meta": domainSuggestion.domainName]]

        let parameters: [String: AnyObject] = ["temporary": "false" as AnyObject,
                                               "products": productsArray as AnyObject]

        wordPressComRestApi.POST(urlPath,
                                 parameters: parameters,
                                 success: { (response, _) in
                                    guard let cartKey = response["cart_key"] as? String else {
                                        failure(TransactionsServiceRemote.ResponseError.decodingFailure)
                                        return
                                    }

                                    success(cartKey)
        }) { (error, response) in
            failure(error)
        }


    }

    public func redeemCartUsingCredits(cartID: String,
                                       success: @escaping (Void) -> Void,
                                       failure: @escaping (Error) -> Void) {

        let endPoint = "me/transactions"

        let urlPath = path(forEndpoint: endPoint, withVersion: ._1_1)

        let paymentDict = ["payment_method": "WPCOM_Billing_WPCOM"]
        let parameters: [String: AnyObject] = ["cart": cartID as AnyObject,
                                               "payment": paymentDict as AnyObject]

        wordPressComRestApi.POST(urlPath, parameters: parameters, success: { (response, _) in
            success(())
        }) { (error, response) in
            failure(error)
        }
    }
}
