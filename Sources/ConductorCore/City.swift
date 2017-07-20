// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Squall

public class Track: CustomStringConvertible {
    public enum Color: CustomStringConvertible {
        case red
        case blue
        case black
        case white
        case orange
        case yellow
        case pink
        case green
        case unspecified // Used only for tracks
        case locomotive // Used for cards, not tracks

        func index() -> Int {
            switch self {
            case .red:
                return 0
            case .blue:
                return 1
            case .black:
                return 2
            case .white:
                return 3
            case .orange:
                return 4
            case .yellow:
                return 5
            case .pink:
                return 6
            case .green:
                return 7
            case .unspecified:
                fatalError()
            case .locomotive:
                return 8
            }
        }

        static var count = 9

        static func colorForIndex(_ index: Int) -> Color {
            switch index {
            case 0:
                return .red
            case 1:
                return .blue
            case 2:
                return .black
            case 3:
                return .white
            case 4:
                return .orange
            case 5:
                return .yellow
            case 6:
                return .pink
            case 7:
                return .green
            case 8:
                return .locomotive
            default:
                fatalError()
            }
        }

        public var description: String {
            switch self {
            case .red:
                return "Red"
            case .blue:
                return "Blue"
            case .black:
                return "Black"
            case .white:
                return "White"
            case .orange:
                return "Orange"
            case .yellow:
                return "Yellow"
            case .pink:
                return "Pink"
            case .green:
                return "Green"
            case .unspecified:
                return "Unspecified"
            case .locomotive:
                return "Locomotive"
            }
        }
    }

    var endpoints: [City]
    var length: Int
    var color: Color
    var tunnel: Bool
    var ferries: Int
    var owner: Player?

    public var description: String { return "\(endpoints[0]) to \(endpoints[1]) (\(length), \(color), \(owner != nil ? owner!.description : "No Owner"))" }

    init(between cityA: City, and cityB: City, length: Int, color: Color, tunnel: Bool = false, ferries: Int = 0, addTracks: Bool = true) {
        endpoints = [cityA, cityB]
        self.length = length
        self.color = color
        self.tunnel = tunnel
        self.ferries = ferries

        if addTracks {
            cityA.addTrack(self)
            cityB.addTrack(self)
        }
    }

    func connectsToCity(_ city: City) -> Bool {
        if endpoints.contains(where: { $0 === city }) {
            return true
        }
        return false
    }

    func getOtherCity(_ city: City) -> City? {
        if !self.connectsToCity(city) {
            return nil
        }
        return endpoints.filter({ $0 !== city })[0]
    }
}

public class City: CustomStringConvertible {
    var name: String
    var tracks: [Track] = []
    public var description: String { return name }

    public init(withName name: String) {
        self.name = name
    }

    internal func addTrack(_ track: Track) {
        tracks.append(track)
    }

    func isAdjacentToCity(_ city: City) -> Bool {
        for track in tracks {
            if track.endpoints.contains(where: {$0 === city}) {
                return true
            }
        }
        return false
    }

    func tracksToCity(_ city: City) -> [Track]? {
        if !self.isAdjacentToCity(city) {
            return nil
        }

        var rv: [Track] = []
        for track in tracks {
            if track.connectsToCity(city) {
                rv.append(track)
            }
        }

        return rv
    }

    func shortestTrackToCity(_ city: City) -> Int {
        return self.tracksToCity(city)!.reduce(Int.max, {
            if $1.length < $0 {
                return $1.length
            } else {
                return $0
            }
        })
    }
}

public class Destination: CustomStringConvertible {
    var endpoints: [City]
    var length: Int
    public var description: String { return "\(endpoints[0]) to \(endpoints[1]) (\(length))" }

    init(from cityA: City, to cityB: City, length: Int) {
        endpoints = [cityA, cityB]
        self.length = length
    }
}

public protocol PlayerDelegate {
    func keepDestinations(_ destinations: [Destination]) -> [Destination]
    func currentDestinations(_ destinations: [Destination])

    func actionThisTurn() -> Game.Action

    func whichCardToTake(_ faceUpCards: [Track.Color]) -> Int?
    func whichTrackToClaim(_ avaliableTracks: [Track]) -> Int
}

public class CLIDelegate: PlayerDelegate {
    public init() {

    }

    func boolPrompt(_ prompt:String) -> Bool {
        while true {
            print(prompt, terminator: "? [y/n]: ")

            guard let line = readLine() else {
                fatalError()
            }

            switch line {
            case "y", "Y", "yes", "Yes","YES":
                return true
            case "n", "N", "no", "No","NO":
                return false
            default:
                continue
            }
        }
    }

    func optionListPrompt(_ options: String...) -> Int { return optionListPrompt(options) }
    func optionListPrompt(_ options: [String]) -> Int {
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
        print(destinations.map({$0.description}).joined(separator: "\n"))

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
        print(destinations.map({$0.description}).joined(separator: "\n"))
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
        var options = faceUpCards.map({$0.description})
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
        return optionListPrompt(avaliableTracks.map({$0.description}))
    }
}

public class Player: CustomStringConvertible {
    public enum Color {
        case black
        case green
        case red
        case blue
        case yellow
    }

    var delegate: PlayerDelegate

    var color: Color
    var trains: Int = 45
    var stations: Int = 3
    var cards: [Int] = Array(repeatElement(0, count:  Track.Color.count))
    var destinations: [Destination] = []

    public var description: String { return "\(color) Player" }

    public init(withDelegate delegate: PlayerDelegate, andColor color: Color) {
        self.delegate = delegate
        self.color = color
    }

    public func addCardToHand(_ color: Track.Color) {
        cards[color.index()] += 1
    }

    func hasEnoughCards(_ numCards: Int, ofColor color: Track.Color) -> Bool {
        return cards[color.index()] >= numCards
    }
}

public class Game {
    var players: [Player]
    var board: Board
    var faceUpCards: [Track.Color] = []
    static let rng: Gust = Gust(seed: UInt32(Date().timeIntervalSinceReferenceDate))

    public init(withPlayers players: Player..., andBoard board: Board = Board.standardEuropeMap()) {
        self.players = players
        self.board = board
    }

    public enum Action {
        case drawCards
        case playTrack
        case newDestinations
        case buildStation
    }

    // 12 of each color (8 colors)
    // 14 locomotive
    // (12 * 8) + 14 = 110
    // 12 / 110 =
    func draw() -> Track.Color {
        let probabilities: [Double] = [
            Double(12)/Double(110),
            Double(12)/Double(110),
            Double(12)/Double(110),
            Double(12)/Double(110),
            Double(12)/Double(110),
            Double(12)/Double(110),
            Double(12)/Double(110),
            Double(12)/Double(110),

            Double(14)/Double(110)
            ]

        let rngout: UInt64 = Game.rng.random()
        let rand = Double(rngout) / Double(UInt64.max)
        var accum = 0.0
        for (i, prob) in probabilities.enumerated() {
            accum += prob
            if rand < accum {
                return Track.Color.colorForIndex(i)
            }
        }

        print("Double Math error")
        return .locomotive
    }

    func newDestinationsForPlayer(_ player: Player, destinations: Int) {
        var temp: [Destination] = []
        for _ in 0..<destinations {
            temp.append(board.generateDestination())
        }
        player.destinations.append(contentsOf: player.delegate.keepDestinations(temp))
        print(player.destinations)
        player.delegate.currentDestinations(player.destinations)
    }

    func drawCardsForPlayer(_ player: Player) {
        let card1 = player.delegate.whichCardToTake(faceUpCards)
        if card1 == nil {
            player.addCardToHand(draw())
        } else {
            let card = faceUpCards.remove(at: card1!)
            player.addCardToHand(card)
            faceUpCards.append(draw())
            if card == .locomotive {
                return // Only one locomotive
            }
        }

        while true {
            let card2 = player.delegate.whichCardToTake(faceUpCards)
            if card2 == nil {
                player.addCardToHand(draw())
            } else if faceUpCards[card2!] == .locomotive {
                continue // Only one locomotive, can't choose it as second card
            } else {
                player.addCardToHand(faceUpCards.remove(at: card2!))
                faceUpCards.append(draw())
                break
            }
        }
    }

    func playTrackForPlayer(_ player: Player) {
        while true {
            var tracks = board.unownedTracks()
            let track = tracks[player.delegate.whichTrackToClaim(tracks)]

            if player.hasEnoughCards(track.length, ofColor: track.color) {
                track.owner = player
                break
            }
        }
    }

    public func run() -> Player {
        for p in players {
            for _ in 0..<3 {
                p.cards[draw().index()] += 1
            }
            newDestinationsForPlayer(p, destinations: 4)
        }

        for _ in 0..<5 {
            faceUpCards.append(draw())
        }

        while true {
            for p in players {
                switch p.delegate.actionThisTurn() {
                case .drawCards:
                    drawCardsForPlayer(p)
                case .playTrack:
                    playTrackForPlayer(p)
                case .newDestinations:
                    newDestinationsForPlayer(p, destinations: 3)
                case .buildStation:
                    break
                }
            }
        }

        // return players[0]
    }
}
