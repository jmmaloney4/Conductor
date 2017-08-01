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
game.start()

print(board.generateDestination())
