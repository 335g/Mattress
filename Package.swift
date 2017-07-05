// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Mattress",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Mattress",
            targets: ["Mattress"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "git@github.com:thoughtbot/Runes.git", .branch("swift-4"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Mattress",
            dependencies: ["Runes"],
            path: "Sources"),
        .testTarget(
            name: "MattressTests",
            dependencies: ["Mattress"]),
    ]
)
