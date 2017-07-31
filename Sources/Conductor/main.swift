// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import ConductorCore

let rules = try! Rules(fromJSONFile: "Tests/Resources/rules.json")
print(rules.startingHandSize)
let board = try! Board(fromJSONFile: "Tests/Resources/europe.json")
let game = Game(withRules: rules, board: board, andPlayers: CLIPlayerInterface(), CLIPlayerInterface())
print(board.cities.count)
