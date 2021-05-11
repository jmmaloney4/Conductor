import Foundation

struct RouteJSON: Codable {
    var endpoints: [String]
    var color: String
    var length: Int
    var tunnel: Bool
    var ferries: Int
}

func LoadMapJSON(stream: InputStream) throws {
    let decodedJson = try JSONDecoder().decode([RouteJSON].self, from: try Data(reading: stream))
    print(decodedJson)
}
