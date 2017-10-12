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
        print("\n=== AI Player \(player.game.players.index(of: player)!) " +
            "Starting Turn \(turn / player.game.players.count) ===")
        print("Active Destinations: \(player.destinations) \(player.destinations.map({ player.game.state.playerMeetsDestination(player, $0) }))")
        print("Hand: \(player.hand)")

        for p in player.game.players {
            print("Player \(player.game.players.index(of: p)!) Owns: \(player.game.state.tracksOwnedBy(p))")
        }
    }

    public func actionToTakeThisTurn(_ turn: Int) -> Action {
        print(turn)

        var tracksSorted = player.game.state.unownedTracks().sorted(by: { (a: Track, b: Track) -> Bool in
            a.length < b.length
        })
        if player.canAffordTrack(tracksSorted[0]) {
            return .playTrack({ (tracks: [Track]) -> Int in
                return tracks.index(of: tracksSorted[0])!
            }, { _ in })
        }

        return .drawCards({ (colors: [Color]) -> Int? in
            print("Drawing")
            return nil
        }, { _ in print("Hand: \(self.player.hand)") })

        /*

        // var destination: Destination! = Destination(from: player.game.board.cityForName("Venezia")!, to: player.game.board.cityForName("Pamplona")!, length: 8)
        var destination: Destination! = nil
        for dest in player.destinations where !player.game.state.playerMeetsDestination(player, dest) {
            destination = dest
            break
        }
        if destination == nil {
            return .getNewDestinations({ _ in
                return [0]
            }, { (kept) in })
        }
        print(destination)

        if let (route, _) = player.game.board.findShortesAvaliableRoute(between: destination.cities[0], and: destination.cities[1], to: player) {
            print(route)

            for i in 1..<route.count {
                let tracks = player.game.board.tracksBetween(route[i-1], and: route[i])
                for track in tracks {
                    if player.game.state.tracks[track] == nil {
                        if player.canAffordTrack(track) {
                            return .playTrack({ (tracks: [Track]) -> Int in
                                return tracks.index(of:track)!
                            }, {_ in })
                        } else {
                            return .drawCards({ (colors: [Color]) -> Int? in
                                print("Drawing")
                                return nil
                            }, { _ in print("Hand: \(self.player.hand)") })
                        }
                    }
                }
            }
        }

        for track in player.game.state.unownedTracks() where player.canAffordTrack(track) {
            return .playTrack({ (tracks: [Track]) -> Int in
                return tracks.index(of:track)!
            }, {_ in})
        }

        return .drawCards({ (colors: [Color]) -> Int? in
            print("Drawing")
            return nil
        }, { _ in print("Hand: \(self.player.hand)") })
         */
    }
}
