// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public enum Action: CustomStringConvertible {

    /// Called to determine which card to draw.
    ///
    /// Will be called again for the second draw, unless the first draw is a 
    /// locomotive. Return `nil` to signify a random draw from the pile. If it 
    /// is the second draw and this returns a locomotive, an error will be thrown.
    ///
    /// - Parameter cards: The cards laid out on the table.
    public typealias DrawCardsFunc = (_ cards: [Color]) -> Int?

    /// Called to determine which destinations to keep.
    ///
    /// Return an array of the indicies in the passed array to keep. You must 
    /// keep at least one.
    ///
    /// - Parameter destinations: The destinations to choose from.
    public typealias NewDestinationsFunc = (_ destinations: [Destination]) -> [Int]

    /// Called to determine which track to play.
    ///
    /// Return the index into the passed array of the track you would like to 
    /// play. Also return the number of locomotive cards you would like to use 
    /// to pay for the track, or return `nil` to only use locomotives as 
    /// necessary, and the color of cards you would like to pay with if the 
    /// track has an unspecified color, otherwise return nil to pay with the 
    /// specified color.
    ///
    /// - Parameter tracks: The tracks to choose from.
    public typealias PlayTrackFunc = (_ tracks: [Track]) -> (Int, Int?, Color?)

    case drawCards(DrawCardsFunc)
    case getNewDestinations(NewDestinationsFunc)
    case playTrack(PlayTrackFunc)
    // case playStation(([City]) -> Int)

    public var description: String {
        switch self {
        case .drawCards: return "Draw Cards"
        case .getNewDestinations: return "Get New Destinations"
        case .playTrack: return "Play Track"
        // case .playStation: return "Play Station"
        }
    }
}

public protocol PlayerInterface {
    weak var player: Player! { get set }
    var kind: PlayerKind { get }

    func startingGame()
    func pickInitialDestinations(_ destinations: [Destination]) -> [Int]
    func startingTurn(_ turn: Int)
    func actionToTakeThisTurn(_ turn: Int) -> Action
    func drewCard(_ color: Color)
    func keptDestinations(_ destinations: [Destination])
    func playedTrack(_ track: Track)
}

public enum PlayerKind: CustomStringConvertible {
    case cli
    case destinationAI
    case bigTrackAI
    case randomAI

    public var description: String {
        switch self {
        case .cli: return "CLI"
        case .bigTrackAI: return "Big Track AI"
        case .destinationAI: return "Destination AI"
        case .randomAI: return "Random AI"
        }
    }
}

public func playerStringToPlayerKind(_ string: String) -> [PlayerKind] {
    var players: [PlayerKind] = []
    for c in string {
        switch c {
        case "c":
            players.append(.cli)
        case "b":
            players.append(.bigTrackAI)
        case "d":
            players.append(.destinationAI)
        case "r":
            players.append(.randomAI)
        default:
            log.error("\(c) does not corrispond to a type of player")
            fatalError()
        }
    }
    return players
}

public func playerKindsToString(_ kinds: [PlayerKind]) -> String {
    var rv = String()
    for player in kinds {
        switch player {
        case .bigTrackAI: rv.append("b")
        case .destinationAI: rv.append("d")
        case .cli: rv.append("c")
        case .randomAI: rv.append("r")
        }
    }
    return rv
}

// Mostly storage-only, game logic in the Game class
public class Player: Hashable {
    weak var game: Game!
    var interface: PlayerInterface
    var hand: [Color: Int] = [.red: 0, .blue: 0, .black: 0, .white: 0, .orange: 0, .yellow: 0, .pink: 0, .green: 0, .locomotive: 0]
    var destinations: [Destination] = []

    public var hashValue: Int { return ObjectIdentifier(self).hashValue }
    public static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    init(game: Game) {
        self.game = game
        self.interface = CLI()
    }

    init(withInterface interface: PlayerInterface, andGame game: Game) {
        self.interface = interface
        self.interface.player = self
        self.game = game
    }

    func addCardToHand(_ color: Color) {
        hand[color]! += 1
    }

    func cardsInHand(_ color: Color) -> Int {
        if let rv = hand[color] {
            return rv
        } else {
            return 0
        }
    }

    func spendCards(_ color: Color, cost: Int) {
        hand[color]! -= cost
        if game.deck != nil {
            log.debug("Spent \(cost) \(color) cards, adding them back into the deck")
            game.deck!.append(contentsOf: Array(repeating: color, count: cost))
        }
    }

    func canAffordCost(_ cost: Int, color: Color) -> Bool {
        if color == .unspecified && hand[mostColorInHand()]! >= cost {
            return true
        } else if let x = hand[color] {
            if x >= cost {
                return true
            }
        }
        return false
    }

    func canAffordTrack(_ track: Track) -> Bool {
        // Need locomotive cards to build ferries
        /*
        if self.cardsInHand(.locomotive) < track.ferries {
            return false
        }
         */
        if self.trainsLeft() < track.length {
            return false
        }
        return canAffordCost(track.length - self.cardsInHand(.locomotive), color: track.color)
    }

    func trainsLeft() -> Int {
        let trains = game.tracksOwnedBy(self).reduce(0, { $0 + $1.length })
        return game.rules[Rules.kInitialTrains].int! - trains
    }

    func mostColorInHand() -> Color {
        var most: Color = .red
        var mc: Int = 0
        for (color, i) in hand where color != .locomotive {
            if mc < i { // swiftlint:disable:this for_where
                most = color
                mc = i
            }
        }
        if most == .unspecified || most == .locomotive {
            log.error("Hand: \(hand)")
        }
        return most
    }
}
