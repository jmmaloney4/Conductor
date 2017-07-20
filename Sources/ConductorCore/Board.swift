// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftPriorityQueue

public class Board {
    var cities: [City]

    public init(withCities cities: City...) {
        self.cities = cities
    }

    func cityForName(_ name: String) -> City? {
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
        for city in cities where city !== cityA {
            queue.push(DijkstraNode(city: city))
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

            if path.count >= 3 && distance >= 5 {
                return Destination(from: cityA, to: cityB, length: distance)
            }

        }
    }

    func allTracks() -> [Track] {
        var rv: [Track] = []
        for city in cities {
            for track in city.tracks {
                if !rv.contains(where: { $0 === track }) {
                    rv.append(track)
                }
            }
        }
        return rv
    }

    func unownedTracks() -> [Track] {
        return allTracks().filter({ $0.owner == nil })
    }

    func tracksOwnedBy(_ player: Player) -> [Track] {
        return allTracks().filter({ $0.owner != nil && $0.owner! === player })
    }
}
