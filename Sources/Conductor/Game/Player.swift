// Copyright © 2017-2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

enum IllegalMoveError: Error {}

enum PlayerAction {
    typealias DrawSelectionCallback = () -> Void
    typealias DestinationSelectionCallback = ([Destination]) -> (Int)

    case draw(DrawSelectionCallback)
    case buildTrack(CityPair)
    case newDestinations
    case buildStation(String)
}

protocol Player {
    func initialDestinationSelection() -> PlayerAction.DestinationSelectionCallback
}
