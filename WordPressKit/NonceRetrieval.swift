import Foundation

enum NonceRetrievalMethod {
    case newPostScrap
    case ajaxNonceRequest

    func buildURL(base: URL) -> URL? {
        switch self {
            case .newPostScrap:
                return URL(string: "post-new.php", relativeTo: base)
            case .ajaxNonceRequest:
                return URL(string: "admin-ajax.php?action=rest-nonce", relativeTo: base)
        }
    }

    func retrieveNonce(from html: String) -> String? {
        switch self {
            case .newPostScrap:
                return scrapNonceFromNewPost(html: html)
            case .ajaxNonceRequest:
                return readNonceFromAjaxAction(html: html)
        }
    }

    func scrapNonceFromNewPost(html: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: "apiFetch.createNonceMiddleware\\(\\s*['\"](?<nonce>\\w+)['\"]\\s*\\)", options: []),
            let match = regex.firstMatch(in: html, options: [], range: NSRange(location: 0, length: html.count)) else {
                return nil
        }
        let nsrange = match.range(withName: "nonce")
        let nonce = Range(nsrange, in: html)
            .map({ html[$0] })
            .map( String.init )

        return nonce
    }

    func readNonceFromAjaxAction(html: String) -> String? {
        guard !html.isEmpty else {
            return nil
        }
        return html
    }
}

