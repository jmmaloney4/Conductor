// swift-tools-version:4.0
// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import PackageDescription

let package = Package(
    name: "Conductor",
    products: [
        .library(name: "ConductorCore", targets: ["ConductorCore"]),
        .executable(name: "Conductor", targets: ["Conductor"])
    ],
    dependencies: [
        .package(url: "https://github.com/jmmaloney4/CommandLine.git", from: "3.1.1"),
        
        .package(url: "https://github.com/jmmaloney4/Squall.git", from: "1.2.3"),
        .package(url: "https://github.com/davecom/SwiftPriorityQueue.git", from: "1.1.2"),
        .package(url: "https://github.com/IBM-Swift/SwiftyJSON.git", from: "16.0.1"),
        .package(url: "https://github.com/jmmaloney4/Weak.git", from: "0.0.5"),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", from: "1.5.1"),
        .package(url: "https://github.com/evgenyneu/SigmaSwiftStatistics.git", from: "7.0.2")
    ],
    targets: [
        .target(name: "Conductor", dependencies: ["ConductorCore", "CommandLineKit"]),
        .target(name: "ConductorCore", dependencies: ["Squall", "SwiftPriorityQueue", "SwiftyJSON", "Weak", "SwiftyBeaver", "SigmaSwiftStatistics"])
    ]
)

