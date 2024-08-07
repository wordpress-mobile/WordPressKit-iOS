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
            url: "https://github.com/user-attachments/files/16531883/WordPressKit.zip",
            checksum: "ca916824c64a6061814a69a37bc9a6560aafcc35559983e945fdfa5c3bbcc23d"
        ),
    ]
)
