// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

internal class State: Hashable {
    weak var game: Game!
    var parent: State?
    var tracks: [Track:Player?] = [:]
    var stations: [City:Player?] = [:]
    var cards: [Color] = []
    var turn: Int = 0

    var hashValue: Int { return ObjectIdentifier(self).hashValue }
    static func == (lhs: State, rhs: State) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    init(withGame game: Game) {
        self.game = game
        for _ in 0..<game.rules.faceUpCards {
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

    func tracksOwnedBy(_ player: Player) -> [Track] {
        var rv: [Track] = []
        for (track, p) in tracks where p == player {
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
        if cards.reduce(0, { (res, color) in
            if color == .locomotive {
                return res + 1
            } else {
                return res
            }}) >= game.rules.maxLocomotivesFaceUp {
            // Refresh cards, too many locomotives
            var newCards: [Color] = []
            for _ in 0..<game.rules.faceUpCards {
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
}
