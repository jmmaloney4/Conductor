import Foundation

public enum CardColor: Hashable {
    case color(name: String)
    case locomotive
}

public enum TrackColor: Equatable {
    case color(name: String)
    case unspecified
}

extension TrackColor: Codable {
    enum CodingKeys: CodingKey {
        case color
        case unspecified
    }

    enum CodingError: Error {
        case unknownValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let name = try? container.decode(String.self, forKey: .color) {
            self = .color(name: name)
        } else if let _ = try? container.decodeNil(forKey: .unspecified) {
            self = .unspecified
        } else {
            throw CodingError.unknownValue
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .color(name):
            try container.encode(name, forKey: .color)
        case .unspecified:
            try container.encodeNil(forKey: .unspecified)
        }
    }
}
