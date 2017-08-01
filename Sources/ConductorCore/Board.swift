// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftyJSON
import SwiftPriorityQueue

public class Board: CustomStringConvertible {
    weak var game: Game!
    public var cities: [City]

    public var description: String {
        let sorted = cities.sorted(by: { $0.tracks.count > $1.tracks.count })
        print(sorted)

        return sorted.map({ $0.description + ": \($0.tracks)" }).joined(separator: "\n")
    }

    public init(fromJSONFile path: String) throws {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            throw ConductorError.fileError(path: path)
        }

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

    public func getCityForName(_ name: String) -> City? {
        for city in cities where city.name == name {
            return city
        }
        return nil
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

    func findShortestRoute(between cityA: City, and cityB: City) -> ([City], Int) {

        var queue: PriorityQueue<DijkstraNode> = PriorityQueue<DijkstraNode>(ascending: true)

        queue.push(DijkstraNode(city: cityA, previous: nil, distance: 0))
        for city in cities where city != cityA {
            queue.push(DijkstraNode(city: city))
        }

        var finalNode: DijkstraNode? = nil

        while true {
            let current = queue.pop()!

            var newQueue = PriorityQueue<DijkstraNode>(ascending: true)

            while let node = queue.pop() {
                if node.city.isAdjacentToCity(current.city) {
                    let distance = node.city.shortestTrackToAdjacentCity(current.city)
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

        return (rv.reversed(), finalNode!.distance)
    }

    public func generateDestination() -> Destination {
        while true {
            var rand: UInt64 = game.rng.random()
            let cityA = cities[Int(rand % UInt64(cities.count))]
            rand = game.rng.random()
            let cityB = cities[Int(rand % UInt64(cities.count))]

            if cityA.isAdjacentToCity(cityB) {
                continue
            }

            let (path, distance) = findShortestRoute(between: cityA, and: cityB)

            if path.count >= 3 && distance >= 5 {
                return Destination(from: cityA, to: cityB, length: distance)
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

    init(from cityA: City, to cityB: City, length: Int) {
        cities = [cityA, cityB]
        self.length = length
    }
}