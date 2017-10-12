// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public class BigTrackAIPlayerInterface: PlayerInterface {
    public weak var player: Player!

    public init() {}

    public func startingGame() {}

    public func startingTurn(_ turn: Int) {
        log.info("=== Big Track AI Player \(player.game.players.index(of: player)!) " +
            "Starting Turn \(turn / player.game.players.count) ===")
        log.info("Active Destinations: \(player.destinations) \(player.destinations.map({ player.game.state.playerMeetsDestination(player, $0) }))")
        log.info("Hand: \(player.hand)")

        for p in player.game.players {
            log.info("Player \(player.game.players.index(of: p)!) Owns: \(player.game.state.tracksOwnedBy(p))")
        }
    }

    public func actionToTakeThisTurn(_ turn: Int) -> Action {
        log.debug(turn)

        var tracksSorted = player.game.state.unownedTracks().sorted(by: { (a: Track, b: Track) -> Bool in
            a.length > b.length
        })
        if !tracksSorted.isEmpty && player.canAffordTrack(tracksSorted[0]) {
            return .playTrack({ (tracks: [Track]) -> Int in
                return tracks.index(of: tracksSorted[0])!
            }, { _ in })
        }

        if !tracksSorted.isEmpty {
            log.debug("Biggest Track: \(tracksSorted[0])")
        }

        return .drawCards({ (colors: [Color]) -> Int? in
            if tracksSorted.isEmpty {
                log.debug("Drawing Random")
                return nil
            }
            let rv = BasicAIPlayerInterface.smartDraw(player: self.player, target: tracksSorted[0], options: colors)
            if rv != nil {
                log.debug("Drawing \(colors[rv!])")
            } else {
                log.debug("Drawing Random")
            }
            return rv
        }, { _ in log.info("Hand: \(self.player.hand)") })
    }
}
