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

#if os(Linux)
let EX_USAGE: Int32 = 64 // swiftlint:disable:this identifier_name
#endif

let cli = CommandLineKit.CommandLine()

let rulesPathOption = StringOption(shortFlag: "r", longFlag: "rules", required: true,
                                   helpMessage: "Path to the rules file.")
let boardPathOption = StringOption(shortFlag: "b", longFlag: "board", required: true,
                                   helpMessage: "Path to the board file.")
let outPathOption = StringOption(shortFlag: "o", longFlag: "out", required: false,
                                 helpMessage: "Path to the output file.")
let logPathOption = StringOption(shortFlag: "l", longFlag: "log", required: false,
                                 helpMessage: "Path to the log file.")
let configPathOption = StringOption(shortFlag: "c", longFlag: "config", required: false,
                                    helpMessage: "Path to the simulation configuration file.")
let playerTypesOption = StringOption(shortFlag: "p", longFlag: "players", required: true,
                                     helpMessage: "The type of players that will be used.")
let helpOption = BoolOption(shortFlag: "h", longFlag: "help",
                            helpMessage: "Prints a help message.")
let verbosityOption = CounterOption(shortFlag: "v", longFlag: "verbose",
                                    helpMessage: "Print verbose messages. Specify multiple times to increase verbosity.")
let syncOption = BoolOption(shortFlag: "s", longFlag: "sync",
                            helpMessage: "Run the simulations synchronously (will default to running asynchronously).")

cli.addOptions(rulesPathOption, boardPathOption, outPathOption, logPathOption,
               configPathOption, playerTypesOption, helpOption, verbosityOption, syncOption)

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
let logPath = logPathOption.value // optional
let configPath = configPathOption.value // optional
let playerTypes = playerTypesOption.value!
let verbosity = verbosityOption.value
let async = !syncOption.value

Conductor.initLog()
if logPath != nil {
    Conductor.addLogFile(path: logPath!)
}
log.info("Logging to \(logPath ?? "none")")

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

log.info("Loading rules from \(rulesPath)")
log.info("Rules: \(try! loadJSONFile(path: rulesPath).description)")
log.info("Loading board from \(boardPath)")
log.debug("Board: \(try! Board(fromJSONFile: boardPath))")
if outPath != nil {
    try! FileManager.default.createDirectory(at: URL(fileURLWithPath: outPath!), withIntermediateDirectories: true, attributes: nil)
}
log.info("Writing output to \(outPath ?? "none")")
log.info("Running simulation asynchronously: \(async)")

var players: [PlayerKind] = playerStringToPlayerKind(playerTypes)

log.info("players: \(players)")

/// Simulate a game using the specified rules, board and players.  Run the specified
/// number of simulations and output the results to the specified output file.
public func simulate(rulesFile: String, boardFile: String, players: [PlayerKind],
                     numSims: Int, outFile: String?) {
    /// run simulations
    log.info("Simulation starting: \(players)")
    let sim = Simulation(rules: rulesFile, board: boardFile, players: players)
    let res = sim.simulate(numSims, async: async)
    log.info("Simulation complete: \(players)")

    // output results to output file
    if outPath != nil {
        let outFile = outPath! + "/\(playerKindsToString(players)).csv"
        do {
            let out = players.map { $0.description }.joined(separator: ",") + "\n" + res.csv()
            log.warning(outFile)
            try out.write(to: URL(fileURLWithPath: outFile), atomically: true, encoding: .utf8)
            log.info("Wrote result of \(res.count) simulations to \(outFile)")
        } catch {
            log.error(error)
        }
    }
    
    // log simulation summary to console and log file
    log.info("Average Points: [\(players.enumerated().map({ i, player in return (player, res.averagePoints()[i]) }).map({ "\($0): \($1)" }).joined(separator: ", "))]")
    log.info("Winrate: [\(players.enumerated().map({ i, player in return (player, res.winrate()[i]) }).map({ "\($0): \($1)" }).joined(separator: ", "))]")
}

if players.contains(.cli) {
    // Only run one game, not a simulation
    let rules = try! loadJSONFile(path: rulesPath)
    let board = try! Board(fromJSONFile: boardPath)
    let game = Game(withRules: rules, board: board, andPlayerTypes: players)
    print(game.start())
} else {
    // Simulation
    if configPath != nil {
        log.info("Using JSON config file: \(configPath!)")
        
        let config = try! loadJSONFile(path: configPath!)
        
        let simulations = config["simulations"].int!
        log.info("running \(simulations) simulations")
        
        let playerKinds = config["players"].array!.map({ return $0.string! }).map({ return playerStringToPlayerKind($0) })
        
        for (i, players) in playerKinds.enumerated() {
            let outFile = outPath! + "/\(i).csv"
            simulate(rulesFile: rulesPath, boardFile: boardPath, players: players,
                     numSims: simulations, outFile: outFile)
        }
    }
    else {
        log.info("NOT using JSON config file")
        
        // run 50 simulations
        simulate(rulesFile: rulesPath, boardFile: boardPath, players: players,
                 numSims: 1, outFile: outPath)
    }
}
