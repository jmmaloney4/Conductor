import Foundation
import Yams

struct Rules: Codable {
    /// Colors used in the deck and in the tracks of the loaded map.
    var colors: [String]

    /// Whether to use a uniform distribution over thee cards, or a finite deck
    var finiteDeck: Bool

    /// Number of traincars each player starts with.
    var initialTraincars: Int

    /// If a player has less than this many traincars, the game ends after one more turn.
    var minimumTraincars: Int

    /// Number of face up cards to be chosen from
    var faceUpCards: Int

    var onlyOneActionPerTurn: Bool

    static func rulesFromYaml(stream: InputStream) throws -> Rules {
        try YAMLDecoder().decode(Rules.self, from: try Data(reading: stream))
    }

    static func rulesFromYaml(file path: String) throws -> Rules {
        guard let stream = InputStream(fileAtPath: path) else {
            throw ConductorError.fileInputError(path: path)
        }
        return try rulesFromYaml(stream: stream)
    }
}