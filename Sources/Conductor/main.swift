// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import ConductorCore
/*
internal var bluePlayer = Player(withColor: .blue)
internal var redPlayer = Player(withColor: .red)

bluePlayer.initDelegate(CLIDelegate.self)
redPlayer.initDelegate(CLIDelegate.self)

internal var board: Board = standardEuropeMap()
print(board.toJSON())
/*
internal var game: Game = Game(withPlayers: bluePlayer, redPlayer)
_ = game.run()
*/

 */

let board = try! Board(fromJSONFile: "/Users/jack/Developer/Conductor/europe.json")
let game = Game(withBoard: board, andPlayers: CLIPlayerInterface(), CLIPlayerInterface())


