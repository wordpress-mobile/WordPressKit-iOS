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
            url: "https://github.com/user-attachments/files/19315257/WordPressKit.zip",
            checksum: "1b4ba5cef01a64e98ffdc02a5c8ac92f550f234222bfb6abf11b4b4df94435bc"
        ),
    ]
)
