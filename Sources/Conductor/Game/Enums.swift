import Foundation

public enum CardColor: Hashable, CustomStringConvertible {
    case color(name: String)
    case locomotive

    public var description: String {
        switch self {
        case let .color(name): return name
        case .locomotive: return "Locomotive"
        }
    }
}

extension CardColor: Codable {
    enum CodingKeys: CodingKey {
        case color
        case locomotive
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let name = try? container.decode(String.self, forKey: .color) {
            self = .color(name: name)
        } else if let _ = try? container.decodeNil(forKey: .locomotive) {
            self = .locomotive
        } else {
            throw ConductorCodingError.unknownValue
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .color(name):
            try container.encode(name, forKey: .color)
        case .locomotive:
            try container.encodeNil(forKey: .locomotive)
        }
    }
}

public enum TrackColor: Equatable, CustomStringConvertible {
    case color(name: String)
    case unspecified

    public var description: String {
        switch self {
        case let .color(name): return name
        case .unspecified: return "Unspecified"
        }
    }
}

extension TrackColor: Codable {
    enum CodingKeys: CodingKey {
        case color
        case unspecified
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let name = try? container.decode(String.self, forKey: .color) {
            self = .color(name: name)
        } else if let _ = try? container.decodeNil(forKey: .unspecified) {
            self = .unspecified
        } else {
            throw ConductorCodingError.unknownValue
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

public enum DeckType {
    /// All colors are uniformly distributed
    case uniform(colors: [CardColor])

    /// Finite Number of Cards, each is kept track of and discarded apropriatly.
    /// `ofEach` cards of each color. `locomotives` number of locomotives.
    case finite(cards: [CardColor])
}

extension DeckType: Codable {
    enum CodingKeys: CodingKey {
        case uniform
        case finite
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let colors = try container.decodeIfPresent([CardColor].self, forKey: .uniform) {
            self = .uniform(colors: colors)
        } else if let cards = try container.decodeIfPresent([CardColor].self, forKey: .finite) {
            self = .finite(cards: cards)
        } else {
            throw ConductorCodingError.unknownValue
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .uniform(colors): try container.encode(colors, forKey: .uniform)
        case let .finite(cards): try container.encode(cards, forKey: .finite)
        }
    }
}
