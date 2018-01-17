// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public class DestinationAI: AI {
    public override var kind: PlayerKind {
        return .destinationAI
    }

    public override func pickInitialDestinations(_ destinations: [Destination]) -> [Int] {
        let sorted = destinations.sorted(by: { $0.length > $1.length })
        let index = destinations.index(where: { $0 == sorted[0] })!
        return [index]
    }

    public override func actionToTakeThisTurn(_ turn: Int) -> Action {
        log.verbose(turn)

        var destination: Destination! = nil
        for dest in player.destinations where !player.game.playerMeetsDestination(player, dest) {
            destination = dest
            break
        }
        if destination == nil {
            return .getNewDestinations({ (dests: [Destination]) -> [Int] in
                return self.pickBestDestination(dests: dests)
            })
        }
        log.verbose(destination)

        if let (route, _) = player.game.board.findShortesAvaliableRoute(between: destination.cities[0], and: destination.cities[1], to: player) {
            log.verbose("Route: \(route)")

            for i in 1..<route.count {
                let tracks = player.game.board.tracksBetween(route[i - 1], and: route[i])
                for track in tracks where player.game.trackIndex[track] == nil {
                    if player.canAffordTrack(track) {
                        return .playTrack({ (tracks: [Track]) -> (Int, Int?, Color?) in
                            return (tracks.index(of: track)!, nil, nil)
                        })
                    } else {
                        return .drawCards({ (colors: [Color]) -> Int? in
                            let rv = AI.smartDraw(player: self.player, target: track, options: colors)
                            if rv != nil {
                                log.verbose("Drawing \(colors[rv!])")
                            } else {
                                log.verbose("Drawing Random")
                            }
                            return rv
                        })
                    }
                }
            }
        }

        for track in player.game.unownedTracks() where player.canAffordTrack(track) {
            return .playTrack({ (tracks: [Track]) -> (Int, Int?, Color?) in
                return (tracks.index(of: track)!, nil, nil)
            })
        }

        return .drawCards({ (colors: [Color]) -> Int? in
            log.verbose("Drawing")
            return nil
        })
    }

    func pickBestDestination(dests: [Destination]) -> [Int] {
        let scores = dests.map({ (dest: Destination) -> Int in
            guard let (route, _) = player.game.board.findShortesAvaliableRoute(between: dest.cities[0], and: dest.cities[1], to: player) else {
                return Int.max
            }

            var rv: Int = 0

            for i in route.indices {
                if i == 0 {
                    continue
                }

                let tracks = player.game.board.tracksBetween(route[i - 1], and: route[i]).filter({ !player.game.playerOwnsTrack(player, $0) })
                if !tracks.isEmpty {
                    rv += tracks[0].length
                }
            }

            return rv
        })

        let best = dests[scores.index(of: scores.sorted(by: { $0 < $1 })[0])!]

        return [dests.index(of: best)!]
    }
}
