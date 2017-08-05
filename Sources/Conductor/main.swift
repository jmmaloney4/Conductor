// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import ConductorCore
import SwiftyJSON
import CommandLineKit

let cli = CommandLineKit.CommandLine()

let rulesPath = StringOption(shortFlag: "r", longFlag: "rules", required: true, helpMessage: "A JSON File specifying the rules to be followed in this game")
let mapPath = StringOption(shortFlag: "m", longFlag: "map", required: true, helpMessage: "A JSON File specifying the map to be used in this game")
let gameSavePath = StringOption(shortFlag: "s", longFlag: "save", helpMessage: "A File path to save the game to")

cli.addOptions(rulesPath, mapPath, gameSavePath)

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

/*

let json: JSON = [["action": "seed", "seed": UInt32(523313113)]]
print(json.rawString()!)

if CommandLine.argc < 3 {
    print("Usage: \(CommandLine.arguments[0]) [rules.json] [map.json]")
    exit(1)
}



let rules = try! Rules(fromJSONFile: CommandLine.arguments[1])
let board = try! Board(fromJSONFile: CommandLine.arguments[2])
let game = Game(withRules: rules, board: board, andPlayers: CLIPlayerInterface(), CLIPlayerInterface())

let paris = board.cityForName("Paris")!
let frankfurt = board.cityForName("Frankfurt")!
let munchen = board.cityForName("Munchen")!
let zurich = board.cityForName("Zurich")!

game.state.tracks[board.tracksBetween(paris, and: frankfurt)[0]] = game.players[0]
game.state.tracks[board.tracksBetween(frankfurt, and: munchen)[0]] = game.players[0]
game.state.tracks[board.tracksBetween(munchen, and: zurich)[0]] = game.players[0]
print(game.state.playerMeetsDestination(game.players[0], Destination(from: paris, to: zurich, length: 7)))

game.start()

print(board.generateDestination())
*/
