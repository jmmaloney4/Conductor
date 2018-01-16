// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

// Abstract AI Class
public class AI: PlayerInterface {
    public weak var player: Player!
    public var kind: PlayerKind {
        log.error("Abstract Class")
        fatalError()
    }

    public init() {}

    public func startingGame() {}

    public func pickInitialDestinations(_ destinations: [Destination]) -> [Int] {
        let sorted = destinations.sorted(by: { $0.length < $1.length })
        let index = destinations.index(where: { $0 == sorted[0] })!
        return [index]
    }

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

    public func playedTrack(_ track: Track) {
        log.debug("Playing Track on \(track)")
    }

    public func keptDestinations(_ destinations: [Destination]) {
        log.debug("Keeping: \(destinations.map({ "\($0)" }).joined(separator: ", "))")
    }

    public func drewCard(_ color: Color) {
        log.debug("Drew a \(color)")
    }

}
