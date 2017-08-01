// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public class CLIPlayerInterface: PlayerInterface {
    public weak var player: Player! = nil

    public init() {}

    public func startingGame() {}

    public func startingTurn(_ turn: Int) {
        print("\n\n === Player \(player.game.players.index(of: player)!) Starting Turn ===")
        print("Active Destinations: \(player.destinations)")
        print("Hand: \(player.hand)")

        for p in player.game.players {
            print("Player \(player.game.players.index(of: p)!) Owns: \(player.game.state.tracksOwnedBy(p))")
        }
    }
}
