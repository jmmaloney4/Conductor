import Foundation
import Squall

enum DeckType {
    /// All colors are uniformly distributed
    case uniform(colors: [CardColor])

    /// Finite Number of Cards, each is kept track of and discarded apropriatly.
    /// `ofEach` cards of each color. `locomotives` number of locomotives.
    case finite(cards: [CardColor])
}

protocol Deck {
    /// Returns Int.max if this is a uniform deck
    var count: Int { get }
    var type: DeckType { get }

    func draw() -> CardColor
    func draw(_: Int) -> [CardColor]
    func discard(_: CardColor)
    func discard(_: [CardColor])
}

class UniformDeck: Deck {
    var count: Int { Int.max }
    var colors: [CardColor]
    var type: DeckType { .uniform(colors: colors) }
    var rng: Gust

    init(colors: [CardColor], rng: Gust) {
        self.colors = colors
        self.rng = rng
    }

    convenience init(colors: [CardColor]) {
        self.init(colors: colors, rng: Gust())
    }

    func draw() -> CardColor {
        let rand: Double = rng.uniform(lower: 0.0, Double(colors.count))
        return colors[Int(floor(rand))]
    }

    func draw(_ count: Int) -> [CardColor] {
        (1 ... count).map { _ in self.draw() }
    }

    func discard(_: CardColor) {}

    func discard(_: [CardColor]) {}
}
