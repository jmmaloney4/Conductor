// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Squall

public class Game {
    var players: [Player]
    var board: Board
    var faceUpCards: [Track.Color] = []
    var turn: Int = 0
    static let rng: Gust = Gust(seed: UInt32(Date().timeIntervalSinceReferenceDate))

    public init(withPlayers players: Player..., andBoard board: Board = Board.standardEuropeMap()) {
        self.players = players
        self.board = board
    }

    public enum Action {
        case drawCards
        case playTrack
        case newDestinations
        case buildStation
    }

    // 12 of each color (8 colors)
    // 14 locomotive
    // (12 * 8) + 14 = 110
    // 12 / 110 =
    func draw() -> Track.Color {
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

        let rngout: UInt64 = Game.rng.random()
        let rand = Double(rngout) / Double(UInt64.max)
        var accum = 0.0
        for (i, prob) in probabilities.enumerated() {
            accum += prob
            if rand < accum {
                return Track.Color.colorForIndex(i)
            }
        }

        print("Double Math error")
        return .locomotive
    }

    func newDestinationsForPlayer(_ player: Player, destinations: Int) {
        var temp: [Destination] = []
        for _ in 0..<destinations {
            temp.append(board.generateDestination())
        }
        player.destinations.append(contentsOf: player.delegate.keepDestinations(temp))
        print(player.destinations)
        player.delegate.currentDestinations(player.destinations)
    }

    func drawCardsForPlayer(_ player: Player) {
        let card1 = player.delegate.whichCardToTake(faceUpCards)
        if card1 == nil {
            player.addCardToHand(draw())
        } else {
            let card = faceUpCards.remove(at: card1!)
            player.addCardToHand(card)
            faceUpCards.append(draw())
            if card == .locomotive {
                return // Only one locomotive
            }
        }

        while true {
            let card2 = player.delegate.whichCardToTake(faceUpCards)
            if card2 == nil {
                player.addCardToHand(draw())
            } else if faceUpCards[card2!] == .locomotive {
                continue // Only one locomotive, can't choose it as second card
            } else {
                player.addCardToHand(faceUpCards.remove(at: card2!))
                faceUpCards.append(draw())
            }
            break
        }
    }

    func playTrackForPlayer(_ player: Player) {
        while true {
            var tracks = board.unownedTracks()
            let track = tracks[player.delegate.whichTrackToClaim(tracks)]

            if player.hasEnoughCards(track.length, ofColor: track.color) {
                track.owner = player
                break
            }
        }
    }

    public func run() -> Player {
        for p in players {
            for _ in 0..<3 {
                p.cards[draw().rawValue] += 1
            }
            newDestinationsForPlayer(p, destinations: 4)
        }

        for _ in 0..<5 {
            faceUpCards.append(draw())
        }

        while true {
            turn += 1
            for p in players {
                switch p.delegate.actionThisTurn() {
                case .drawCards:
                    drawCardsForPlayer(p)
                case .playTrack:
                    playTrackForPlayer(p)
                case .newDestinations:
                    newDestinationsForPlayer(p, destinations: 3)
                case .buildStation:
                    break
                }
            }
        }

        // return players[0]
    }
}
