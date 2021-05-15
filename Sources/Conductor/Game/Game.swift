import Foundation
import LinkedList

struct PlayerData: Codable {
    struct CardData: Codable {
        var color: CardColor
        /// If this card has been seen by the other players
        var known: Bool
    }

    var hand: [CardData] = []
}

struct GameState {
    var playerData: [PlayerData]
    var faceupCards: [CardColor?]
    var deck: Deck
}

extension GameState: Codable {
    enum CodingKeys: CodingKey {
        case playerData
        case faceupCards
        case deck
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(playerData, forKey: .playerData)
        try container.encode(faceupCards, forKey: .faceupCards)
        switch deck.type {
        case .uniform: try container.encode(deck as! UniformDeck, forKey: .deck)
        case .finite: try container.encode(deck as! FiniteDeck, forKey: .deck)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let playerData = try container.decode([PlayerData].self, forKey: .playerData)
        let faceupCards = try container.decode([CardColor].self, forKey: .faceupCards)

        if let deck = try? container.decode(UniformDeck.self, forKey: .deck) {
            self.init(playerData: playerData, faceupCards: faceupCards, deck: deck)
        } else if let deck = try? container.decode(FiniteDeck.self, forKey: .deck) {
            self.init(playerData: playerData, faceupCards: faceupCards, deck: deck)
        } else {
            throw ConductorCodingError.unknownValue
        }
    }
}

/// Single execution of a game
class Game {
    var rules: Rules
    var history: LinkedList<GameState>

    init(rules: Rules) {
        self.rules = rules
        history = [self.rules.initialGameState()]
    }
}
