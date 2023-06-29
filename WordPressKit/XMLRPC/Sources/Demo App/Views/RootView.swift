import SwiftUI
import XMLRPC

struct RootView: View {

    @State
    private var selection: WPPost?

    @EnvironmentObject
    private var login: LoginRepository

    var body: some View {
        NavigationSplitView(sidebar: {
            if login.currentLogin != nil {
                PostList(selection: $selection)
            }
        }, detail: {
            if let post = selection {
                PostView(post: post)
            } else {
                Text("Select a Post")
            }
        })
    }
}

