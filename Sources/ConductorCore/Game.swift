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
    var rng: Gust
    var seed: UInt32
    public var trackIndex: [Track:Player] = [:]
    // public var stations: [City:Player] = [:]
    var cards: [Color] = []
    var turn: Int = 0

    public var hashValue: Int { return ObjectIdentifier(self).hashValue }
    public static func == (lhs: Game, rhs: Game) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    private convenience init(withRules rules: Rules, board: Board) {
        self.init(withRules: rules, board: board, andPlayers: [])
    }

    public convenience init(withRules rules: Rules, board: Board, andPlayerTypes players: PlayerKind...) {
        self.init(withRules: rules, board: board, andPlayerTypes: players)
    }

    public convenience init(withRules rules: Rules, board: Board, andPlayerTypes players: [PlayerKind]) {
        var interfaces: [PlayerInterface] = []
        for i in players {
            switch i {
            case .bigTrackAI:
                interfaces.append(BigTrackAI())
            case .destinationAI:
                interfaces.append(DestinationAI())
            case .cli:
                interfaces.append(CLI())
            }
        }
        self.init(withRules: rules, board: board, andPlayers: interfaces)
    }

    public convenience init(withRules rules: Rules, board: Board, andPlayers players: PlayerInterface...) {
        self.init(withRules: rules, board: board, andPlayers: players)
    }

    public init(withRules rules: Rules, board: Board, andPlayers players: [PlayerInterface]) {
        self.seed = UInt32(Date().timeIntervalSinceReferenceDate) + (GlobalRng.random() / 100000)
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
        // log.info("Rng Seed: \(seed)")

        self.board.game = self

        for _ in 0..<rules.get(Rules.kFaceUpCards).int! {
            cards.append(draw())
        }
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
        switch player.interface.actionToTakeThisTurn(turn) {
        case .drawCards(let fn):
            var c: Color

            // first card
            var locomotive = false
            if let i = fn(cards) {
                c = takeCard(at: i)!
                if c == .locomotive {
                    locomotive = true
                }
            } else {
                c = draw()
            }
            player.addCardToHand(c)
            player.interface.drewCard(c)

            // if they drew a locomotive, they only get one card
            if locomotive {
                break
            }

            // second card, filter locomotives, can't take one
            if let i = fn(cards.filter({ $0 != .locomotive })) {
                c = takeCard(at: i)!
            } else {
                c = draw()
            }
            player.addCardToHand(c)
            player.interface.drewCard(c)

        case .getNewDestinations(let fn):
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

            player.destinations.append(contentsOf: kept)
            player.interface.keptDestinations(kept)

        case .playTrack(let fn):
            let tracks = unownedTracks().filter({ player.canAffordTrack($0) })
            if tracks.isEmpty {
                log.warning("No avaliable tracks")
                runTurnForPlayer(player)
            }
            let (i, l, c) = fn(tracks)
            let track = tracks[i]

            if track.color != .unspecified && c != nil {
                log.error("Can't have color be specified if track has a specified color")
                fatalError()
            }

            var color: Color
            if c == nil {
                if track.color == .unspecified {
                    color = player.mostColorInHand()
                } else {
                    color = track.color
                }
            } else {
                color = c!
            }

            log.debug("Color: \(color), Track: \(track.color)")

            var loc: Int
            if l == nil {
                // Use locomotives only if necessary
                if  track.length > player.cardsInHand(color) {
                    loc = track.length - player.cardsInHand(color)
                } else {
                    loc = 0
                }
            } else {
                // Otherwise use given number of locomotives
                loc = l!
            }

            player.spendCards(.locomotive, cost: loc)
            player.spendCards(color, cost: track.length - loc)

            trackIndex[track] = player
            player.interface.playedTrack(track)
        }
    }

    public func start() -> [Int] {
        for player in players {
            player.interface.startingTurn(turn)
            var destinations: [Destination] = [board.generateDestination(lengthMin: 20)]
            for _ in 1..<rules.get(Rules.kNumDestinationsToChooseFrom).int! {
                destinations.append(board.generateDestination())
            }
            let kept = player.interface.pickInitialDestinations(destinations).map({ destinations[$0] })
            player.destinations.append(contentsOf: kept)
            player.interface.keptDestinations(kept)

            turn += 1
        }

        var pt: Int! = nil
        while turn < 1000 {
            for player in players {
                if player.hand[.unspecified] != nil {
                    log.warning("Whoa there")
                }
                player.interface.startingTurn(turn)
                runTurnForPlayer(player)

                if (pt != nil && turn >= pt + players.count) || unownedTracks().isEmpty {
                    log.debug("End (\(turn))")
                    return winners()
                } else if pt == nil && player.trainsLeft() < rules.get(Rules.kMinTrains).int! {
                    pt = turn
                }

                turn += 1
            }
        }
        log.error("Hit turn limit")
        return []
    }

    public func winners() -> [Int] {
        let rv = players.map({ (player: Player) -> Int in
            var points = 0
            for track in tracksOwnedBy(player) {
                points += track.points()!
            }
            for dest in player.destinations where playerMeetsDestination(player, dest) {
                points += dest.length
            }
            for dest in player.destinations where !playerMeetsDestination(player, dest) {
                points -= dest.length
            }
            return points

        })
        if rv.count == 0 {
            log.error("No Players")
        }
        return rv
    }

    func playerOwnsTrack(_ player: Player, _ track: Track) -> Bool {
        return trackIndex[track] == player
    }

    func isTrackUnowned(_ track: Track) -> Bool {
        return trackIndex[track] == nil
    }

    func tracksOwnedBy(_ player: Player) -> [Track] {
        var rv: [Track] = []
        for (track, _) in trackIndex where playerOwnsTrack(player, track) {
            rv.append(track)
        }
        return rv
    }

    func unownedTracks() -> [Track] {
        var rv: [Track] = []
        for track in board.getAllTracks() where isTrackUnowned(track) {
            rv.append(track)
        }
        return rv
    }

    func checkForMaxLocomotives() {
        if cards.reduce(0, { res, color in
            if color == .locomotive {
                return res + 1
            } else {
                return res
            }}) >= rules.get(Rules.kMaxLocomotivesFaceUp).int! {
            // Refresh cards, too many locomotives
            var newCards: [Color] = []
            for _ in 0..<rules.get(Rules.kFaceUpCards).int! {
                newCards.append(draw())
            }
            cards = newCards
            checkForMaxLocomotives()
        }
    }

    func takeCard(at index: Int) -> Color? {
        if index >= cards.count || index < 0 {
            return nil
        }

        let rv = cards.remove(at: index)
        cards.append(draw())
        checkForMaxLocomotives()
        return rv
    }

    public func playerMeetsDestination(_ player: Player, _ destination: Destination) -> Bool {
        var queue: [Track] = []
        let city = destination.cities[0]

        var fn: ((City) -> Bool)! = nil
        fn = { city in
            for track in city.tracks where self.playerOwnsTrack(player, track) && !queue.contains(track) {
                queue.append(track)
                let endpoint = track.getOtherCity(city)!

                if endpoint == destination.cities[1] {
                    return true
                }

                if fn(endpoint) {
                    return true
                }

                queue.removeLast()
            }
            return false
        }

        return fn(city)
    }

    func playerDestinationPoints(_ player: Player) -> Int {
        var rv = 0
        for destination in player.destinations {
            if playerMeetsDestination(player, destination) {
                rv += destination.length
            }
        }
        return rv
    }
}
