// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Conductor",
    products: [
        .executable(
            name: "Conductor",
            targets: ["Conductor"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/danger/swift.git", from: "3.10.1"),
        .package(url: "https://github.com/kylef/Commander.git", from: "0.9.2"),
        .package(url: "https://github.com/davecom/SwiftGraph.git", .branch("master")),
        .package(url: "https://github.com/jmmaloney4/Squall.git", .branch("master")),
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.6"),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", from: "1.9.5"),
        .package(url: "https://github.com/Wildchild9/LinkedList.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "Conductor",
            dependencies: ["Danger", "Commander", "SwiftGraph", "Squall", "Yams", "SwiftyBeaver", "LinkedList"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
