import SwiftUI
import XMLRPC
import SwiftKeychainWrapper

class LoginRepository: ObservableObject {
    @Published
    var isAttemptingLogin: Bool = false

    @Published
    var username: String = ""

    @Published
    var password: String = ""

    @Published
    var error: Error?

    @Published
    var currentLogin: Login?

    @Published
    var needsLogin: Bool = true

    private let keychainWrapper = KeychainWrapper.standard

    @MainActor
    init() {
        self.refreshLogin()
    }

    @MainActor
    func refreshLogin() {

//        guard
//            let username = UserDefaults.standard.string(forKey: "current-user"),
//            let password = KeychainWrapper(serviceName: username).string(forKey: "xmlrpc-password")
//        else {
//            self.needsLogin = true
//            return
//        }

        self.needsLogin = false
        self.currentLogin = Login(blogID: 0, username: "WP_USER", password: "WP_PASSWORD")
    }

    @MainActor
    func persistLogin() {
        UserDefaults.standard.set(self.username, forKey: "current-user")
        let keychain = KeychainWrapper(serviceName: self.username)
        precondition(keychain.set(self.password, forKey: "xmlrpc-password"))
    }

    func tryLogin() {
        self.isAttemptingLogin = true

        Task {
            do {
                let request = GetProfileRequest(login: Login(blogID: 0, username: self.username, password: self.password))
                let response = try await XMLRPC.Client(endpoint: URL(string: "http://localhost/xmlrpc.php")!).perform(request: request)

                _ = try UserResponseProcessor().process(response)

                await self.persistLogin()
                await self.refreshLogin()

                await MainActor.run {
                    self.error = nil
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
            }

            await MainActor.run {
                self.isAttemptingLogin = false
            }
        }
    }
}
