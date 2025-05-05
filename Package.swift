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
            url: "https://github.com/user-attachments/files/20038728/WordPressKit.zip",
            checksum: "7361289ba2ccef75d47dc8c6074072295812314b83194407864575faef1ae140"
        ),
    ]
)
