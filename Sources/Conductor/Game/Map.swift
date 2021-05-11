import Foundation
import SwiftGraph

struct RouteJSON: Codable {
    var endpoints: [String]
    var color: String
    var length: Int
    var tunnel: Bool
    var ferries: Int
}

struct City: Codable, Equatable {
    var name: String

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name
    }
}

class Map {
    var graph: SwiftGraph.WeightedGraph<City, Int>

    init(fromJSONStream stream: InputStream) throws {
        let decodedJson = try JSONDecoder().decode([RouteJSON].self, from: try Data(reading: stream))

        graph = WeightedGraph(vertices: [])
        decodedJson.forEach { route in
            // Add cities if they do not already exist
            route.endpoints
                .filter { name in !self.graph.vertices.contains { $0.name == name } }
                .forEach { name in _ = self.graph.addVertex(City(name: name)) }

            self.graph.addEdge(from: City(name: route.endpoints[0]), to: City(name: route.endpoints[1]), weight: route.length)
        }

        print(graph)
    }
}
