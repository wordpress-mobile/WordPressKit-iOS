import Foundation

struct Post {
    let id: Int
    let title: String
    let slug: String


    let publishedAt: Date
    let modifiedAt: Date

    let status: String
    let type: String

    let authorId: Int

    let password: String

    let excerpt: String
    let content: String

    let parent: Int

    let link: URL

    let guid: String

    let menuOrder: Int

    let commentStatus: String

    let pingStatus: String

    let postFormat: String
}

struct User {
    let id: Int
}

struct Term {
    let id: Int
    let name: String
    let slug: String
    let group: Int
    let taxonomyId: Int
    let taxonomy: String
    let description: String
    let parentId: Int
    let count: Int

    let filter: String
}
