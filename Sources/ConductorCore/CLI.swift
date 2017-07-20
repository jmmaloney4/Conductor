// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public class CLIDelegate: PlayerDelegate {
    public init() {}

    private func boolPrompt(_ prompt: String) -> Bool {
        while true {
            print(prompt, terminator: "? [y/n]: ")

            guard let line = readLine() else {
                fatalError()
            }

            switch line {
            case "y", "Y", "yes", "Yes", "YES":
                return true
            case "n", "N", "no", "No", "NO":
                return false
            default:
                continue
            }
        }
    }

    private func optionListPrompt(_ options: String...) -> Int { return optionListPrompt(options) }
    private func optionListPrompt(_ options: [String]) -> Int {
        for (k, option) in options.enumerated() {
            print("\(k) \(option)")
        }
        while true {
            print("[0-\(options.count - 1)]", terminator: ": ")
            guard let line = readLine() else {
                continue
            }

            let rv = Int(line)
            if rv == nil || rv! < 0 || rv! > options.count - 1 {
                continue
            } else {
                return rv!
            }
        }
    }

    public func keepDestinations(_ destinations: [Destination]) -> [Destination] {
        print("Destinations Drawn: ")
        print(destinations.map({ $0.description }).joined(separator: "\n"))

        var rv: [Destination] = []
        destLoop: for dest in destinations {
            if boolPrompt("Keep \(dest)") {
                rv.append(dest)
            }
        }
        return rv
    }

    public func currentDestinations(_ destinations: [Destination]) {
        print("Current Destinations: ")
        print(destinations.map({ $0.description }).joined(separator: "\n"))
    }

    public func actionThisTurn() -> Game.Action {
        let action = optionListPrompt("Draw Cards", "Play Track", "New Destinations", "Build Station")
        switch action {
        case 0:
            return .drawCards
        case 1:
            return .playTrack
        case 2:
            return .newDestinations
        case 3:
            return .buildStation
        default:
            fatalError()
        }
    }

    public func whichCardToTake(_ faceUpCards: [Track.Color]) -> Int? {
        var options = faceUpCards.map({ $0.description })
        options.append("Draw From Random Pile")

        let i = optionListPrompt(options)
        switch i {
        case faceUpCards.count: // Draw from pile
            return nil
        default:
            return i
        }
    }

    public func whichTrackToClaim(_ avaliableTracks: [Track]) -> Int {
        return optionListPrompt(avaliableTracks.map({ $0.description }))
    }
}
