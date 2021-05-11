import Foundation

class Rules: Codable {
    /// Colors used in the deck and in the tracks of the loaded map.
    var colors: [String]

    /// Number of traincars each player starts with.
    var initialTraincars: Int

    /// If a player has less than or equal to this many traincars, the game ends after one more turn.
    var minimumTraincars: Int
}
