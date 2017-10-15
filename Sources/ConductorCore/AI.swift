// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public class AI: PlayerInterface {
    public weak var player: Player!

    public init() {}

    public func startingGame() {}

    public func startingTurn(_ turn: Int) {
        log.debug("=== \(String(describing: type(of: self))) Player \(player.game.players.index(of: player)!) " +
            "Starting Turn \(turn / player.game.players.count) ===")
        log.debug("Active Destinations: \(player.destinations) \(player.destinations.map({ player.game.playerMeetsDestination(player, $0) }))")
        log.debug("Hand: \(player.hand)")

        for p in player.game.players {
            log.debug("Player \(player.game.players.index(of: p)!) Owns: \(player.game.tracksOwnedBy(p))")
        }
    }

    public func actionToTakeThisTurn(_ turn: Int) -> Action {
        log.error("Shouln't run this function, need to override in subclass")
        fatalError()
    }

    public func actionCompleted(_ action: Action) {}

    class func smartDraw(player: Player, target: Track, options: [Color]) -> Int? {
        var color = target.color
        if target.color == .unspecified {
            color = player.mostColorInHand()
        }

        if let rv = options.index(of: color) {
            return rv
        } else {
            return nil
        }
    }

    class func playCards(cost: Int, color: Color, hand: [Color:Int], player: Player) -> [Color] {
        var rv: [Color] = []
        let loc = hand[.locomotive]!
        rv.append(contentsOf: Array(repeating: .locomotive, count: loc))
        let nc = cost - loc

        if color == .unspecified {
            rv.append(contentsOf: Array(repeating: player.mostColorInHand(), count: nc))
        }

        return rv
    }

}
