// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XMLRPC",
    platforms: [
        .iOS(.v12),
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "XMLRPC",
            targets: ["XMLRPC"]
        ),
        .executable(
            name: "Demo App",
            targets: ["Demo App"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/wordpress-mobile/wpxmlrpc", from: "0.9.0"),
        .package(url: "https://github.com/jrendel/SwiftKeychainWrapper", from: "4.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "XMLRPC",
            dependencies: ["wpxmlrpc"]),
        .executableTarget(
            name: "Demo App",
            dependencies: ["XMLRPC", "SwiftKeychainWrapper"],
            linkerSettings: [
                .unsafeFlags(["-sectcreate", "__TEXT", "__info_plist", "Sources/Demo App/Resources/Info.plist"])
            ]
        ),

        .testTarget(
            name: "UnitTests",
            dependencies: ["XMLRPC"],
            resources: [
                .copy("Test Data/_components/struct/PostQuery.xml"),

                .copy("Test Data/post/delete-post.xml"),
                .copy("Test Data/post/get-post-type.xml"),
                .copy("Test Data/post/get-post-types.xml"),
                .copy("Test Data/post/get-post.xml"),
                .copy("Test Data/post/get-posts-with-count.xml"),
                .copy("Test Data/post/get-posts-with-page-type.xml"),
                .copy("Test Data/post/get-posts-with-post-type.xml"),
                .copy("Test Data/post/get-posts.xml"),

                .copy("Test Data/posts-response.xml"),
            ]
        ),
        .testTarget(
            name: "e2eTests",
            dependencies: ["XMLRPC"]
        )
    ]
)
