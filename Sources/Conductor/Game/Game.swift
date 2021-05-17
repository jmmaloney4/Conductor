// Copyright © 2017-2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import LinkedList
import Squall

typealias City = String
typealias CityPair = Pair<City, City>
typealias Destination = CityPair

struct PlayerData: Codable {
    struct CardData: Codable {
        var color: CardColor
        /// If this card has been seen by the other players
        var known: Bool
    }

    var hand: [CardData] = []
    var tracks: [CityPair] = []
    var destinations: [CityPair] = []
}

struct GameState {
    var playerData: [PlayerData]
    var faceupCards: [CardColor?]
    var deck: Deck
    var rng: Gust
}

extension GameState: Codable {
    enum CodingKeys: CodingKey {
        case playerData
        case faceupCards
        case deck
        case rng
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(playerData, forKey: .playerData)
        try container.encode(faceupCards, forKey: .faceupCards)
        switch deck.type {
        case .uniform: try container.encode(deck as! UniformDeck, forKey: .deck)
        case .finite: try container.encode(deck as! FiniteDeck, forKey: .deck)
        }
        try container.encode(rng, forKey: .rng)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let playerData = try container.decode([PlayerData].self, forKey: .playerData)
        let faceupCards = try container.decode([CardColor].self, forKey: .faceupCards)
        let rng = try container.decode(Gust.self, forKey: .rng)

        if let deck = try? container.decode(UniformDeck.self, forKey: .deck) {
            self.init(playerData: playerData, faceupCards: faceupCards, deck: deck, rng: rng)
        } else if let deck = try? container.decode(FiniteDeck.self, forKey: .deck) {
            self.init(playerData: playerData, faceupCards: faceupCards, deck: deck, rng: rng)
        } else {
            throw ConductorCodingError.unknownValue
        }
    }
}

/// Single execution of a game
class Game: GameDataDelegate {
    var map: Map
    var rules: Rules
    var players: [Player]
    var history: LinkedList<GameState>
    var state: GameState

    init(map: Map, rules: Rules, players: Player...) throws {
        self.map = map
        self.rules = rules
        self.players = players
        history = []
        state = try self.rules.initialGameState(playerCount: players.count)
    }

    func play() {
        players.map { p -> [Destination] in
            let destinations = (0 ..< (rules.initialLongDestinations + rules.initialShortDestinations)).map { _ in
                self.map.randomDestination(using: &self.state.rng)
            }

            let chosen = p.initialDestinationSelection(delegate: self)(destinations)

            destinations.forEach { dest in
                print("\(dest) \(self.map.distance(dest)) \(self.map.path(dest)) \(chosen.contains(dest))")
            }

            return chosen
        }.enumerated().forEach { k, chosen in
            self.state.playerData[k].destinations = chosen
        }
    }
}
