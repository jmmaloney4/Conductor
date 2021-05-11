import Foundation
import SwiftGraph

struct RouteJSON: Codable {
    var endpoints: [String]
    var length: Int
    var color: String
    var tunnel: Bool
    var ferries: Int
}

struct Track: Codable {
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

extension Track: Comparable {
    static func == (lhs: Track, rhs: Track) -> Bool {
        lhs.length == rhs.length
    }

    static func < (lhs: Track, rhs: Track) -> Bool {
        lhs.length < rhs.length
    }
}

extension Track: Numeric {
    typealias Magnitude = Int
    typealias IntegerLiteralType = Int

    var magnitude: Int { length }

    init(integerLiteral value: Int) { length = value }

    init() { self.init(integerLiteral: 0) }

    init?<T>(exactly source: T) where T: BinaryInteger {
        self.init(integerLiteral: Int(source))
    }

    static func * (lhs: Track, rhs: Track) -> Track {
        Track(integerLiteral: lhs.length * rhs.length)
    }

    static func *= (lhs: inout Track, rhs: Track) {
        lhs.length *= rhs.length
    }

    static func + (lhs: Track, rhs: Track) -> Track {
        Track(integerLiteral: lhs.length + rhs.length)
    }

    static func - (lhs: Track, rhs: Track) -> Track {
        Track(integerLiteral: lhs.length - rhs.length)
    }
}

class Map {
    var graph: SwiftGraph.WeightedGraph<String, Track>

    init(fromJSONStream stream: InputStream) throws {
        let decodedJson = try JSONDecoder().decode([RouteJSON].self, from: try Data(reading: stream))

        graph = WeightedGraph(vertices: [])
        decodedJson.forEach { route in
            // Add cities if they do not already exist
            route.endpoints
                .filter { name in !self.graph.vertices.contains(name) }
                .forEach { name in _ = self.graph.addVertex(name) }

            self.graph.addEdge(from: route.endpoints[0], to: route.endpoints[1], weight: Track(from: route))
        }
    }
}
