// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftPriorityQueue

public class State: Hashable {
    weak var game: Game!
    var parent: State?
    public var tracks: [Track:Player] = [:]
    public var stations: [City:Player] = [:]
    var cards: [Color] = []
    var turn: Int = 0

    public var hashValue: Int { return ObjectIdentifier(self).hashValue }
    public static func == (lhs: State, rhs: State) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    init(withGame game: Game) {
        self.game = game
        for _ in 0..<game.rules.get(Rules.kFaceUpCards).int! {
            cards.append(game.draw())
        }
    }

    convenience init(fromParent parent: State) {
        self.init(withGame: parent.game)
        self.parent = parent
        self.tracks = parent.tracks
        self.stations = parent.stations
        self.cards = parent.cards
        self.turn = parent.turn
    }

    func playerOwnsTrack(_ player: Player, _ track: Track) -> Bool {
        return tracks[track] == player
    }

    func isTrackUnowned(_ track: Track) -> Bool {
        return tracks[track] == nil
    }

    func tracksOwnedBy(_ player: Player) -> [Track] {
        var rv: [Track] = []
        for (track, _) in tracks where playerOwnsTrack(player, track) {
            rv.append(track)
        }
        return rv
    }

    func unownedTracks() -> [Track] {
        var rv: [Track] = []
        for track in game.board.getAllTracks() where isTrackUnowned(track) {
            rv.append(track)
        }
        return rv
    }

    func stationsOwnedBy(_ player: Player) -> [City] {
        var rv: [City] = []
        for (city, p) in stations where p == player {
            rv.append(city)
        }
        return rv
    }

    func checkForMaxLocomotives() {
        if cards.reduce(0, { res, color in
            if color == .locomotive {
                return res + 1
            } else {
                return res
            }}) >= game.rules.get(Rules.kMaxLocomotivesFaceUp).int! {
            // Refresh cards, too many locomotives
            var newCards: [Color] = []
            for _ in 0..<game.rules.get(Rules.kFaceUpCards).int! {
                newCards.append(game.draw())
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
        cards.append(game.draw())
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
