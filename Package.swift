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
            url: "https://github.com/user-attachments/files/18891163/WordPressKit.zip",
            checksum: "a768cf1578321fbda9bcbd025f00697773f9dc978a31b7ae9174c310a20596f8"
        ),
    ]
)
