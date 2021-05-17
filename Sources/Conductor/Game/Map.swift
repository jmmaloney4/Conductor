// Copyright © 2017-2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftGraph

struct RouteJSON: Codable {
    var endpoints: [String]
    var length: Int
    var color: String
    var tunnel: Bool
    var ferries: Int
}

struct Edge: Codable {
    var length: Int

    struct TrackData: Codable {
        var color: TrackColor
        var tunnel: Bool
        var ferries: Int
    }

    var data: TrackData?

    init(from route: RouteJSON) {
        length = route.length
        data = TrackData(color: .color(name: route.color), tunnel: route.tunnel, ferries: route.ferries)
    }
}

extension Edge: Comparable {
    static func == (lhs: Edge, rhs: Edge) -> Bool {
        lhs.length == rhs.length
    }

    static func < (lhs: Edge, rhs: Edge) -> Bool {
        lhs.length < rhs.length
    }
}

extension Edge: Numeric {
    typealias Magnitude = Int
    typealias IntegerLiteralType = Int

    var magnitude: Int { length }

    init(integerLiteral value: Int) { length = value }

    init() { self.init(integerLiteral: 0) }

    init?<T>(exactly source: T) where T: BinaryInteger {
        self.init(integerLiteral: Int(source))
    }

    static func * (lhs: Edge, rhs: Edge) -> Edge {
        Edge(integerLiteral: lhs.length * rhs.length)
    }

    static func *= (lhs: inout Edge, rhs: Edge) {
        lhs.length *= rhs.length
    }

    static func + (lhs: Edge, rhs: Edge) -> Edge {
        Edge(integerLiteral: lhs.length + rhs.length)
    }

    static func - (lhs: Edge, rhs: Edge) -> Edge {
        Edge(integerLiteral: lhs.length - rhs.length)
    }
}

class Map {
    var graph: SwiftGraph.WeightedGraph<String, Edge>

    var lookupTable: [City: ([City: Edge?], [City: [WeightedEdge<Edge>]])] = [:]

    init(fromJSONStream stream: InputStream) throws {
        let decodedJson = try JSONDecoder().decode([RouteJSON].self, from: try Data(reading: stream))

        graph = WeightedGraph(vertices: [])
        decodedJson.forEach { route in
            // Add cities if they do not already exist
            route.endpoints
                .filter { name in !self.graph.vertices.contains(name) }
                .forEach { name in _ = self.graph.addVertex(name) }

            self.graph.addEdge(from: route.endpoints[0], to: route.endpoints[1], weight: Edge(from: route))
        }

        graph.vertices.forEach { city in
            let (distancesDict, pathDict) = self.graph.dijkstra(root: city, startDistance: Edge())
            let paths = [String: [WeightedEdge<Edge>]](uniqueKeysWithValues: self.graph.vertices.filter { $0 != city }
                .map { to in
                    let path = pathDictToPath(from: self.graph.indexOfVertex(city)!, to: self.graph.indexOfVertex(to)!, pathDict: pathDict)
                    return (to, path)
                })
            let distances = distanceArrayToVertexDict(distances: distancesDict, graph: self.graph)
            self.lookupTable[city] = (distances, paths)
        }
    }

    func randomDestination<T>(using rng: inout T) -> Destination where T: RandomNumberGenerator {
        let shuffled = graph.vertices.shuffled(using: &rng)
        return Destination(a: shuffled[0], b: shuffled[1])
    }

    func distance(from a: City, to b: City) -> Edge {
        lookupTable[a]!.0[b]!!
    }

    func distance(_ pair: CityPair) -> Edge {
        distance(from: pair.a, to: pair.b)
    }

    func path(from a: City, to b: City) -> [Edge] {
        lookupTable[a]!.1[b]!.map(\.weight)
    }

    func path(_ pair: CityPair) -> [Edge] {
        path(from: pair.a, to: pair.b)
    }
}
