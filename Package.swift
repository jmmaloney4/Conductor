// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import PackageDescription

let package = Package(
    name: "Conductor",
    targets: [ Target(name: "Conductor", dependencies: ["ConductorCore"])],
    
    dependencies: [
        .Package(url: "https://github.com/jmmaloney4/Squall.git", "1.2.3"),
        .Package(url: "https://github.com/jmmaloney4/VarInt.git", "0.3.0"),
        .Package(url: "https://github.com/davecom/SwiftPriorityQueue.git", "1.1.2"),
        .Package(url: "https://github.com/IBM-Swift/SwiftyJSON.git", "16.0.1"),
        .Package(url: "https://github.com/jmmaloney4/Weak.git", "0.0.5"),
        .Package(url: "https://github.com/jmmaloney4/CommandLine.git", "3.0.2"),
        .Package(url: "https://github.com/onevcat/Rainbow.git", "2.1.0"),
        .Package(url: "https://github.com/IBM-Swift/BlueSocket.git", "0.12.59"),
        .Package(url: "https://github.com/IBM-Swift/Kitura.git", "1.7.6")
    ],
    exclude: ["Tests/Resources/"]
)

