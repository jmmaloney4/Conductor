// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftyJSON
import SwiftPriorityQueue
import Weak

public class Board: CustomStringConvertible {
    weak var game: Game!
    public var cities: [City]

    public var description: String {
        let sorted = cities.sorted(by: { $0.tracks.count > $1.tracks.count })
        return sorted.map({ $0.description + ": \($0.tracks)" }).joined(separator: "\n")
    }

    public convenience init(fromJSONFile path: String) throws {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            throw ConductorError.fileError(path: path)
        }
        try self.init(fromData: data)
    }
    public init(fromData data: Data) throws {
        let json = JSON(data: data)

        self.cities = []

        for (_, subJson):(String, JSON) in json {

            guard
                let cityAName = subJson["endpoints"][0].string,
                let cityBName = subJson["endpoints"][1].string else {
                throw ConductorError.invalidJSON
            }

            var cityA: City
            let cityAlist = cities.filter({ $0.name == cityAName })
            if cityAlist.isEmpty {
                cityA = City(withName: cityAName, board: self)
                cities.append(cityA)
            } else if cityAlist.count == 1 {
                cityA = cityAlist[0]
            } else {
                fatalError("Shouldn't be more than one city with same name")
            }

            var cityB: City
            let cityBlist = cities.filter({ $0.name == cityBName })
            if cityBlist.isEmpty {
                cityB = City(withName: cityBName, board: self)
                cities.append(cityB)
            } else if cityBlist.count == 1 {
                cityB = cityBlist[0]
            } else {
                fatalError("Shouldn't be more than one city with same name")
            }

            guard
                let colorName = subJson["color"].string,
                let color = Color.colorForName(colorName),
                let length = subJson["length"].int,
                let tunnel = subJson["tunnel"].bool,
                let ferries = subJson["ferries"].int
                else {
                    throw ConductorError.invalidJSON
            }

            let track = Track(between: cityA, and: cityB, length: length,
                              color: color, tunnel: tunnel, ferries: ferries)
            cityA.addTrack(track)
            cityB.addTrack(track)
        }
    }

    public var json: JSON {
        var array: [[String:Any?]] = []
        for track in getAllTracks() {
            array.append(["endpoints": track.endpoints.map({ "\($0)" }),
                          "color": "\(track.color)",
                          "length": track.length,
                          "tunnel": track.tunnel,
                          "ferries": track.ferries])
        }
        return JSON(array)
    }

    func getAllTracks() -> [Track] {
        var rv: [Track] = []
        for city in cities {
            for track in city.tracks {
                if !rv.contains(track) {
                    rv.append(track)
                }
            }
        }
        return rv
    }

    public func cityForName(_ name: String) -> City? {
        for city in cities where city.name == name {
            return city
        }
        return nil
    }

    public func tracksBetween(_ cityA: City, and cityB: City) -> [Track] {
        var rv: [Track] = []
        for track in getAllTracks() where track.endpoints.contains(Weak(cityA)) && track.endpoints.contains(Weak(cityB)) {
            rv.append(track)
        }
        return rv
    }

    private class DijkstraNode: Comparable {
        static func == (lhs: Board.DijkstraNode, rhs: Board.DijkstraNode) -> Bool {
            return lhs.city === rhs.city
        }

        static func < (lhs: Board.DijkstraNode, rhs: Board.DijkstraNode) -> Bool {
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

    enum DijkstraSearchType {
        case all
        case unowned
        case avaliable(Player)
        case owned(Player?) // if nil then just any player owning it
    }

    public func findShortestRoute(between cityA: City, and cityB: City) -> ([City], Int)? {
        return findShortestRoute(between: cityA, and: cityB, search: .all)
    }

    public func findShortestUnownedRoute(between cityA: City, and cityB: City) -> ([City], Int)? {
        return findShortestRoute(between: cityA, and: cityB, search: .unowned)
    }

    public func findShortesAvaliableRoute(between cityA: City, and cityB: City, to player: Player) -> ([City], Int)? {
        return findShortestRoute(between: cityA, and: cityB, search: .avaliable(player))
    }

    public func findShortestRoute(between cityA: City, and cityB: City, ownedBy player: Player?) -> ([City], Int)? {
        return findShortestRoute(between: cityA, and: cityB, search: .owned(player))
    }

    func findShortestRoute(between cityA: City, and cityB: City, search: DijkstraSearchType) -> ([City], Int)? {

        var queue: PriorityQueue<DijkstraNode> = PriorityQueue<DijkstraNode>(ascending: true)

        queue.push(DijkstraNode(city: cityA, previous: nil, distance: 0))
        for city in cities where city != cityA {
            queue.push(DijkstraNode(city: city))
        }

        var finalNode: DijkstraNode? = nil

        while true {
            let current = queue.pop()!
            if current.distance == Int.max {
                return nil
            }

            var newQueue = PriorityQueue<DijkstraNode>(ascending: true)

            while let node = queue.pop() {
                if node.city.isAdjacentToCity(current.city) {
                    let tracks = node.city.tracksToAdjacentCity(current.city)!
                    for track in tracks {
                        switch search {
                        case .all:
                            break;
                        case .unowned:
                            if game.trackIndex[track] == nil {
                                break
                            } else {
                                continue
                            }
                        case .avaliable(let player):
                            if game.trackIndex[track] == player || game.trackIndex[track] == nil {
                                break
                            } else {
                                continue
                            }
                        case .owned(let owner):
                            if owner == nil && game.trackIndex[track] != nil {
                                break
                            } else if owner != nil && game.trackIndex[track] == owner {
                                break
                            } else {
                                continue
                            }
                        }
                        if node.distance > (current.distance + track.length) {
                            node.distance = current.distance + track.length
                            node.previous = current
                        }
                    }
                }
                newQueue.push(node)
            }

            queue = newQueue
            if current.city === cityB {
                finalNode = current
                break
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

        if rv.count < 2 {
            fatalError("What")
        }

        return (rv.reversed(), finalNode!.distance)
    }

    public func longestPathOwnedBy(player: Player) -> ([City], Int)? {
        var rv: ([City], Int) = ([], 0)

        for city in cities {

        }
        return nil
    }

    func depthFirstSearch(player: Player, city: City, prev: City?) -> ([City], Int)? {
        var tracks = city.tracks
        tracks.sort { (a, b) -> Bool in
            return a.length < b.length
        }
        for track in tracks where prev == nil || !track.connectsToCity(prev!) {
            
        }
        return nil
    }

    public func generateDestination(lengthMin: Int? = 5, lengthMax: Int? = nil, trackMin: Int? = 3, trackMax: Int? = nil) -> Destination {
        var count = 0
        while true {
            var rand: UInt64 = game.rng.random()
            let cityA = cities[Int(rand % UInt64(cities.count))]
            rand = game.rng.random()
            let cityB = cities[Int(rand % UInt64(cities.count))]

            if cityA.isAdjacentToCity(cityB) {
                continue
            }

            let (path, distance) = findShortestRoute(between: cityA, and: cityB)!

            if  (lengthMin != nil && distance >= lengthMin!) || lengthMin == nil &&
                (lengthMax != nil && distance <= lengthMax!) || lengthMax == nil &&
                (trackMin != nil && path.count >= trackMin!) || trackMin == nil &&
                (trackMax != nil && path.count <= trackMax!) || trackMax == nil {
                return Destination(from: cityA, to: cityB, length: distance)
            }

            count += 1
            if count >= 1000 {
                fatalError("Couldn't generate destination")
            }
        }
    }
}

public struct Destination: CustomStringConvertible {
    var cities: [City]
    var length: Int

    public var description: String {
        return "\(cities[0]) to \(cities[1]) (\(length))"
    }

    public init(from cityA: City, to cityB: City, length: Int) {
        cities = [cityA, cityB]
        self.length = length
    }
}
