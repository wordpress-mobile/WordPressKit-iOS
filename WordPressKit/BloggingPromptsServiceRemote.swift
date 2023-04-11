/// Encapsulates logic to fetch blogging prompts from the remote endpoint.
///
open class BloggingPromptsServiceRemote: ServiceRemoteWordPressComREST {
    /// Used to format dates so the time information is omitted.
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"

        return formatter
    }()

    public enum RequestError: Error {
        case encodingFailure
    }

    /// Fetches a number of blogging prompts for the specified site.
    /// Note that this method hits wpcom/v3, which means the `WordPressComRestAPI` needs to be initialized with `LocaleKeyV2`.
    ///
    /// - Parameters:
    ///   - siteID: Used to check which prompts have been answered for the site with given `siteID`.
    ///   - number: The number of prompts to query. When not specified, this will default to remote implementation.
    ///   - fromDate: When specified, this will fetch prompts from the given date. When not specified, this will default to remote implementation.
    ///   - ignoresYear: When set to true, this will convert the date to a custom format that ignores the year part. Defaults to false.
    ///   - completion: A closure that will be called when the fetch request completes.
    open func fetchPrompts(for siteID: NSNumber,
                           number: Int? = nil,
                           fromDate: Date? = nil,
                           ignoresYear: Bool = false,
                           completion: @escaping (Result<[RemoteBloggingPrompt], Error>) -> Void) {
        let path = path(forEndpoint: "sites/\(siteID)/blogging-prompts", withVersion: ._3_0)
        let requestParameter: [String: AnyHashable] = {
            var params = [String: AnyHashable]()

            if let number, number > 0 {
                params["per_page"] = number
            }

            if let fromDate {
                // convert to yyyy-MM-dd format, excluding the timezone information.
                // the date parameter doesn't need to be timezone-accurate since prompts are grouped by date.
                var dateString = Self.dateFormatter.string(from: fromDate)

                // when the year needs to be ignored, we'll transform the dateString to match the "--mm-dd" format.
                if ignoresYear, !dateString.isEmpty {
                    dateString = "-" + dateString.dropFirst(4)
                }

                params["after"] = dateString
            }

            return params
        }()

        wordPressComRestApi.GET(path, parameters: requestParameter as [String: AnyObject]) { result, _ in
            switch result {
            case .success(let responseObject):
                do {
                    let data = try JSONSerialization.data(withJSONObject: responseObject, options: [])
                    let decoder = JSONDecoder.apiDecoder
                    // our API decoder assumes that we're converting from snake case.
                    // revert it to default so the CodingKeys match the actual response keys.
                    decoder.keyDecodingStrategy = .useDefaultKeys
                    let response = try decoder.decode([RemoteBloggingPrompt].self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Fetches the blogging prompts settings for a given site.
    ///
    /// - Parameters:
    ///   - siteID: The site ID for the blogging prompts settings.
    ///   - completion: Closure that will be called when the request completes.
    open func fetchSettings(for siteID: NSNumber, completion: @escaping (Result<RemoteBloggingPromptsSettings, Error>) -> Void) {
        let path = path(forEndpoint: "sites/\(siteID)/blogging-prompts/settings", withVersion: ._2_0)
        wordPressComRestApi.GET(path, parameters: nil) { result, _ in
            switch result {
            case .success(let responseObject):
                do {
                    let data = try JSONSerialization.data(withJSONObject: responseObject)
                    let settings = try JSONDecoder().decode(RemoteBloggingPromptsSettings.self, from: data)
                    completion(.success(settings))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Updates the blogging prompts settings to remote.
    ///
    /// This will return an updated settings object if at least one of the fields is successfully modified.
    /// If nothing has changed, it will still be regarded as a successful operation; but nil will be returned.
    ///
    /// - Parameters:
    ///   - siteID: The site ID of the blogging prompts settings.
    ///   - settings: The updated settings to upload.
    ///   - completion: Closure that will be called when the request completes.
    open func updateSettings(for siteID: NSNumber,
                             with settings: RemoteBloggingPromptsSettings,
                             completion: @escaping (Result<RemoteBloggingPromptsSettings?, Error>) -> Void) {
        let path = path(forEndpoint: "sites/\(siteID)/blogging-prompts/settings", withVersion: ._2_0)
        var parameters = [String: AnyObject]()
        do {
            let data = try JSONEncoder().encode(settings)
            parameters = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject] ?? [:]
        } catch {
            completion(.failure(error))
            return
        }

        // The parameter shouldn't be empty at this point.
        // If by some chance it is, let's abort and return early. There could be something wrong with the parsing process.
        guard !parameters.isEmpty else {
            WPKitLogError("Error encoding RemoteBloggingPromptsSettings object: \(settings)")
            completion(.failure(RequestError.encodingFailure))
            return
        }

        wordPressComRestApi.POST(path, parameters: parameters) { responseObject, _ in
            do {
                let data = try JSONSerialization.data(withJSONObject: responseObject)
                let response = try JSONDecoder().decode(UpdateBloggingPromptsSettingsResponse.self, from: data)
                completion(.success(response.updated))
            } catch {
                completion(.failure(error))
            }
        } failure: { error, _ in
            completion(.failure(error))
        }
    }
}

// MARK: - Private helpers

private extension BloggingPromptsServiceRemote {
    /// An intermediate object representing the response structure after updating the prompts settings.
    ///
    /// If there is at least one updated field, the remote will return the full `RemoteBloggingPromptsSettings` object in the `updated` key.
    /// Otherwise, if no fields are changed, the remote will assign an empty array to the `updated` key.
    struct UpdateBloggingPromptsSettingsResponse: Decodable {
        let updated: RemoteBloggingPromptsSettings?

        private enum CodingKeys: String, CodingKey {
            case updated
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            // return nil when no fields are changed.
            if let _ = try? container.decode(Array.self, forKey: .updated) {
                self.updated = nil
                return
            }

            self.updated = try container.decode(RemoteBloggingPromptsSettings.self, forKey: .updated)
        }
    }
}
