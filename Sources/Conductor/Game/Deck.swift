import Foundation
import Squall

public protocol Deck {
    /// Returns Int.max if this is a uniform deck
    var count: Int { get }
    var type: DeckType { get }

    mutating func draw() -> CardColor?
    mutating func draw(_: Int) -> [CardColor?]
    mutating func discard(_: CardColor)
    mutating func discard(_: [CardColor])
}

public extension Deck {
    mutating func draw(_ count: Int) -> [CardColor?] {
        (1 ... count).map { _ in self.draw() }
    }

    mutating func discard(_ cards: [CardColor]) {
        cards.forEach { self.discard($0) }
    }
}

public struct UniformDeck: Deck, Codable {
    public var count: Int { Int.max }
    var colors: [CardColor]
    public var type: DeckType { .uniform(colors: colors) }
    var rng: Gust

    public init(colors: [CardColor], rng: Gust) {
        self.colors = colors
        self.rng = rng
    }

    public init(colors: [CardColor]) {
        self.init(colors: colors, rng: Gust())
    }

    public mutating func draw() -> CardColor? { colors[Int(rng.next(upperBound: UInt(colors.count)))] }

    public func discard(_: CardColor) {}
    public func discard(_: [CardColor]) {}
}

public struct FiniteDeck: Deck, Codable {
    public var count: Int { cards.count }

    var initialCards: [CardColor]
    var cards: [CardColor]
    var rng: Gust
    public var type: DeckType { .finite(cards: initialCards) }

    public init(cards: [CardColor], rng: Gust) {
        initialCards = cards
        self.cards = initialCards
        self.rng = rng
    }

    public init(cards: [CardColor]) {
        self.init(cards: cards, rng: Gust())
    }

    public mutating func draw() -> CardColor? {
        if cards.isEmpty { return nil }
        let index = Int(rng.next(upperBound: UInt(cards.count)))
        return cards.remove(at: index)
    }

    public mutating func discard(_ card: CardColor) { cards.append(card) }
}
