// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Conductor",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .executable(
            name: "Conductor",
            targets: ["Conductor"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/danger/swift.git", from: "3.10.1"),
        .package(url: "https://github.com/kylef/Commander.git", from: "0.9.1"),
        .package(url: "https://github.com/davecom/SwiftGraph.git", .branch("master")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Conductor",
            dependencies: ["Danger", "Commander", "SwiftGraph"]
        ),
        .testTarget(
            name: "ConductorTests",
            dependencies: ["Conductor"]
        ),
    ]
)
