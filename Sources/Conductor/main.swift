import Commander
import Foundation
import SwiftGraph

let main = command(Argument<String>("mapfile", description: "JSON File to load the map from."),
                   Argument<String>("rulesfile", description: "YAML File to load the rules from.")) { mapfile, rulesfile in

    guard let inputFile = InputStream(fileAtPath: mapfile) else {
        throw ConductorError.fileInputError(path: mapfile)
    }

    let map = try Map(fromJSONStream: inputFile)
    let (distances, pathDict) = map.graph.dijkstra(root: "Wien", startDistance: 0)
    let nameDistance: [String: Int?] = distanceArrayToVertexDict(distances: distances, graph: map.graph)
    print(nameDistance["Kyiv"]!!)

    let rules = try Rules.rulesFromYaml(file: rulesfile)
    print(rules.colors)

    var cardColors = rules.colors.map { CardColor.color(name: $0) }
    cardColors.append(.locomotive)
    let deck = UniformDeck(colors: cardColors)

    var dict: [CardColor: Int] = [:]
    cardColors.forEach { color in
        dict[color] = 0
    }

    (0 ... 20000).map { _ in deck.draw() }.forEach { color in
        dict[color]! += 1
    }

    dict.values.forEach {
        print($0)
    }
}

main.run()
