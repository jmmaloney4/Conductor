// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Squall

public class Game: Hashable {
    var rules: Rules
    var players: [Player]
    var board: Board
    var state: State!
    var rng: Gust
    var seed: UInt32

    public var hashValue: Int { return ObjectIdentifier(self).hashValue }
    public static func == (lhs: Game, rhs: Game) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    public init(withRules rules: Rules, board: Board, andPlayers players: PlayerInterface...) {
        self.seed = UInt32(Date().timeIntervalSinceReferenceDate)
        print("Rng Seed: \(seed)")
        self.rng = Gust(seed: seed)
        self.rules = rules
        self.board = board
        self.players = []
        for player in players {
            let p = Player(withInterface: player, andGame: self)
            for _ in 0..<rules.startingHandSize {
                p.addCardToHand(draw())
            }
            self.players.append(p)
        }

        self.board.game = self

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

    public func start() {
        while true {
            for player in players {
                player.interface.startingTurn(state.turn)
                switch player.interface.actionToTakeThisTurn(state.turn) {
                case .drawCards(let fn, let drew):
                    var c: Color

                    // first card
                    if let i = fn(state.cards) {
                        c = state.takeCard(at: i)!
                    } else {
                        c = draw()
                    }
                    drew(c)
                    player.addCardToHand(c)

                    // if they drew a locomotive, they only get one card
                    if c == .locomotive {
                        break
                    }

                    // second card, filter locomotives, can't take one
                    if let i = fn(state.cards.filter({ $0 != .locomotive })) {
                        c = state.takeCard(at: i)!
                    } else {
                        c = draw()
                    }
                    drew(c)
                    player.addCardToHand(c)

                case .getNewDestinations(let fn, let keeping):
                    var destinations: [Destination] = []
                    for _ in 0..<rules.numDestinationsToChooseFrom {
                        destinations.append(board.generateDestination())
                    }
                    var kept: [Destination] = []
                    while true {
                        kept = fn(destinations)
                        if !kept.isEmpty {
                            break
                        }
                    }
                    keeping(kept)
                    player.destinations.append(contentsOf: kept)
                default:
                    break
                }
                state.turn += 1
            }
        }
    }
}
