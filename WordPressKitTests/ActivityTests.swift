@testable import WordPressKit
import XCTest

class ActivityTests: XCTestCase {

    func testActivityDecoding() throws {
        let x = try XCTUnwrap(activityLogComment.data(using: .utf8))
        let y = try JSONDecoder().decode(Activity.self, from: x)
        XCTAssertEqual(y.activityID, "id-123")
    }
}

private let activityLogComment: String = """
{
    "activityId": "id-123",
    "summary": "Comment approved",
    "content": {
        "text": "Comment by aaaaaaaaaa on Hola Lima! 🇵🇪: Great post! True talent!",
        "ranges": [
                   {
                   "url": "https://wordpress.com/comment/137726971/7",
                   "indices": [
                               0,
                               7
                               ],
                   "site_id": 137726971,
                   "root_id": 441,
                   "section": "comment",
                   "intent": "edit",
                   "id": 7
                   },
                   {
                   "url": "https://wordpress.com/edit/post/137726971/441",
                   "indices": [
                               25,
                               40
                               ],
                   "site_id": 137726971,
                   "section": "post",
                   "intent": "edit",
                   "context": "single",
                   "id": 441
                   }
                   ]
    },
    "name": "comment__approved",
    "actor": {
        "type": "Person",
        "name": "etoledom",
        "external_user_id": 0,
        "wpcom_user_id": 129935412,
        "icon": {
            "type": "Image",
            "url": "https://secure.gravatar.com/avatar/8e06b8f61330e7bc0e5eb4e67aa68e0f?s=96&d=identicon&r=g",
            "width": 96,
            "height": 96
        },
        "role": "administrator"
    },
    "type": "Accept",
    "published": "2018-06-29T20:38:55.277+00:00",
    "generator": {
        "jetpack_version": 0,
        "blog_id": 137726971
    },
    "is_rewindable": false,
    "rewind_id": "1530304735.2771",
    "gridicon": "comment",
    "status": null,
    "activity_id": "AWRNRTAUjEqjFGbx8DZj",
    "object": {
        "type": "Comment",
        "object_id": 7
    },
    "target": {
        "type": "Article",
        "name": "Hola Lima! 🇵🇪",
        "post_id": 229,
        "post_type": "post",
        "post_status": "publish"
    },
    "is_discarded": false
}
"""
