// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public class BigTrackAI: AI {
    public override var kind: PlayerKind {
        return .bigTrackAI
    }

    public override func actionToTakeThisTurn(_ turn: Int) -> Action {
        log.verbose(turn)

        var tracksSorted = player.game.unownedTracks().filter({ $0.length <= player.trainsLeft() })
            .sorted(by: { (a: Track, b: Track) -> Bool in
            a.length > b.length
        })
        if !tracksSorted.isEmpty && player.canAffordTrack(tracksSorted[0]) {
            return .playTrack({ (tracks: [Track]) -> (Int, Int?, Color?) in
                return (tracks.index(of: tracksSorted[0])!, nil, nil)
            })
        }

        if !tracksSorted.isEmpty {
            log.verbose("Biggest Track: \(tracksSorted[0])")
        }

        return .drawCards({ (colors: [Color]) -> Int? in
            if tracksSorted.isEmpty {
                log.verbose("Drawing Random")
                return nil
            }
            let rv = AI.smartDraw(player: self.player, target: tracksSorted[0], options: colors)
            if rv != nil {
                log.verbose("Drawing \(colors[rv!])")
            } else {
                log.verbose("Drawing Smart Random")
            }
            return rv
        })
    }
}
