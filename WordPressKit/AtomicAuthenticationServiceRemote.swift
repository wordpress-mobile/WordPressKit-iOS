import Foundation

class AtomicAuthenticationServiceRemote: ServiceRemoteWordPressComREST {
    
    enum ResponseError: Error {
        case responseIsNotADictionary(response: AnyObject)
        case decodingFailure(response: [String: AnyObject])
        case couldNotInstantiateCookie(name: String, value: String, domain: String, path: String, expires: Date)
    }
    
    func getAuthCookie(
        siteID: Int,
        success: @escaping (_ cookie: HTTPCookie) -> Void,
        failure: @escaping (Error) -> Void) {
        
        let endpoint = "sites/\(siteID)/atomic-auth-proxy/read-access-cookies"
        let path = self.path(forEndpoint: endpoint, withVersion: ._2_0)

        wordPressComRestApi.GET(path,
                parameters: nil,
                success: {
                    responseObject, httpResponse in

                    do {
                        let settings = try self.cookie(from: responseObject)
                        success(settings)
                    } catch {
                        failure(error)
                    }
            },
                failure: { error, httpResponse in
                    failure(error)
        })
    }

    // MARK: - Result Parsing
    
    private func date(from expiration: Int) -> Date {
        return Date(timeIntervalSince1970: TimeInterval(expiration))
    }
    
    private func cookie(from responseObject: AnyObject) throws -> HTTPCookie {
        guard let response = responseObject as? [String: AnyObject] else {
            let error = ResponseError.responseIsNotADictionary(response: responseObject)
            DDLogError("❗️Error: \(error)")
            throw error
        }
        
        guard let cookies = response["cookies"] as? [[String: Any]] else {
            let error = ResponseError.decodingFailure(response: response)
            DDLogError("❗️Error: \(error)")
            throw error
        }

        let cookieDictionary = cookies[0]

        guard let name = cookieDictionary["name"] as? String,
            let value = cookieDictionary["value"] as? String,
            let domain = cookieDictionary["domain"] as? String,
            let path = cookieDictionary["path"] as? String,
            let expires = cookieDictionary["expires"] as? Int else {

                let error = ResponseError.decodingFailure(response: response)
                DDLogError("❗️Error: \(error)")
                throw error
        }
        
        let expirationDate = date(from: expires)

        guard let cookie = HTTPCookie(properties: [
            .name: name,
            .value: value,
            .domain: domain,
            .path: path,
            .expires: expirationDate,
        ]) else {
            let error = ResponseError.couldNotInstantiateCookie(name: name, value: value, domain: domain, path: path, expires: expirationDate)
            DDLogError("❗️Error: \(error)")
            throw error
        }
        
        return cookie
    }
}
