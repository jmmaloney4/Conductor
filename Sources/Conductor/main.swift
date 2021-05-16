// Copyright © 2017-2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Commander
import Foundation
import SwiftGraph

let main = command(Argument<String>("mapfile", description: "JSON File to load the map from."),
                   Argument<String>("rulesfile", description: "YAML File to load the rules from.")) { mapfile, _ in

    guard let inputFile = InputStream(fileAtPath: mapfile) else {
        throw ConductorError.fileInputError(path: mapfile)
    }

    let map = try Map(fromJSONStream: inputFile)
    let (distances, _) = map.graph.dijkstra(root: "Wien", startDistance: Edge())
    let nameDistance: [String: Edge?] = distanceArrayToVertexDict(distances: distances, graph: map.graph)
    print(nameDistance["Kyiv"]!!)

    let game = try Game(map: map, rules: Rules(), players: RandomPlayer(), RandomPlayer())
    game.play()
}

main.run()
