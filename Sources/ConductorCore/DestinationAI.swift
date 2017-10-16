// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public class DestinationAI: AI {
    public override func pickInitialDestinations(_ destinations: [Destination]) -> [Int] {
        let sorted = destinations.sorted(by: { $0.length > $1.length })
        let index = destinations.index(where: { $0 == sorted[0] })!
        return [index]
    }

    public override func actionToTakeThisTurn(_ turn: Int) -> Action {
        log.verbose(turn)

        // var destination: Destination! = Destination(from: player.game.board.cityForName("Venezia")!, to: player.game.board.cityForName("Pamplona")!, length: 8)
        var destination: Destination! = nil
        for dest in player.destinations where !player.game.playerMeetsDestination(player, dest) {
            destination = dest
            break
        }
        if destination == nil {
            return .getNewDestinations({ _ in
                return [0]
            })
        }
        log.verbose(destination)

        if let (route, _) = player.game.board.findShortesAvaliableRoute(between: destination.cities[0], and: destination.cities[1], to: player) {
            log.verbose("Route: \(route)")

            for i in 1..<route.count {
                let tracks = player.game.board.tracksBetween(route[i-1], and: route[i])
                for track in tracks {
                    if player.game.trackIndex[track] == nil {
                        if player.canAffordTrack(track) {
                            return .playTrack({ (tracks: [Track]) -> (Int, Int?, Color?) in
                                return (tracks.index(of:track)!, nil, nil)
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
        }

        for track in player.game.unownedTracks() where player.canAffordTrack(track) {
            return .playTrack({ (tracks: [Track]) -> (Int, Int?, Color?) in
                return (tracks.index(of:track)!, nil, nil)
            })
        }

        return .drawCards({ (colors: [Color]) -> Int? in
            log.verbose("Drawing")
            return nil
        })
    }
}
