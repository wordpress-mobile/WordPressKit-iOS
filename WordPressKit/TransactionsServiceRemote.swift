import Foundation
import WordPressShared
import CocoaLumberjack

@objc public class TransactionsServiceRemote: ServiceRemoteWordPressComREST {

    public enum ResponseError: Error {
        case decodingFailure
    }

    private enum Constants {
        static let freeDomainPaymentMethod = "WPCOM_Billing_WPCOM"
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
                                   privacyProtectionEnabled: Bool,
                                   success: @escaping (CartResponse) -> Void,
                                   failure: @escaping (Error) -> Void) {

        let endPoint = "me/shopping-cart/\(siteID)"
        let urlPath = path(forEndpoint: endPoint, withVersion: ._1_1)

        var productDictionary: [String: AnyObject] = ["product_id": domainSuggestion.productID as AnyObject,
                                                      "meta": domainSuggestion.domainName as AnyObject]

        if privacyProtectionEnabled {
            productDictionary["extra"] = ["privacy": true] as AnyObject
        }

        let parameters: [String: AnyObject] = ["temporary": "true" as AnyObject,
                                               "products": [productDictionary] as AnyObject]

        wordPressComRestApi.POST(urlPath,
                                 parameters: parameters,
                                 success: { (response, _) in


                                    guard let jsonResponse = response as? [String: AnyObject],
                                        let cart = CartResponse(jsonDictionary: jsonResponse),
                                        !cart.products.isEmpty else {
                                            
                                        failure(TransactionsServiceRemote.ResponseError.decodingFailure)
                                        return
                                    }

                                    success(cart)
        }) { (error, response) in
            failure(error)
        }


    }

    public func redeemCartUsingCredits(cart: CartResponse,
                                       domainContactInformation: [String: String],
                                       success: @escaping () -> Void,
                                       failure: @escaping (Error) -> Void) {

        let endPoint = "me/transactions"

        let urlPath = path(forEndpoint: endPoint, withVersion: ._1_1)

        let paymentDict = ["payment_method": Constants.freeDomainPaymentMethod]

        let parameters: [String: AnyObject] = ["domain_details": domainContactInformation as AnyObject,
                                               "cart": cart.jsonRepresentation() as AnyObject,
                                               "payment": paymentDict as AnyObject]

        wordPressComRestApi.POST(urlPath, parameters: parameters, success: { (response, _) in
            success()
        }) { (error, response) in
            failure(error)
        }
    }
}

public struct CartResponse {
    let blogID: Int
    let cartKey: String
    let products: [Product]

    init?(jsonDictionary: [String: AnyObject]) {
        guard
            let cartKey = jsonDictionary["cart_key"] as? String,
            let blogID = jsonDictionary["blog_id"] as? Int,
            let products = jsonDictionary["products"] as? [[String: AnyObject]]
            else {
                return nil
        }

        let mappedProducts = products.compactMap { (product) -> Product? in
            guard
                let productID = product["product_id"] as? Int,
                let meta = product["meta"] as? String
                else {
                    return nil
            }

            let extra = product["extra"] as? [String: AnyObject]

            return Product(productID: productID, meta: meta, extra: extra)
        }

        guard mappedProducts.count == products.count else {
            return nil
        }

        self.blogID = blogID
        self.cartKey = cartKey
        self.products = mappedProducts
    }

    fileprivate func jsonRepresentation() -> [String: AnyObject] {
        return ["blog_id": blogID as AnyObject,
                "cart_key": cartKey as AnyObject,
                "products": products.map { $0.jsonRepresentation() } as AnyObject]

    }
}

public struct Product {
    let productID: Int
    let meta: String
    let extra: [String: AnyObject]?

    fileprivate func jsonRepresentation() -> [String: AnyObject] {
        var returnDict: [String: AnyObject] = [:]

        returnDict["product_id"] = productID as AnyObject
        returnDict["meta"] = meta as AnyObject


        if let extra = extra {
            returnDict["extra"] = extra as AnyObject
        }

        return returnDict
    }
}

