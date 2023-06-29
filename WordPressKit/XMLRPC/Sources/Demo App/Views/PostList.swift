import SwiftUI
import XMLRPC

struct PostList: View {

    @Binding public var selection : WPPost?

    @EnvironmentObject
    var login: LoginRepository

    @EnvironmentObject
    var postRepository: PostRepository

    var body: some View {
        if postRepository.posts.isEmpty && postRepository.isFetchingPosts {
            ProgressView()
                .onAppear(perform: self.refreshData)
        } else {
            List(postRepository.posts, selection: $selection) { post in
                NavigationLink(value: post) {
                    Text(post.title ?? "[Untitled Post]")
                }
            }
            .navigationTitle("Posts")
            .onAppear(perform: self.refreshData)
        }
    }

    func refreshData() {
        guard let login = login.currentLogin else {
            return
        }

        do {
            try postRepository.fetchPosts(for: login)
        } catch {
            
        }
    }
}

