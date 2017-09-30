// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public class BasicAIPlayerInterface: PlayerInterface {
    public weak var player: Player!

    public init() {}

    public func startingGame() {}

    public func startingTurn(_ turn: Int) {}

    public func actionToTakeThisTurn(_ turn: Int) -> Action {
        print(turn)
        return .drawCards({_ in return 0 }, {_ in})
    }
}
