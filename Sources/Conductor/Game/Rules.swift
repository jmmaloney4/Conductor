// Copyright © 2017-2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Squall
import Yams

internal struct Rules: Codable {
    /// Colors used in the deck and in the tracks of the loaded map.
    var colors: [String] = ["Black", "Blue", "Green", "Orange", "Pink", "Red", "White", "Yellow"]

    internal struct DeckConfiguration: Codable {
        var type: DeckType!
        var cardsPerColor: Either<Int, [Int]> = Either(left: 12, right: nil)
        var numLocomotives: Int = 14
    }

    var deck = DeckConfiguration()

    /// Number of traincars each player starts with.
    var initialTraincars: Int = 45
    /// If a player has less than this many traincars, the game ends after one more turn.
    var minimumTraincars: Int = 3
    /// Number of face up cards to be chosen from
    var faceupCards: Int = 5
    /// Number of cards dealt to each player at the start of the game.
    var initialHandSize: Int = 4

    // Start of Game
    /// Nunber of Destinations that muust be kept at the start of the game
    var minimumDestinations: Int = 2
    var initialLongDestinations: Int = 1
    var initialShortDestinations: Int = 3
    var longestLongDestination = Int.max
    var longestShortDestination: Int = 20
    var shortestShortDestination: Int = 6

    // Advanced
    var onlyOneActionPerTurn: Bool = true

    static func rulesFromYaml(stream: InputStream) throws -> Rules {
        try YAMLDecoder().decode(Rules.self, from: try Data(reading: stream))
    }

    static func rulesFromYaml(file path: String) throws -> Rules {
        guard let stream = InputStream(fileAtPath: path) else {
            throw ConductorError.fileInputError(path: path)
        }
        return try self.rulesFromYaml(stream: stream)
    }

    init() {
        var cards = Array(repeating: CardColor.locomotive, count: self.deck.numLocomotives)
        cards.append(contentsOf: self.colors.map { color in
            Array(repeating: CardColor.color(name: color), count: self.deck.cardsPerColor.left!)
        }.reduce([]) { $0 + $1 })
        self.deck = DeckConfiguration(type: .finite(cards: cards))
    }

    func initialGameState(playerCount: Int = 2, seed _: Int = Int(Date().timeIntervalSince1970.rounded())) throws -> GameState {
        var deck = self.makeDeck()

        let playerData = try (0 ..< playerCount).map { _ in
            let h = deck.draw(self.initialHandSize)
            guard !h.contains(nil) else { throw ConductorError.outOfCardsError }
            return h.map { PlayerData.CardData(color: $0!, known: false) }
        }
        .map { PlayerData(hand: $0) }

        let faceups = deck.draw(self.faceupCards)
        guard !faceups.contains(nil) else { throw ConductorError.outOfCardsError }

        return GameState(
            playerData: playerData,
            faceupCards: faceups,
            deck: deck,
            rng: Gust()
        )
    }

    func makeDeck() -> Deck {
        switch self.deck.type {
        case let .uniform(colors): return UniformDeck(colors: colors)
        case let .finite(cards): return FiniteDeck(cards: cards)
        default: fatalError("deck.type cannot be nil")
        }
    }
}
