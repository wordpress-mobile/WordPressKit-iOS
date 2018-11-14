import Foundation
import WordPressShared
import CocoaLumberjack

@objc public class TransactionsServiceRemote: ServiceRemoteWordPressComREST {

    public enum ResponseError: Error {
        case decodingFailure
    }

    private enum Constants {
        static let privateRegistrationProductID = 16
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

        let productsArray: [[String: AnyObject]]

        let productDictionary: [String: AnyObject] = ["product_id": domainSuggestion.productID as AnyObject,
                                                      "meta": domainSuggestion.domainName as AnyObject]

        if privacyProtectionEnabled {
            let privacyProduct: [String: AnyObject] = ["product_id": Constants.privateRegistrationProductID as AnyObject,
                                                       "meta": domainSuggestion.domainName as AnyObject]

            productsArray = [productDictionary, privacyProduct]
        } else {
            productsArray = [productDictionary]
        }

        let parameters: [String: AnyObject] = ["temporary": "true" as AnyObject,
                                               "products": productsArray as AnyObject]

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

public struct CartResponse: Codable {
    let blogID: Int
    let cartKey: String
    let products: [Product]

    init?(jsonDictionary: [String: AnyObject]) {
        guard let cartKey = jsonDictionary["cart_key"] as? String,
                let blogID = jsonDictionary["blog_id"] as? Int,
                let products = jsonDictionary["products"] as? [[String: AnyObject]] else {
                return nil
        }

        let mappedProducts = products.compactMap { (product) -> Product? in
            guard let productID = product["product_id"] as? Int,
                let meta = product["meta"] as? String else {
                    return nil
            }

            return Product(productID: productID, meta: meta)
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
                "products": products.map { return ["product_id": $0.productID, "meta": $0.meta] } as AnyObject ]
    }
}

public struct Product: Codable {
    let productID: Int
    let meta: String
}
