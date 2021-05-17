// Copyright © 2017-2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Squall

public protocol Deck {
    /// Returns Int.max if this is a uniform deck
    var count: Int { get }
    var type: DeckType { get }

    mutating func draw() -> CardColor?
    mutating func draw(_: Int) -> [CardColor?]
    mutating func draw<T>(using: inout T) -> CardColor? where T: RandomNumberGenerator
    mutating func draw<T>(_: Int, using: inout T) -> [CardColor?] where T: RandomNumberGenerator

    mutating func discard(_: CardColor)
    mutating func discard(_: [CardColor])
}

public extension Deck {
    mutating func draw() -> CardColor? {
        var rng = Gust()
        return self.draw(using: &rng)
    }

    mutating func draw(_ count: Int) -> [CardColor?] {
        var rng = Gust()
        return (1 ... count).map { _ in self.draw(using: &rng) }
    }

    mutating func draw<T>(_: Int, using rng: inout T) -> [CardColor?] where T: RandomNumberGenerator {
        (1 ... count).map { _ in self.draw(using: &rng) }
    }

    mutating func discard(_ cards: [CardColor]) {
        cards.forEach { self.discard($0) }
    }
}

public struct UniformDeck: Deck, Codable {
    private var colors: [CardColor]

    public var count: Int { Int.max }
    public var type: DeckType { .uniform(colors: self.colors) }

    public init(colors: [CardColor]) {
        self.colors = colors
    }

    public mutating func draw<T>(using rng: inout T) -> CardColor? where T: RandomNumberGenerator {
        self.colors.randomElement(using: &rng)
    }

    public func discard(_: CardColor) {}
}

public struct FiniteDeck: Deck, Codable {
    private var initialCards: [CardColor]
    private var cards: [CardColor]

    public var count: Int { self.cards.count }
    public var type: DeckType { .finite(cards: self.initialCards) }

    public init(cards: [CardColor]) {
        self.initialCards = cards
        self.cards = self.initialCards
    }

    public mutating func draw<T>(using rng: inout T) -> CardColor? where T: RandomNumberGenerator {
        guard !self.cards.isEmpty else { return nil }
        let index = Int(rng.next(upperBound: UInt(self.cards.count)))
        return self.cards.remove(at: index)
    }

    public mutating func discard(_ card: CardColor) { self.cards.append(card) }
}
