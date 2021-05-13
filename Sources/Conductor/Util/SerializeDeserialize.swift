import Foundation

public func SerializeDeserialize<T: Codable>(_ t: T) throws -> T {
    try JSONDecoder().decode(T.self, from: JSONEncoder().encode(t))
}
