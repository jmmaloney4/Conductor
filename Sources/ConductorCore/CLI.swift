// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public class CLIPlayerInterface: PlayerInterface {
    public weak var player: Player! = nil

    public init() {}

    public func startingGame() {}

    public func startingTurn(_ turn: Int) {
        print("\n=== Player \(player.game.players.index(of: player)!) " +
            "Starting Turn \(turn / player.game.players.count) ===")
        print("Active Destinations: \(player.destinations) \(player.destinations.map({ player.game.state.playerMeetsDestination(player, $0) }))")
        print("Hand: \(player.hand)")

        for p in player.game.players {
            print("Player \(player.game.players.index(of: p)!) Owns: \(player.game.state.tracksOwnedBy(p))")
        }
    }

    private func promptYesNo(_ prompt: String) -> Bool {
        while true {
            print(prompt, terminator: "? [y/n]: ")

            guard let line = readLine() else {
                fatalError()
            }

            switch line {
            case "y", "Y", "yes", "Yes", "YES", "1":
                return true
            case "n", "N", "no", "No", "NO", "0":
                return false
            default:
                continue
            }
        }
    }

    func printList(_ options: String...) { printList(options) }
    func printList(_ options: [String]) {
        for (k, option) in options.enumerated() {
            var str: String = ""
            if options.count >= 10 {
                str = String(format: "%02d", k)
            } else {
                str = "\(k)"
            }
            print("\(str) \(option)")
        }
    }

    func promptInCount(_ count: Int) -> Int {
        while true {
            print("[0-\(count - 1)]", terminator: ": ")
            guard let line = readLine() else {
                continue
            }

            let rv = Int(line)
            if rv == nil || rv! < 0 || rv! > count - 1 {
                continue
            } else {
                return rv!
            }
        }
    }

    public func actionToTakeThisTurn(_ turn: Int) -> Action {
        let options: [Action] = [
            .drawCards({ cards in
                var toPrint = cards.map({ "\($0)" })
                toPrint.append("Draw From Pile")

                print("\n=> Choose Card:")
                self.printList(toPrint)
                let rv = self.promptInCount(toPrint.count)
                if rv >= cards.count {
                    return nil
                } else {
                    return rv
                }
            }, { color in
                print("Drew a \(color)")
            }),
            .getNewDestinations({ destinations in
                print("\n=> Choose Destinations:")
                self.printList(destinations.map({ "\($0)" }))

                var rv: [Int] = []
                for (k, dest) in destinations.enumerated() {
                    if self.promptYesNo("Keep \(dest)") {
                        rv.append(k)
                    }
                }
                return rv
            }, { kept in
                print("Keeping: \(kept.map({ "\($0)" }).joined(separator: ", "))")
            }),
            .playTrack({ tracks in
                print("\n=> Choose Tracks: ")
                self.printList(tracks.map({ "\($0)" }))
                return self.promptInCount(tracks.count)
            }, { DestinationAIPlayerInterface.playCards(cost: $0, color: $1, hand: $2, player: self.player) }, { track in
                print("Playing Track on \(track)")
            }),
            .playStation({ cities in
                print("=> Choose City: ")
                self.printList(cities.map({ "\($0.name)" }))
                return self.promptInCount(cities.count)
            }, { city in
                print("Placing Station at \(city)")
            })
        ]

        print("\n=> Choose Action: ")
        printList(options.map({ "\($0)" }))

        return options[promptInCount(options.count)]
    }
}
