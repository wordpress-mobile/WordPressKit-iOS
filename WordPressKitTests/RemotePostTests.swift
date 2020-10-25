//
//  RemotePostTests.swift
//  WordPressKitTests
//
//  Created by Declan McKenna on 19/10/2020.
//  Copyright © 2020 Automattic Inc. All rights reserved.
//

import XCTest
@testable import WordPressKit

class RemotePostTests: XCTestCase {

    func testHashWithNilValues() {
        XCTAssertEqual(RemotePost().contentHash(), RemotePost().contentHash())
    }

    func testHashWithNilValuesIsPersistent() {
        let expectedHash = "72bcdd41f59ecd51f66ada667342a04765ff8f17997a4d48ea708e6eabbf5580"
        XCTAssertEqual(RemotePost().contentHash(), expectedHash)
    }

    func testRemotePostHashIsSameForSameContent() {
        let post = noNullPropertyPost
        let identicalPost = noNullPropertyPost
        XCTAssertEqual(post.contentHash(), identicalPost.contentHash())
    }

    func testRemotePostHashDiffersForDifferentContent() {
        let post = noNullPropertyPost
        let modifiedPost = noNullPropertyPost
        modifiedPost.tags.append("new tag")
        XCTAssertNotEqual(post.contentHash(), modifiedPost.contentHash())
    }

    func testRemotePostHashIsPersistent() {
        let post = noNullPropertyPost
        let expectedHash = "729a3df7c916699c5efb548dc4f53f43dec11d5516dd63ff6787c81904d464f1"
        XCTAssertEqual(post.contentHash(), expectedHash)
    }
}

private extension RemotePostTests {
    /// Remote post with all properties set to non null to ensure hash is consistent for all fields
    var noNullPropertyPost: RemotePost {
        let remotePost = RemotePost()
        remotePost.postID = 90210
        remotePost.siteID = 101
        remotePost.authorAvatarURL = "www.test.com"
        remotePost.authorDisplayName = "jk"
        remotePost.authorEmail = "omg@somuchtestdata.com"
        remotePost.authorURL = "swiftdec.com"
        remotePost.authorID = 9001
        remotePost.date = Date(timeIntervalSince1970: 0)
        remotePost.title = "Lorem Ipsum"
        remotePost.url = URL(string: "lemonparty.com")
        remotePost.shortURL = URL(string: "www.why.com")
        remotePost.content = "Dolor Sit Amet"
        remotePost.excerpt = "...."
        remotePost.slug = "lorem-ipsum"
        remotePost.suggestedSlug = "~!!"
        remotePost.status = "draft"
        remotePost.parentID = 42
        remotePost.postThumbnailID = 420
        remotePost.postThumbnailPath = "Arakis"
        remotePost.type = ""
        remotePost.format = ""
        remotePost.commentCount = 666
        remotePost.likeCount = 555
        remotePost.tags = ["lorem,ipsum,test"]
        remotePost.pathForDisplayImage = "!.com"
        remotePost.isStickyPost = true
        remotePost.isFeaturedImageChanged = false
        return remotePost
    }
}
