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
            url: "https://github.com/user-attachments/files/19339848/WordPressKit.zip",
            checksum: "5bf1ff361992dccf44dfe41b0a442ee4c3c13dc0a1ce9b647a8ed1b976b5c3fc"
        ),
    ]
)
