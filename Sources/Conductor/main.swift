import Commander
import Foundation
import SwiftGraph

let main = command(Argument<String>("mapfile", description: "JSON File to load the map from."),
                   Argument<String>("rulesfile", description: "YAML File to load the rules from.")) { mapfile, rulesfile in

    guard let inputFile = InputStream(fileAtPath: mapfile) else {
        throw ConductorError.fileInputError(path: mapfile)
    }

    let map = try Map(fromJSONStream: inputFile)
    let (distances, _) = map.graph.dijkstra(root: "Wien", startDistance: Track())
    let nameDistance: [String: Track?] = distanceArrayToVertexDict(distances: distances, graph: map.graph)
    print(nameDistance["Kyiv"]!!)

    let rules = try Rules.rulesFromYaml(file: rulesfile)
    print(rules.colors)
}

main.run()
