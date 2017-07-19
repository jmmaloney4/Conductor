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
    
    public static func standardEuropeMap() -> Board {
        let paris = City(withName: "Paris") // 10
        let frankfurt = City(withName: "Frankfurt") // 8
        let berlin = City(withName: "Berlin")
        let pamplona = City(withName: "Pamplona") // 7
        let bruxelles = City(withName: "Bruxelles") // 5
        let dieppe = City(withName: "Dieppe") // 5
        let essen = City(withName: "Essen") // 5
        let london = City(withName: "London") // 5
        let amsterdam = City(withName: "Amsterdam") // 4
        let brest = City(withName: "Brest") // 3
        let edinburgh = City(withName: "Edinburgh") // 2
        
        _ = Track(between: paris, and: frankfurt, length: 3, color: .white)
        _ = Track(between: paris, and: frankfurt, length: 3, color: .orange)
        _ = Track(between: paris, and: pamplona, length: 4, color: .blue)
        _ = Track(between: paris, and: pamplona, length: 4, color: .green)
        _ = Track(between: paris, and: bruxelles, length: 2, color: .yellow)
        _ = Track(between: paris, and: bruxelles, length: 2, color: .red)
        _ = Track(between: paris, and: dieppe, length: 1, color: .pink)
        _ = Track(between: paris, and: brest, length: 3, color: .black)
        
        _ = Track(between: frankfurt, and: berlin, length: 3, color: .black)
        _ = Track(between: frankfurt, and: berlin, length: 3, color: .red)
        _ = Track(between: frankfurt, and: bruxelles, length: 2, color: .blue)
        _ = Track(between: frankfurt, and: essen, length: 2, color: .green)
        _ = Track(between: frankfurt, and: amsterdam, length: 2, color: .white)
        
        _ = Track(between: berlin, and: essen, length: 2, color: .blue)
        
        _ = Track(between: pamplona, and: brest, length: 4, color: .pink)
        
        _ = Track(between: bruxelles, and: dieppe, length: 2, color: .green)
        _ = Track(between: bruxelles, and: amsterdam, length: 1, color: .black)
        
        _ = Track(between: dieppe, and: london, length: 2, color: .unspecified, ferries: 1)
        _ = Track(between: dieppe, and: london, length: 2, color: .unspecified, ferries: 1)
        _ = Track(between: dieppe, and: brest, length: 2, color: .orange)
        
        _ = Track(between: essen, and: amsterdam, length: 3, color: .yellow)
        
        _ = Track(between: london, and: amsterdam, length: 2, color: .unspecified, ferries: 2)
        _ = Track(between: london, and: edinburgh, length: 4, color: .black)
        _ = Track(between: london, and: edinburgh, length: 4, color: .orange)
        
        return Board(withCities: paris, frankfurt, berlin, pamplona, bruxelles, dieppe, essen, london, amsterdam, brest, edinburgh)
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
            
            if path.count >= 3 && distance >= 5 {
                return Destination(from: cityA, to: cityB, length: distance)
            }
            
        }
    }
}
