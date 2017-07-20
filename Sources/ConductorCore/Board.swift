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

    // swiftlint:disable function_body_length
    public static func standardEuropeMap() -> Board {
        let paris = City(withName: "Paris") // 10
        let frankfurt = City(withName: "Frankfurt") // 8
        let berlin = City(withName: "Berlin") // 7
        let pamplona = City(withName: "Pamplona") // 7
        let budapest = City(withName: "Budapest") // 6
        let kyiv = City(withName: "Kyiv") // 6
        let warszawa = City(withName: "Warszawa") // 6
        let wien = City(withName: "Wien") // 6
        let bruxelles = City(withName: "Bruxelles") // 5
        let bucuresti = City(withName: "Bucuresti") // 5
        let constantinople = City(withName: "Constantinople") // 5
        let dieppe = City(withName: "Dieppe") // 5
        let essen = City(withName: "Essen") // 5
        let london = City(withName: "London") // 5
        let madrid = City(withName: "Madrid") // 5
        let marseille = City(withName: "Marseille") // 5
        let sevastopol = City(withName: "Sevastopol") // 5
        let wilno = City(withName: "Wilno") // 5
        let amsterdam = City(withName: "Amsterdam") // 4
        let athina = City(withName: "Athina") // 4
        let kobenhavn = City(withName: "Kobenhavn") // 4
        let munchen = City(withName: "Munchen") // 4
        let petrograd = City(withName: "Petrograd") // 4
        let roma = City(withName: "Roma") // 4
        let sarajevo = City(withName: "Sarajevo") // 4
        let smyrna = City(withName: "Smyrna") // 4
        let sofia = City(withName: "Sofia") // 4
        let venezia = City(withName: "Venezia") // 4
        let zagrab = City(withName: "Zagrab") // 4
        let zurich = City(withName: "Zurich") // 4
        let angora = City(withName: "Angora") // 3
        let barcelona = City(withName: "Barcelona") // 3
        let brest = City(withName: "Brest") // 3
        let brindisi = City(withName: "Brindisi") // 3
        let danzic = City(withName: "Danzic") // 3
        let erzurum = City(withName: "Erzurum") // 3
        let kharkov = City(withName: "Kharkov") // 3
        let moskva = City(withName: "Moskva") // 3
        let palermo = City(withName: "Palermo") // 3
        let rica = City(withName: "Rica") // 3
        let rostov = City(withName: "Rostov") // 3
        let smolensk = City(withName: "Smolensk") // 3
        let sochi = City(withName: "Sochi") // 3
        let stockholm = City(withName: "Stockholm") // 3
        let cadiz = City(withName: "Cadiz") // 2
        let edinburgh = City(withName: "Edinburgh") // 2
        let lisboa = City(withName: "Lisboa") // 2

        _ = Track(between: paris, and: frankfurt, length: 3, color: .white)
        _ = Track(between: paris, and: frankfurt, length: 3, color: .orange)
        _ = Track(between: paris, and: pamplona, length: 4, color: .blue)
        _ = Track(between: paris, and: pamplona, length: 4, color: .green)
        _ = Track(between: paris, and: bruxelles, length: 2, color: .yellow)
        _ = Track(between: paris, and: bruxelles, length: 2, color: .red)
        _ = Track(between: paris, and: dieppe, length: 1, color: .pink)
        _ = Track(between: paris, and: marseille, length: 4, color: .unspecified)
        _ = Track(between: paris, and: zurich, length: 3, color: .unspecified, tunnel: true)
        _ = Track(between: paris, and: brest, length: 3, color: .black)

        _ = Track(between: frankfurt, and: berlin, length: 3, color: .black)
        _ = Track(between: frankfurt, and: berlin, length: 3, color: .red)
        _ = Track(between: frankfurt, and: bruxelles, length: 2, color: .blue)
        _ = Track(between: frankfurt, and: essen, length: 2, color: .green)
        _ = Track(between: frankfurt, and: amsterdam, length: 2, color: .white)
        _ = Track(between: frankfurt, and: munchen, length: 2, color: .pink)

        _ = Track(between: berlin, and: warszawa, length: 4, color: .pink)
        _ = Track(between: berlin, and: warszawa, length: 4, color: .yellow)
        _ = Track(between: berlin, and: wien, length: 3, color: .green)
        _ = Track(between: berlin, and: essen, length: 2, color: .blue)
        _ = Track(between: berlin, and: danzic, length: 4, color: .unspecified)

        _ = Track(between: pamplona, and: madrid, length: 3, color: .black, tunnel: true)
        _ = Track(between: pamplona, and: madrid, length: 3, color: .white, tunnel: true)
        _ = Track(between: pamplona, and: marseille, length: 4, color: .red)
        _ = Track(between: pamplona, and: barcelona, length: 2, color: .unspecified, tunnel: true)
        _ = Track(between: pamplona, and: brest, length: 4, color: .pink)

        _ = Track(between: budapest, and: kyiv, length: 6, color: .unspecified, tunnel: true)
        _ = Track(between: budapest, and: wien, length: 1, color: .white)
        _ = Track(between: budapest, and: bucuresti, length: 4, color: .unspecified, tunnel: true)
        _ = Track(between: budapest, and: wien, length: 1, color: .red)
        _ = Track(between: budapest, and: sarajevo, length: 3, color: .pink)
        _ = Track(between: budapest, and: zagrab, length: 2, color: .orange)

        _ = Track(between: kyiv, and: warszawa, length: 4, color: .unspecified)
        _ = Track(between: kyiv, and: bucuresti, length: 4, color: .unspecified)
        _ = Track(between: kyiv, and: wilno, length: 2, color: .unspecified)
        _ = Track(between: kyiv, and: kharkov, length: 4, color: .unspecified)
        _ = Track(between: kyiv, and: smolensk, length: 3, color: .red)

        _ = Track(between: warszawa, and: wien, length: 4, color: .blue)
        _ = Track(between: warszawa, and: wilno, length: 3, color: .red)
        _ = Track(between: warszawa, and: danzic, length: 2, color: .unspecified)

        _ = Track(between: wien, and: munchen, length: 3, color: .orange)
        _ = Track(between: wien, and: zagrab, length: 2, color: .unspecified)

        _ = Track(between: bruxelles, and: dieppe, length: 2, color: .green)
        _ = Track(between: bruxelles, and: amsterdam, length: 1, color: .black)

        _ = Track(between: bucuresti, and: constantinople, length: 3, color: .yellow)
        _ = Track(between: bucuresti, and: sevastopol, length: 4, color: .white)
        _ = Track(between: bucuresti, and: sofia, length: 2, color: .unspecified, tunnel: true)

        _ = Track(between: constantinople, and: sevastopol, length: 4, color: .unspecified, ferries: 2)
        _ = Track(between: constantinople, and: smyrna, length: 2, color: .unspecified, tunnel: true)
        _ = Track(between: constantinople, and: sofia, length: 3, color: .blue)
        _ = Track(between: constantinople, and: angora, length: 2, color: .unspecified, tunnel: true)

        _ = Track(between: dieppe, and: london, length: 2, color: .unspecified, ferries: 1)
        _ = Track(between: dieppe, and: london, length: 2, color: .unspecified, ferries: 1)
        _ = Track(between: dieppe, and: brest, length: 2, color: .orange)

        _ = Track(between: essen, and: amsterdam, length: 3, color: .yellow)
        _ = Track(between: essen, and: kobenhavn, length: 3, color: .unspecified, ferries: 1)
        _ = Track(between: essen, and: kobenhavn, length: 3, color: .unspecified, ferries: 1)

        _ = Track(between: london, and: amsterdam, length: 2, color: .unspecified, ferries: 2)
        _ = Track(between: london, and: edinburgh, length: 4, color: .black)
        _ = Track(between: london, and: edinburgh, length: 4, color: .orange)

        _ = Track(between: madrid, and: barcelona, length: 2, color: .yellow)
        _ = Track(between: madrid, and: cadiz, length: 3, color: .orange)
        _ = Track(between: madrid, and: lisboa, length: 3, color: .pink)

        _ = Track(between: marseille, and: roma, length: 4, color: .unspecified, tunnel: true)
        _ = Track(between: marseille, and: zurich, length: 2, color: .pink, tunnel: true)
        _ = Track(between: marseille, and: barcelona, length: 4, color: .unspecified)

        _ = Track(between: sevastopol, and: erzurum, length: 4, color: .unspecified, ferries: 2)
        _ = Track(between: sevastopol, and: rostov, length: 4, color: .unspecified)
        _ = Track(between: sevastopol, and: sochi, length: 2, color: .unspecified, ferries: 1)

        _ = Track(between: wilno, and: petrograd, length: 4, color: .blue)
        _ = Track(between: wilno, and: rica, length: 4, color: .green)
        _ = Track(between: wilno, and: smolensk, length: 3, color: .yellow)

        _ = Track(between: athina, and: sarajevo, length: 4, color: .green)
        _ = Track(between: athina, and: smyrna, length: 2, color: .unspecified, ferries: 1)
        _ = Track(between: athina, and: sofia, length: 3, color: .pink)
        _ = Track(between: athina, and: brindisi, length: 4, color: .unspecified, ferries: 1)

        _ = Track(between: kobenhavn, and: stockholm, length: 3, color: .yellow)
        _ = Track(between: kobenhavn, and: stockholm, length: 3, color: .white)

        _ = Track(between: munchen, and: venezia, length: 2, color: .blue, tunnel: true)
        _ = Track(between: munchen, and: zurich, length: 2, color: .yellow, tunnel: true)

        _ = Track(between: petrograd, and: moskva, length: 4, color: .white)
        _ = Track(between: petrograd, and: rica, length: 4, color: .unspecified)
        _ = Track(between: petrograd, and: stockholm, length: 8, color: .unspecified, tunnel: true)

        _ = Track(between: roma, and: venezia, length: 2, color: .black)
        _ = Track(between: roma, and: palermo, length: 4, color: .unspecified, ferries: 1)
        _ = Track(between: roma, and: brindisi, length: 2, color: .white)

        _ = Track(between: sarajevo, and: sofia, length: 2, color: .unspecified, tunnel: true)
        _ = Track(between: sarajevo, and: zagrab, length: 3, color: .red)

        _ = Track(between: smyrna, and: angora, length: 3, color: .orange, tunnel: true)
        _ = Track(between: smyrna, and: palermo, length: 6, color: .unspecified, ferries: 2)

        _ = Track(between: venezia, and: zagrab, length: 2, color: .unspecified)
        _ = Track(between: venezia, and: zurich, length: 2, color: .green, tunnel: true)

        _ = Track(between: brindisi, and: palermo, length: 3, color: .unspecified, ferries: 1)

        _ = Track(between: danzic, and: rica, length: 3, color: .black)

        _ = Track(between: erzurum, and: sochi, length: 3, color: .red, tunnel: true)

        _ = Track(between: kharkov, and: moskva, length: 4, color: .unspecified)
        _ = Track(between: kharkov, and: rostov, length: 2, color: .green)

        _ = Track(between: moskva, and: smolensk, length: 2, color: .orange)

        _ = Track(between: rostov, and: sochi, length: 2, color: .unspecified)

        _ = Track(between: cadiz, and: lisboa, length: 2, color: .blue)

        return Board(withCities: paris, frankfurt, berlin, pamplona, budapest,
                     kyiv, warszawa, wien, bruxelles, bucuresti, constantinople,
                     dieppe, essen, london, madrid, marseille, sevastopol, wilno,
                     amsterdam, athina, kobenhavn, munchen, petrograd, roma,
                     sarajevo, smyrna, sofia, venezia, zagrab, zurich, angora,
                     barcelona, brest, brindisi, danzic, erzurum, kharkov, moskva,
                     palermo, rica, rostov, smolensk, sochi, stockholm, cadiz,
                     edinburgh, lisboa)
    }
    // swiftlint:enable function_body_length

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
