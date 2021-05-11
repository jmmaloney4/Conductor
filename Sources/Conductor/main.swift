import Commander
import Foundation
import SwiftGraph

let main = command(Argument<String>("mapfile", description: "File to load the map from.")) { mapfile in

    guard let inputFile = InputStream(fileAtPath: mapfile) else {
        throw ConductorError.fileInputError(path: mapfile)
    }

    let map = try Map(fromJSONStream: inputFile)
    let (distances, pathDict) = map.graph.dijkstra(root: "Wien", startDistance: 0)
    let nameDistance: [String: Int?] = distanceArrayToVertexDict(distances: distances, graph: map.graph)
    print(nameDistance["Kyiv"]!!)
    print(pathDict)
}

main.run()
