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
let mapPathOption = StringOption(shortFlag: "m", longFlag: "map", required: true,
                            helpMessage: "Path to the map file.")
let outPathOption = StringOption(shortFlag: "o", longFlag: "out", required: false,
                            helpMessage: "Path to the output file.")
let playerTypesOption = StringOption(shortFlag: "p", longFlag: "players", required: true,
                            helpMessage: "Path to the output file.")
let helpOption = BoolOption(shortFlag: "h", longFlag: "help",
                      helpMessage: "Prints a help message.")
let verbosityOption = CounterOption(shortFlag: "v", longFlag: "verbose",
                              helpMessage: "Print verbose messages. Specify multiple times to increase verbosity.")

cli.addOptions(rulesPathOption, mapPathOption, outPathOption, playerTypesOption, helpOption, verbosityOption)

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
let mapPath = mapPathOption.value!
let outPath = outPathOption.value // optional
let playerTypes = playerTypesOption.value!
let verbosity = verbosityOption.value

Conductor.InitLog()
let log = SwiftyBeaver.self

switch verbosity {
case 0:
    Conductor.console.minLevel = .warning
    log.debug("Verbosity set to warning")
case 1:
    Conductor.console.minLevel = .info
    log.debug("Verbosity set to info")
case 2:
    Conductor.console.minLevel = .debug
    log.debug("Verbosity set to debug")
default:
    Conductor.console.minLevel = .verbose
    log.debug("Verbosity set to verbose")
}

/*
let rules = try! Rules(fromJSONFile: CommandLine.arguments[1])
let board = try! Board(fromJSONFile: CommandLine.arguments[2])
let game = Game(withRules: rules, board: board, andPlayers: CLI(), CLI())
print(game.start())
*/

func runSimulations(interfaces: [PlayerKind], games: Int) -> [[Int]] {
    let group = DispatchGroup()
    var rv: [[Int]] = []
    for i in 0..<games {
        group.enter()
        DispatchQueue.global(qos: .default).async {
            var players: [PlayerInterface] = []
            for i in interfaces {
                switch i {
                case .bigTrackAI:
                    players.append(BigTrackAI())
                case .destinationAI:
                    players.append(DestinationAI())
                case .cli:
                    players.append(CLI())
                }
            }

            let rules = try! Rules(fromJSONFile: CommandLine.arguments[1])
            let board = try! Board(fromJSONFile: CommandLine.arguments[2])
            let game = Game(withRules: rules, board: board, andPlayers: players)
            let res = game.start()
            log.debug("\(res)")

            if res.count == 0 {
                log.error("Game Failed")
            }

            rv.append(res)
            log.info("Simulation \(i+1)/\(games): \(res)")

            group.leave()
        }
    }

    group.wait()
    return rv
}

func totalWins(_ scores: [[Int]]) -> [Int] {
    var rv = Array(repeating: 0, count: scores[0].count)
    for game in scores {
        let sorted = game.sorted(by: { $0 > $1 })
        let winner = sorted[0]
        // If theres a tie nobody wins
        if game.filter({ $0 == winner }).count == 1 {
            rv[game.index(of: winner)!] += 1
        }
    }
    return rv
}

func totalScores(_ scores: [[Int]]) -> [Int] {
    var rv = Array(repeating: 0, count: scores[0].count)
    for game in scores {
        for (i, v) in game.enumerated() {
            rv[i] += v
        }
    }
    return rv
}

var averagePoints: [Float] = []
var wins: [Float] = []

for i in 1...6 {
    var interfaces: [PlayerKind] = [.destinationAI]
    interfaces.append(contentsOf: Array(repeating: .bigTrackAI, count: i))

    var scores = runSimulations(interfaces: interfaces, games: 10)

    log.info(totalWins(scores))
    log.info(totalScores(scores))
    log.info(totalScores(scores).map({ Float($0) / Float(scores.count) }))
    log.info(totalWins(scores).map({ Float($0) / Float(scores.count) }))

    averagePoints.append(totalScores(scores).map({ Float($0) / Float(scores.count) })[0])
    wins.append(totalWins(scores).map({ Float($0) / Float(scores.count) })[0])
}

log.info(averagePoints)
log.info(wins)
