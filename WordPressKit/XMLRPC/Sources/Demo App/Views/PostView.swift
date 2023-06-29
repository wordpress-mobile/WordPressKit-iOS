import Foundation

import SwiftUI
import XMLRPC

struct PostView: View {

   public let post: WPPost

    var body: some View {
        HStack {
//            ScrollView {
                VStack(alignment: .leading) {
                    Text(post.date.formatted()).font(.body)
                    Text("Published by \(post.authorID)").font(.body)
                    if let content = post.content {
                        WebView(string: content)
                    }

                    Spacer()
                }.navigationTitle(post.title ?? "[Untitled Post]")
//            }
            Spacer()
        }

    }

    func refreshData() {

//        self.postRepository.fetchPosts(for: login)
    }
}

