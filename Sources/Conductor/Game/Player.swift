// Copyright © 2017-2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Squall

enum IllegalMoveError: Error {}

enum PlayerAction {
    typealias DrawSelectionCallback = () -> Void
    typealias DestinationSelectionCallback = ([Destination]) -> ([Destination])

    case draw(DrawSelectionCallback)
    case buildTrack(CityPair)
    case newDestinations
    case buildStation(String)
}

protocol GameDataDelegate {
    var rules: Rules { get }
}

protocol Player {
    func initialDestinationSelection(delegate: GameDataDelegate) -> PlayerAction.DestinationSelectionCallback
}

class RandomPlayer: Player {
    var rng = Gust()

    func initialDestinationSelection(delegate: GameDataDelegate) -> PlayerAction.DestinationSelectionCallback {
        { options in
            let len = delegate.rules.minimumDestinations + Int(self.rng.next(upperBound: UInt(options.count - delegate.rules.minimumDestinations)))

            return Array(options.shuffled(using: &self.rng).prefix(upTo: len))
        }
    }
}
