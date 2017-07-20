// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public protocol PlayerDelegate {
    func keepDestinations(_ destinations: [Destination]) -> [Destination]
    func currentDestinations(_ destinations: [Destination])

    func actionThisTurn() -> Game.Action

    func whichCardToTake(_ faceUpCards: [Track.Color]) -> Int?
    func whichTrackToClaim(_ avaliableTracks: [Track]) -> Int
}

public class Player: CustomStringConvertible {
    public enum Color: CustomStringConvertible {
        case black
        case green
        case red
        case blue
        case yellow

        public var description: String {
            switch self {
            case .black: return "Black"
            case .green: return "Green"
            case .red: return "Blue"
            case .blue: return "Blue"
            case .yellow: return "Yellow"
            }
        }

    }

    var delegate: PlayerDelegate

    var color: Color
    var trains: Int = 45
    var stations: Int = 3
    var cards: [Int] = Array(repeatElement(0, count:  Track.Color.count))
    var destinations: [Destination] = []

    public var description: String { return "\(color) Player" }

    public init(withDelegate delegate: PlayerDelegate, andColor color: Color) {
        self.delegate = delegate
        self.color = color
    }

    public func addCardToHand(_ color: Track.Color) {
        cards[color.rawValue] += 1
    }

    func hasEnoughCards(_ numCards: Int, ofColor color: Track.Color) -> Bool {
        return cards[color.rawValue] >= numCards
    }
}
