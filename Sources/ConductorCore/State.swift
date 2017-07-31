// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

internal class State {
    weak var game: Game!
    var parent: State? = nil
    var tracks: [Track:Player?] = [:]
    var stations: [City:Player?] = [:]
    var cards: [Color] = []
    var turn: Int = 0

    init(withGame game: Game) {
        self.game = game
    }

    convenience init(fromParent parent: State) {
        self.init(withGame: parent.game)
        self.parent = parent
        self.tracks = parent.tracks
        self.stations = parent.stations
        self.cards = parent.cards
        self.turn = parent.turn
    }
}
