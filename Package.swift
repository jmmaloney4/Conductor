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
        .package(url: "https://github.com/danger/swift.git", .exact("3.10.1")),
        .package(url: "https://github.com/kylef/Commander.git", .exact("0.9.1")),
        .package(url: "https://github.com/davecom/SwiftGraph.git", .revision("59414e26a0d48aece7d842720f24bdebddfe9ae9")),
        .package(url: "https://github.com/jmmaloney4/Squall.git", .revision("bbfdbe08df5e0364ddeaa3f092dba5e842f77d14")),
        .package(url: "https://github.com/jpsim/Yams.git", .exact("4.0.6")),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", .exact("1.9.0")),
    ],
    targets: [
        .target(
            name: "Conductor",
            dependencies: ["Danger", "Commander", "SwiftGraph", "Squall", "Yams", "SwiftyBeaver"]
        ),
    ]
)
