import Foundation

public class BlockEditorSettingsServiceRemote {
    let remoteAPI: WordPressRestApi
    public init(remoteAPI: WordPressRestApi) {
        self.remoteAPI = remoteAPI
    }
}

// MARK: Editor `theme_supports` support
public extension BlockEditorSettingsServiceRemote {
    typealias EditorThemeCompletionHandler = (Swift.Result<RemoteEditorTheme?, Error>) -> Void

    func fetchTheme(forSiteID siteID: Int?, _ completion: @escaping EditorThemeCompletionHandler) {
        let requestPath = "/wp/v2/themes"
        let parameters: [String: AnyObject] = ["status": "active" as AnyObject]
        let modifiedPath = remoteAPI.requestPath(fromOrgPath: requestPath, with: siteID)
        remoteAPI.GET(modifiedPath, parameters: parameters) { [weak self] (result, _) in
            guard let `self` = self else { return }
            switch result {
            case .success(let response):
                self.processEditorThemeResponse(response) { editorTheme in
                    completion(.success(editorTheme))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func processEditorThemeResponse(_ response: Any, completion: (_ editorTheme: RemoteEditorTheme?) -> Void) {
        guard let responseData = try? JSONSerialization.data(withJSONObject: response, options: []),
              let editorThemes = try? JSONDecoder().decode([RemoteEditorTheme].self, from: responseData) else {
            completion(nil)
            return
        }
        completion(editorThemes.first)
    }

}

// MARK: Editor Global Styles support
public extension BlockEditorSettingsServiceRemote {
    typealias BlockEditorSettingsCompletionHandler = (Swift.Result<RemoteBlockEditorSettings?, Error>) -> Void

    func fetchBlockEditorSettings(_ completion: @escaping BlockEditorSettingsCompletionHandler) {
        let requestPath = "/__experimental/wp-block-editor/v1/settings"
        let parameters: [String: AnyObject] = ["context": "mobile" as AnyObject]
        remoteAPI.GET(requestPath, parameters: parameters) { [weak self] (result, _) in
            guard let `self` = self else { return }
            switch result {
            case .success(let response):
                self.processBlockEditorSettingsResponse(response) { blockEditorSettings in
                    completion(.success(blockEditorSettings))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func processBlockEditorSettingsResponse(_ response: Any, completion: (_ editorTheme: RemoteBlockEditorSettings?) -> Void) {
        guard let responseData = try? JSONSerialization.data(withJSONObject: response, options: []),
              let blockEditorSettings = try? JSONDecoder().decode(RemoteBlockEditorSettings.self, from: responseData) else {
            completion(nil)
            return
        }
        completion(blockEditorSettings)
    }
}
