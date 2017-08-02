// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public enum Action {
    case drawCards(([Color]) -> Int?, (Color) -> Void)
    case getNewDestinations(([Destination]) -> [Int], ([Destination]) -> Void)
    case playTrack(([Track]) -> Int, (Track) -> Void)
    case playStation
}

public protocol PlayerInterface {
    weak var player: Player! { get set }

    func startingGame()
    func startingTurn(_ turn: Int)
    func actionToTakeThisTurn(_ turn: Int) -> Action
}

// Mostly storage-only, game logic in the Game class
public class Player: Hashable {
    weak var game: Game!
    var interface: PlayerInterface
    var hand: [Color:Int] = [:]
    var destinations: [Destination] = []

    public var hashValue: Int { return ObjectIdentifier(self).hashValue }
    public static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    init(withInterface interface: PlayerInterface, andGame game: Game) {
        self.interface = interface
        self.interface.player = self
        self.game = game
    }

    func addCardToHand(_ color: Color) {
        if hand[color] == nil {
            hand[color] = 1
        } else {
            hand[color]! += 1
        }
    }

    func getCardsInHand(_ color: Color) -> Int {
        if let rv = hand[color] {
            return rv
        } else {
            return 0
        }
    }

    func canAffordCost(_ cost: Int, color: Color) -> Bool {
        for entry in hand where color == .unspecified || entry.key == color {
            if entry.value >= cost {
                return true
            }
        }
        return false
    }

    func canAffordTrack(_ track: Track) -> Bool {
        // Need locomotive cards to build ferries
        if self.getCardsInHand(.locomotive) < track.ferries {
            return false
        }
        let cardsNeeded = track.length - track.ferries
        return canAffordCost(cardsNeeded, color: track.color)
    }
}
