import Foundation
import Squall

public enum DeckType {
    /// All colors are uniformly distributed
    case uniform(colors: [CardColor])

    /// Finite Number of Cards, each is kept track of and discarded apropriatly.
    /// `ofEach` cards of each color. `locomotives` number of locomotives.
    case finite(cards: [CardColor])
}

public protocol Deck {
    /// Returns Int.max if this is a uniform deck
    var count: Int { get }
    var type: DeckType { get }

    func draw() -> CardColor
    func draw(_: Int) -> [CardColor]
    func discard(_: CardColor)
    func discard(_: [CardColor])
}

public extension Deck {
    func draw(_ count: Int) -> [CardColor] {
        (1 ... count).map { _ in self.draw() }
    }

    func discard(_ cards: [CardColor]) {
        cards.forEach { self.discard($0) }
    }
}

public class UniformDeck: Deck {
    public var count: Int { Int.max }
    var colors: [CardColor]
    public var type: DeckType { .uniform(colors: colors) }
    var rng: Gust

    public init(colors: [CardColor], rng: Gust) {
        self.colors = colors
        self.rng = rng
    }

    public convenience init(colors: [CardColor]) {
        self.init(colors: colors, rng: Gust())
    }

    public func draw() -> CardColor {
        colors[Int(rng.next(upperBound: UInt(colors.count)))]
    }

    public func discard(_: CardColor) {}

    public func discard(_: [CardColor]) {}
}

public class FiniteDeck: Deck {
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

    public convenience init(cards: [CardColor]) {
        self.init(cards: cards, rng: Gust())
    }

    public func draw() -> CardColor {
        let index = Int(rng.next(upperBound: UInt(cards.count)))
        return cards.remove(at: index)
    }

    public func discard(_ card: CardColor) {
        cards.append(card)
    }
}
