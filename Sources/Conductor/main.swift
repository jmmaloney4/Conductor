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

    var cardColors = rules.colors.map { CardColor.color(name: $0) }
    cardColors.append(.locomotive)
    var deck = UniformDeck(colors: cardColors)

    var dict: [CardColor: Int] = [:]
    cardColors.forEach { color in
        dict[color] = 0
    }

    (0 ... 20000).map { _ in deck.draw()! }.forEach { color in
        dict[color]! += 1
    }

    dict.values.forEach {
        print($0)
    }

    var cards: [CardColor] = []
    rules.colors.forEach {
        cards.append(contentsOf: Array(repeating: CardColor.color(name: $0), count: 8))
    }
    cards.append(contentsOf: Array(repeating: CardColor.locomotive, count: 8))

    var finiteDeck = FiniteDeck(cards: cardColors)

    dict = [:]
    cardColors.forEach { color in
        dict[color] = 0
    }

    (0 ... 20000).map { _ in let rv = finiteDeck.draw()!; finiteDeck.discard(rv); return rv }.forEach { color in
        dict[color]! += 1
    }

    print("Finite Deck:")
    dict.values.forEach {
        print($0)
    }

    var state = GameState(playerData: [PlayerData(hand: []), PlayerData(hand: [])], faceupCards: [.locomotive, .locomotive], deck: deck)
    var state2 = try SerializeDeserialize(state)
    print(state.deck.draw(10))
    print(state2.deck.draw(10))
}

main.run()
