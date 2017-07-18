// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Squall
import SwiftPriorityQueue

internal class Track {
    internal enum Color {
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
    }
    
    var endpoints: [City]
    var length: Int
    var color: Color
    var tunnel: Bool
    var ferries: Int
    
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

public class City {
    var name: String
    var tracks: [Track] = []
    
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

internal class Destination {
    var endpoints: [City]
    var length: Int
    
    init(from cityA: City, to cityB: City, length: Int) {
        endpoints = [cityA, cityB]
        self.length = length
    }
}

public class Board {
    var cities: [City]
    
    public init(withCities cities: City...) {
        self.cities = cities
    }
    
    public static func standardEuropeMap() -> Board {
        let paris = City(withName: "Paris") // 10
        let frankfurt = City(withName: "Frankfurt") // 8
        let bruxelles = City(withName: "Bruxelles") // 5
        let dieppe = City(withName: "Dieppe") // 5
        let essen = City(withName: "Essen") // 5
        let london = City(withName: "London") // 5
        let amsterdam = City(withName: "Amsterdam") // 4
        let brest = City(withName: "Brest") // 3
        let edinburgh = City(withName: "Edinburgh") // 2
        
        _ = Track(between: paris, and: frankfurt, length: 3, color: .white)
        _ = Track(between: paris, and: frankfurt, length: 3, color: .orange)
        _ = Track(between: paris, and: bruxelles, length: 2, color: .yellow)
        _ = Track(between: paris, and: bruxelles, length: 2, color: .red)
        _ = Track(between: paris, and: dieppe, length: 1, color: .pink)
        _ = Track(between: paris, and: brest, length: 3, color: .black)

        _ = Track(between: frankfurt, and: bruxelles, length: 2, color: .blue)
        _ = Track(between: frankfurt, and: essen, length: 2, color: .green)
        _ = Track(between: frankfurt, and: amsterdam, length: 2, color: .white)
        
        _ = Track(between: bruxelles, and: dieppe, length: 2, color: .green)
        _ = Track(between: bruxelles, and: amsterdam, length: 1, color: .black)
        
        _ = Track(between: dieppe, and: london, length: 2, color: .unspecified, ferries: 1)
        _ = Track(between: dieppe, and: london, length: 2, color: .unspecified, ferries: 1)
        _ = Track(between: dieppe, and: brest, length: 2, color: .orange)
        
        _ = Track(between: essen, and: amsterdam, length: 3, color: .yellow)

        _ = Track(between: london, and: amsterdam, length: 2, color: .unspecified, ferries: 2)
        _ = Track(between: london, and: edinburgh, length: 4, color: .black)
        _ = Track(between: london, and: edinburgh, length: 4, color: .orange)
        
        return Board(withCities: paris, frankfurt, bruxelles, dieppe, essen, london, amsterdam, brest, edinburgh)
    }
    
    func cityForName(_ name: String) -> City? {
        for city in cities {
            if city.name == name {
                return city
            }
        }
        return nil
    }
    
    private class DijkstraNode: Comparable {
        static func ==(lhs: Board.DijkstraNode, rhs: Board.DijkstraNode) -> Bool {
            return lhs.city === rhs.city
        }

        static func <(lhs: Board.DijkstraNode, rhs: Board.DijkstraNode) -> Bool {
            return lhs.distance < rhs.distance
        }

        var city: City
        var previous: DijkstraNode? // Previous city
        var distance: Int // From origin
        
        init(city: City, previous: DijkstraNode? = nil, distance: Int = Int.max) {
            self.city = city
            self.previous = previous
            self.distance = distance
        }
    }
    
    func findShortestRoute(between cityA: City, and cityB: City) -> ([City], Int) {
        
        var queue: PriorityQueue<DijkstraNode> = PriorityQueue<DijkstraNode>(ascending: true)
        
        queue.push(DijkstraNode(city: cityA, previous: nil, distance: 0))
        for city in cities {
            if city !== cityA {
                queue.push(DijkstraNode(city: city))
            }
        }
        
        var finalNode: DijkstraNode? = nil
        
        while true {
            let current = queue.pop()!
            
            var newQueue = PriorityQueue<DijkstraNode>(ascending: true)
            
            while let node = queue.pop() {
                if node.city.isAdjacentToCity(current.city) {
                    let distance = node.city.shortestTrackToCity(current.city)
                    if node.distance > (current.distance + distance) {
                        node.distance = current.distance + distance
                        node.previous = current
                    }
                }
                newQueue.push(node)
            }
            
            queue = newQueue
            if current.city === cityB {
                finalNode = current
                break;
            }
        }
        
        var rv: [City] = []
        var node = finalNode
        while true {
            rv.append(node!.city)
            node = node!.previous
            if node == nil {
                break
            }
        }
        
        return (rv.reversed(), finalNode!.distance)
    }
    
    internal func generateDestination() -> Destination {
        while true {
            var rand: UInt64 = Game.rng.random()
            let cityA = cities[Int(rand % UInt64(cities.count))]
            rand = Game.rng.random()
            let cityB = cities[Int(rand % UInt64(cities.count))]
            
            if cityA.isAdjacentToCity(cityB) {
                continue
            }
            
            let (path, distance) = findShortestRoute(between: cityA, and: cityB)
            
            print(distance)
            print(path)
            
        }
    }
}

public protocol PlayerDelegate {
    
}

public class CLIDelegate: PlayerDelegate {
    public init() {
        
    }
}

public class Player {
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
    
    public init(withDelegate delegate: PlayerDelegate, andColor color: Color) {
        self.delegate = delegate
        self.color = color
    }
}

public class Game {
    var players: [Player]
    var board: Board
    static let rng: Gust = Gust(seed: UInt32(Date().timeIntervalSinceReferenceDate))
    
    public init(withPlayers players: Player..., andBoard board: Board = Board.standardEuropeMap()) {
        self.players = players
        self.board = board
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
            
            Double(14)/Double(110),
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
    
    public func run() -> Player {
        
        for p in players {
            for _ in 0..<3 {
                p.cards[draw().index()] += 1
            }
        }
        
        var b = Board.standardEuropeMap()
        //b.findShortestRoute(between: b.cityForName("Edinburgh")!, and: b.cityForName("Bruxelles")!)
        b.generateDestination()
        
        return players[0]
    }
}
