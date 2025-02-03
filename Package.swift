// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "WordPressKit",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "WordPressKit", targets: ["WordPressKit"]),
    ],
    targets: [
        .binaryTarget(
            name: "WordPressKit",
            url: "https://github.com/user-attachments/files/18646293/WordPressKit.zip",
            checksum: "eb801860f5ce489390dd5a50fbd05cb3942dec8350b3665bc51c036fd669432f"
        ),
    ]
)
