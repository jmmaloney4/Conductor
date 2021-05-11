import Foundation
import SwiftGraph

struct RouteJSON: Codable {
    var endpoints: [String]
    var color: String
    var length: Int
    var tunnel: Bool
    var ferries: Int
}

class Map {
    var graph: SwiftGraph.WeightedGraph<String, Int>

    init(fromJSONStream stream: InputStream) throws {
        let decodedJson = try JSONDecoder().decode([RouteJSON].self, from: try Data(reading: stream))

        graph = WeightedGraph(vertices: [])
        decodedJson.forEach { route in
            // Add cities if they do not already exist
            route.endpoints
                .filter { name in !self.graph.vertices.contains(name) }
                .forEach { name in _ = self.graph.addVertex(name) }

            self.graph.addEdge(from: route.endpoints[0], to: route.endpoints[1], weight: route.length)
        }
    }
}
