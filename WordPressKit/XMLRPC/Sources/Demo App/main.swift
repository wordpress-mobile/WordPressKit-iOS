import Foundation
import SwiftUI
import XMLRPC

struct ListItem: Identifiable, Hashable {
    let id: String
    let value: String
}

struct DemoApp: App {

    @StateObject
    var loginRepository = LoginRepository()

    @StateObject
    var postRepository = PostRepository()

    @State
    private var error: Error!

    @State
    var hasError: Bool = false

    var body: some Scene {
        WindowGroup {
            RootView()
                .sheet(isPresented: $loginRepository.needsLogin, onDismiss: self.reloadData, content: LoginView.init)
                .environmentObject(loginRepository)
                .environmentObject(postRepository)
                .alert("An Error has Occured", isPresented: $hasError) {

                }

        }
    }

    func reloadData() {
        guard let login = loginRepository.currentLogin else {
            return
        }

        do {
            try postRepository.fetchPosts(for: login)
        } catch {
            self.error = error
            self.hasError = true
        }
    }
}

DispatchQueue.main.async {
    let app = NSApplication.shared
    app.setActivationPolicy(.regular)
    app.activate(ignoringOtherApps: true)

}

DemoApp.main()
