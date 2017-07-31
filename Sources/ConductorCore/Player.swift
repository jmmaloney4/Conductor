// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public protocol PlayerInterface {
    weak var player: Player! { get set }
}

// Mostly storage-only, game logic in the Game class
public class Player: Hashable {
    weak var game: Game!
    var interface: PlayerInterface
    var hand: [Color:Int] = [:]
    var destinations: [Destination] = []

    public var hashValue: Int { return ObjectIdentifier(self).hashValue }
    public static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    init(withInterface interface: PlayerInterface, andGame game: Game) {
        self.interface = interface
        self.interface.player = self
        self.game = game
    }
}
