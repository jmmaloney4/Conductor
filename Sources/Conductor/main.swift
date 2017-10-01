// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import ConductorCore
import SwiftyJSON
import CommandLineKit

if CommandLine.argc < 3 {
    print("Usage: \(CommandLine.arguments[0]) [rules.json] [map.json]")
    exit(1)
}

let rules = try! Rules(fromJSONFile: CommandLine.arguments[1])
let board = try! Board(fromJSONFile: CommandLine.arguments[2])
let game = Game(withRules: rules, board: board, andPlayers: BasicAIPlayerInterface(), BasicAIPlayerInterface(), BasicAIPlayerInterface(), BasicAIPlayerInterface())
/*
let tracks: [(String, String, Int)] = [("Brest", "Dieppe", 0),
                                  ("Brest", "Paris", 0),
                                  ("Paris", "Pamplona", 0),
                                  ("Paris", "Pamplona", 1),
                                  ("Pamplona", "Marseille", 0),
                                  ("Barcelona", "Marseille", 0)]

for (a, b, i) in tracks {
    game.state.tracks[board.tracksBetween(board.cityForName(a)! , and: board.cityForName(b)!)[i]] = game.players[0]
}

let brest = board.cityForName("Brest")!
let frankfurt = board.cityForName("Frankfurt")!
// Destination(from: brest, to: frankfurt, length: 6)
print(board.findShortesAvaliableRoute(between: brest, and: frankfurt, to: game.players[1]))

*/
/*
let paris = board.cityForName("Paris")!
let frankfurt = board.cityForName("Frankfurt")!
let munchen = board.cityForName("Munchen")!
let zurich = board.cityForName("Zurich")!
let wien = board.cityForName("Wien")!
let zagrab = board.cityForName("Zagrab")!
let brest = board.cityForName("Brest")!
let pamploma = board.cityForName("Pamploma")!
let dieppe = board.cityForName("Dieppe")!

game.state.tracks[board.tracksBetween(paris, and: frankfurt)[0]] = game.players[0]
game.state.tracks[board.tracksBetween(paris, and: frankfurt)[1]] = game.players[0]
game.state.tracks[board.tracksBetween(frankfurt, and: munchen)[0]] = game.players[0]
game.state.tracks[board.tracksBetween(munchen, and: zurich)[0]] = game.players[0]
game.state.tracks[board.tracksBetween(munchen, and: wien)[0]] = game.players[0]
//game.state.tracks[board.tracksBetween(wien, and: zagrab)[0]] = game.players[0]
print(game.state.playerMeetsDestination(game.players[0], Destination(from: paris, to: zurich, length: 7)))

print(board.findShortesAvaliableRoute(between: zurich, and: zagrab, to: game.players[0])!)
*/

print(game.start())

print(board.generateDestination())

/*

 let cli = CommandLineKit.CommandLine()

 let server = BoolOption(longFlag: "server", helpMessage: "Set to configure this process as a server")
 let rulesPath = StringOption(shortFlag: "r", longFlag: "rules", helpMessage: "Server Only, a JSON File specifying the rules to be followed in this game")
 let boardPath = StringOption(shortFlag: "m", longFlag: "board", helpMessage: "Server Only, a JSON File specifying the board to be used in this game")
 let gameSavePath = StringOption(shortFlag: "s", longFlag: "save", helpMessage: "Server Only, a File path to save the game to")

 let host = StringOption(shortFlag: "h", longFlag: "host", helpMessage: "Client Only, the server to connect to")
 let port = IntOption(shortFlag: "p", longFlag: "port", helpMessage: "For Client, the port to connect to the server on. For Server, the port to open the server on.")

 let help = Option(longFlag: "help", helpMessage: "Prints a help message")

 cli.addOptions(server, rulesPath, boardPath, gameSavePath, host, port, help)

 do {
 try cli.parse()
 } catch {
 cli.printUsage(error)
 exit(EX_USAGE)
 }

 if help.wasSet {
 cli.printUsage()
 exit(0)
 }

 if server.value {

 if !rulesPath.wasSet || !boardPath.wasSet || !gameSavePath.wasSet || !port.wasSet {
 print("Missing server-required arguments")
 cli.printUsage()
 exit(EX_USAGE)
 }

 let rules = try! Rules(fromJSONFile: rulesPath.value!)
 let board = try! Board(fromJSONFile: boardPath.value!)
 let game = Game(withRules: rules, board: board)

 var server = try! Server(port: 5555, game: game)
 print("Connect Clients, then hit [enter]", terminator: "")

 guard let line = readLine() else {
 fatalError()
 }

 } else {
 // Client
 if !host.wasSet || !port.wasSet {
 print("Missing client-required arguments")
 cli.printUsage()
 exit(EX_USAGE)
 }

 let client = try! Client(host: host.value!, port: port.value!)
 }



 */
