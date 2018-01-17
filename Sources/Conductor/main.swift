// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import ConductorCore
import SwiftyJSON
import CommandLineKit
import SwiftyBeaver
import Dispatch

let cli = CommandLineKit.CommandLine()

let rulesPathOption = StringOption(shortFlag: "r", longFlag: "rules", required: true,
                            helpMessage: "Path to the rules file.")
let boardPathOption = StringOption(shortFlag: "b", longFlag: "board", required: true,
                            helpMessage: "Path to the board file.")
let outPathOption = StringOption(shortFlag: "o", longFlag: "out", required: false,
                            helpMessage: "Path to the output file.")
let playerTypesOption = StringOption(shortFlag: "p", longFlag: "players", required: true,
                            helpMessage: "Path to the output file.")
let helpOption = BoolOption(shortFlag: "h", longFlag: "help",
                      helpMessage: "Prints a help message.")
let verbosityOption = CounterOption(shortFlag: "v", longFlag: "verbose",
                              helpMessage: "Print verbose messages. Specify multiple times to increase verbosity.")
let syncOption = BoolOption(shortFlag: "s", longFlag: "sync",
                            helpMessage: "Run the simulations sequentially.")

cli.addOptions(rulesPathOption, boardPathOption, outPathOption, playerTypesOption, helpOption, verbosityOption, syncOption)

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

if helpOption.wasSet {
    cli.printUsage()
    exit(0)
}

let rulesPath = rulesPathOption.value!
let boardPath = boardPathOption.value!
let outPath = outPathOption.value // optional
let playerTypes = playerTypesOption.value!
let verbosity = verbosityOption.value
let async = !syncOption.value
print(syncOption.value)


Conductor.initLog()
let log = SwiftyBeaver.self

switch verbosity {
case 0:
    Conductor.console.minLevel = .warning
    log.info("Verbosity set to warning")
case 1:
    Conductor.console.minLevel = .info
    log.info("Verbosity set to info")
case 2:
    Conductor.console.minLevel = .debug
    log.info("Verbosity set to debug")
default:
    Conductor.console.minLevel = .verbose
    log.info("Verbosity set to verbose")
}

log.info("rules: \(rulesPath)")
log.info("board: \(boardPath)")
log.info("output: \(outPath ?? "none")")
log.info("Async: \(async)")

let rules = try! Rules(fromJSONFile: rulesPath)
print(rules.get(Rules.kDeck))

var players: [PlayerKind] = []
for c in playerTypes {
    switch c {
    case "c":
        players.append(.cli)
    case "b":
        players.append(.bigTrackAI)
    case "d":
        players.append(.destinationAI)
    default:
        log.error("\(c) does not corrispond to a type of player")
        fatalError()
    }
}

log.info("players: \(players)")

if players.contains(.cli) {
    // Only run one game, not a simulation
    let rules = try! Rules(fromJSONFile: rulesPath)
    let board = try! Board(fromJSONFile: boardPath)
    let game = Game(withRules: rules, board: board, andPlayerTypes: players)
    print(game.start())
} else {
    // Simulation
    let sim = try! Simulation(rules: rulesPath, board: boardPath, players: players)
    let res = sim.simulate(50, async: async)
    print(res)
    print(res.wins())
    print(res.winrate())
    print(res.totalPoints())
    print(res.averagePoints())
    print(res.csv())

    if outPath != nil {
        do {
            try res.csv().write(to: URL(fileURLWithPath: outPath!), atomically: true, encoding: .utf8)
        }
        catch {
            log.error(error)
        }
    }
}
