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
            url: "https://github.com/user-attachments/files/19949670/WordPressKit.zip",
            checksum: "69e4a2bec7a641336c4121c1ba23357b6222bf9db8353fe162328852780558ef"
        ),
    ]
)
