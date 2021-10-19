import Combine
import Foundation

/// Provides information about available products for user purchases, such as plans, domains, etc.
///
open class ProductServiceRemote {
    let serviceRemote: ServiceRemoteWordPressComREST

    public init(restAPI: WordPressComRestApi) {
        serviceRemote = ServiceRemoteWordPressComREST(wordPressComRestApi: restAPI)
    }

    /// Gets a list of available products for purchase.
    ///
    open func getProducts(completion: @escaping (Result<Any, Error>) -> Void) {
        let path = serviceRemote.path(forEndpoint: "products", withVersion: ._1_1)

        serviceRemote.wordPressComRestApi.GET(
            path,
            parameters: [:]) { result, response in

            switch result {
            case .success(let products):
                completion(.success(products))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
