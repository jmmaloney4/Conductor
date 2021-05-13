import Foundation

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
    var faceupCards: [CardColor]
    var deck: Deck
}

class Game {
    var rules: Rules

    init(rules: Rules) {
        self.rules = rules
    }
}
