// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Squall

public class Game: Hashable {
    var rules: Rules = Rules()
    var players: [Player]
    var board: Board
    var state: State!
    var rng: Gust = Gust(seed: UInt32(Date().timeIntervalSinceReferenceDate))

    public var hashValue: Int { return ObjectIdentifier(self).hashValue }
    public static func == (lhs: Game, rhs: Game) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    public init(withBoard board: Board, andPlayers players: PlayerInterface...) {
        self.board = board
        self.players = []
        for player in players {
            self.players.append(Player(withInterface: player, andGame: self))
        }

        state = State(withGame: self)
    }

    // 12 of each color (8 colors)
    // 14 locomotive
    // (12 * 8) + 14 = 110
    // 12 / 110 =
    func draw() -> Color {
        let probabilities: [Double] = [
            Double(12) / Double(110),
            Double(12) / Double(110),
            Double(12) / Double(110),
            Double(12) / Double(110),
            Double(12) / Double(110),
            Double(12) / Double(110),
            Double(12) / Double(110),
            Double(12) / Double(110),

            Double(14) / Double(110)
        ]

        let rngout: UInt64 = rng.random()
        let rand = Double(rngout) / Double(UInt64.max)
        var accum = 0.0
        for (i, prob) in probabilities.enumerated() {
            accum += prob
            if rand < accum {
                return Color.colorForIndex(i)!
            }
        }

        print("Double Math error")
        return .locomotive
    }

}
