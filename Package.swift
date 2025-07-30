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
            url: "https://github.com/user-attachments/files/21518814/WordPressKit.zip",
            checksum: "a43e82909d851e78dff7fa64edba12635e2e96206c1fcdca075eae02dd4c157e"
        ),
    ]
)
