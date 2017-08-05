// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import ConductorCore

if CommandLine.argc < 3 {
    print("Usage: \(CommandLine.arguments[0]) [rules.json] [map.json]")
    exit(1)
}

let rules = try! Rules(fromJSONFile: CommandLine.arguments[1])
let board = try! Board(fromJSONFile: CommandLine.arguments[2])
let game = Game(withRules: rules, board: board, andPlayers: CLIPlayerInterface(), CLIPlayerInterface())

/*
let paris = board.cityForName("Paris")!
let frankfurt = board.cityForName("Frankfurt")!
let munchen = board.cityForName("Munchen")!
let zurich = board.cityForName("Zurich")!

game.state.tracks[board.tracksBetween(paris, and: frankfurt)[0]] = game.players[0]
game.state.tracks[board.tracksBetween(frankfurt, and: munchen)[0]] = game.players[0]
game.state.tracks[board.tracksBetween(munchen, and: zurich)[0]] = game.players[0]
print(game.state.playerMeetsDestination(game.players[0], Destination(from: paris, to: zurich, length: 7)))
*/

game.start()

print(board.generateDestination())
