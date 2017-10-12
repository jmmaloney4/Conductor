// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Squall

public class Game: Hashable {
    var rules: Rules
    public var players: [Player]
    var started: Bool = false
    var board: Board
    public var state: State!
    var rng: Gust
    var seed: UInt32

    public var hashValue: Int { return ObjectIdentifier(self).hashValue }
    public static func == (lhs: Game, rhs: Game) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    public convenience init(withRules rules: Rules, board: Board) {
        self.init(withRules: rules, board: board, andPlayers: [])
    }

    public convenience init(withRules rules: Rules, board: Board, andPlayers players: PlayerInterface...) {
        self.init(withRules: rules, board: board, andPlayers: players)
    }

    public init(withRules rules: Rules, board: Board, andPlayers players: [PlayerInterface]) {
        self.seed = UInt32(Date().timeIntervalSinceReferenceDate)
        self.rng = Gust(seed: seed)
        self.rules = rules
        self.board = board
        self.players = []
        for player in players {
            let p = Player(withInterface: player, andGame: self)
            for _ in 0..<rules.get(Rules.kStartingHandSize).int! {
                p.addCardToHand(draw())
            }
            self.players.append(p)
        }
        log.info("Rng Seed: \(seed)")

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

        log.warning("Double Math error")
        return .locomotive
    }

    func runTurnForPlayer(_ player: Player) {
        switch player.interface.actionToTakeThisTurn(state.turn) {
        case .drawCards(let fn, let drew):
            var c: Color

            // first card
            var locomotive = false
            if let i = fn(state.cards) {
                c = state.takeCard(at: i)!
                if c == .locomotive {
                    locomotive = true
                }
            } else {
                c = draw()
            }
            player.addCardToHand(c)
            drew(c)

            // if they drew a locomotive, they only get one card
            if locomotive {
                break
            }

            // second card, filter locomotives, can't take one
            if let i = fn(state.cards.filter({ $0 != .locomotive })) {
                c = state.takeCard(at: i)!
            } else {
                c = draw()
            }
            player.addCardToHand(c)
            drew(c)

        case .getNewDestinations(let fn, let keeping):
            var destinations: [Destination] = []
            for _ in 0..<rules.get(Rules.kNumDestinationsToChooseFrom).int! {
                destinations.append(board.generateDestination())
            }

            var indices: [Int] = []
            while true {
                indices = fn(destinations)
                if !indices.isEmpty {
                    break
                }
            }

            var kept: [Destination] = []
            for index in indices {
                kept.append(destinations[index])
            }
            keeping(kept)

            player.destinations.append(contentsOf: kept)

        case .playTrack(let fn, let playing):
            let tracks = state.unownedTracks().filter({ player.canAffordTrack($0) })
            if tracks.isEmpty {
                log.warning("No avaliable tracks")
                runTurnForPlayer(player)
            }
            let track = tracks[fn(tracks)]
            playing(track)
            state.tracks[track] = player

        case .playStation(let fn, let playing):
            let cost = state.stationsOwnedBy(player).count + 1
            if cost > 3 || !player.canAffordCost(cost, color: .unspecified) {
                log.warning("No avaliable stations")
                runTurnForPlayer(player)
            }
            let cities = board.cities.filter({ state.stations[$0] == nil })
            let city = cities[fn(cities)]
            playing(city)
            state.stations[city] = player
        }
    }

    public func start() -> [Player:Int] {
        var pt: Int! = nil
        while state.turn < 1000 {
            for player in players {
                player.interface.startingTurn(state.turn)
                runTurnForPlayer(player)

                if (pt != nil && state.turn >= pt + players.count) || state.unownedTracks().isEmpty {
                    log.info("End (\(state.turn))")
                    return winners()
                } else if pt == nil && player.trainsLeft() < rules.get(Rules.kMinTrains).int! {
                    pt = state.turn
                }

                state.turn += 1
            }
        }
        return [:]
    }

    public func winners() -> [Player:Int] {
        var rv: [Player:Int] = [:]
        for player in players {
            var points = 0
            for track in state.tracksOwnedBy(player) {
                points += track.points()!
            }
            for dest in player.destinations where state.playerMeetsDestination(player, dest) {
                points += dest.length
            }
            for dest in player.destinations where !state.playerMeetsDestination(player, dest) {
                points -= dest.length
            }
            rv[player] = points
        }
        return rv
    }
}
