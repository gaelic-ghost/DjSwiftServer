// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DjSwiftServer",
    platforms: [
        .macOS("15.0"),
    ],
    dependencies: [
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "DjSwiftServer",
            dependencies: [
                .product(name: "Hummingbird", package: "hummingbird"),
            ],
        ),
        .testTarget(
            name: "DjSwiftServerTests",
            dependencies: ["DjSwiftServer", .product(name: "HummingbirdTesting", package: "hummingbird")],
        ),
    ],
    swiftLanguageModes: [.v6],
)
