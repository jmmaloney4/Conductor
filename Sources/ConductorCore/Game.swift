// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Squall
import SwiftyJSON

public class Game: Hashable {
    var rules: JSON
    public var players: [Player]
    var started: Bool = false
    var board: Board
    var rng: Gust
    var seed: UInt32
    public var trackIndex: [Track: Player] = [:]
    // public var stations: [City:Player] = [:]
    var cards: [Color] = []
    var turn: Int = 0
    var deck: [Color]?
    var probabilities: [Double]?
    var time: Double?
    
    public var hashValue: Int { return ObjectIdentifier(self).hashValue }
    public static func == (lhs: Game, rhs: Game) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    private convenience init(withRules rules: JSON, board: Board) {
        self.init(withRules: rules, board: board, andPlayers: [])
    }
    
    public convenience init(withRules rules: JSON, board: Board, andPlayerTypes players: PlayerKind...) {
        self.init(withRules: rules, board: board, andPlayerTypes: players)
    }
    
    public convenience init(withRules rules: JSON, board: Board, andPlayerTypes players: [PlayerKind]) {
        var interfaces: [PlayerInterface] = []
        for i in players {
            switch i {
            case .bigTrackAI:
                interfaces.append(BigTrackAI())
            case .destinationAI:
                interfaces.append(DestinationAI())
            case .cli:
                interfaces.append(CLI())
            case .randomAI:
                interfaces.append(RandomAI())
            }
        }
        self.init(withRules: rules, board: board, andPlayers: interfaces)
    }
    
    public convenience init(withRules rules: JSON, board: Board, andPlayers players: PlayerInterface...) {
        self.init(withRules: rules, board: board, andPlayers: players)
    }
    
    public init(withRules rules: JSON, board: Board, andPlayers players: [PlayerInterface]) {
        log.debug("Initialize game: \(players)")
        self.seed = UInt32(Date().timeIntervalSinceReferenceDate) + (globalRng.random() / 100000)
        self.rng = Gust(seed: seed)
        self.rules = rules
        self.board = board
        
        let realDeck = rules[Rules.kUseRealDeck].bool!
        let deckConfig = rules[Rules.kDeck]
        
        self.deck = []
        deck!.append(contentsOf: Array(repeating: .red, count: deckConfig[Color.red.key].int!))
        deck!.append(contentsOf: Array(repeating: .blue, count: deckConfig[Color.red.key].int!))
        deck!.append(contentsOf: Array(repeating: .black, count: deckConfig[Color.red.key].int!))
        deck!.append(contentsOf: Array(repeating: .white, count: deckConfig[Color.red.key].int!))
        deck!.append(contentsOf: Array(repeating: .orange, count: deckConfig[Color.red.key].int!))
        deck!.append(contentsOf: Array(repeating: .yellow, count: deckConfig[Color.red.key].int!))
        deck!.append(contentsOf: Array(repeating: .pink, count: deckConfig[Color.red.key].int!))
        deck!.append(contentsOf: Array(repeating: .green, count: deckConfig[Color.red.key].int!))
        deck!.append(contentsOf: Array(repeating: .locomotive, count: deckConfig[Color.red.key].int!))
        
        // Use random deck instead
        if !realDeck {
            let total = deck!.count
            probabilities = [
                Double(deckConfig[Color.red.key].int!) / Double(total),
                Double(deckConfig[Color.red.key].int!) / Double(total),
                Double(deckConfig[Color.red.key].int!) / Double(total),
                Double(deckConfig[Color.red.key].int!) / Double(total),
                Double(deckConfig[Color.red.key].int!) / Double(total),
                Double(deckConfig[Color.red.key].int!) / Double(total),
                Double(deckConfig[Color.red.key].int!) / Double(total),
                Double(deckConfig[Color.red.key].int!) / Double(total),
                
                Double(deckConfig[Color.red.key].int!) / Double(total)
            ]
            deck = nil
        }
        
        self.players = []
        for (i, player) in players.enumerated() {
            log.debug("\(String(describing: type(of: player))) Player \(i) initializing hand")
            let p = Player(withInterface: player, andGame: self)
            for _ in 0..<rules[Rules.kStartingHandSize].int! {
                p.addCardToHand(draw())
            }
            self.players.append(p)
        }
        log.verbose("Rng Seed: \(seed)")
        
        self.board.game = self

        for _ in 0..<rules[Rules.kFaceUpCards].int! {
            cards.append(draw())
        }
        log.debug("Initialize face up cards: \(cards)")
        log.debug("Game initialized: \(players)")
    }
    
    // 12 of each color (8 colors)
    // 14 locomotive
    // (12 * 8) + 14 = 110
    // 12 / 110 =
    func draw() -> Color {
        
        if deck != nil {
            // Real deck
            if deck!.isEmpty {
                log.error("Ran out of cards!")
                fatalError()
            } else {
                let rngout: UInt64 = rng.random()
                let rv = deck!.remove(at: Int(rngout % UInt64(deck!.count)))
                log.verbose("Drew a \(rv), \(deck!.count) cards left in deck")
                return rv
            }
        } else {
            let rngout: UInt64 = rng.random()
            let rand = Double(rngout) / Double(UInt64.max)
            var accum = 0.0
            for (i, prob) in probabilities!.enumerated() {
                accum += prob
                if rand < accum {
                    let rv = Color.colorForIndex(i)!
                    log.verbose("Drew a \(rv)")
                    return rv
                }
            }
            
            log.warning("Double Math error")
            return .locomotive
        }
    }
    
    // Return the card selected by the player
    // - return the card chosen and a boolean indicating whether
    //   the player should be alowed to pick another card - if the
    //   player picks a face up locomotive then they cannot choose
    //   another card
    func pickCard(fn: Action.DrawCardsFunc, cards: [Color]) -> (Color, Bool) {
        // return values
        var selectedCard: Color
        var drawAgain = true
        
        // case 1: selected card index is not nil
        if let i = fn(cards) {
            // takeCard returns nil if card index is out of range
            // case 1a: selected card index is not out of range
            if let tmp = takeCard(at: i) {
                selectedCard = tmp
                log.verbose("Took face up \(selectedCard) card")
                if selectedCard == .locomotive {
                    // player picked a face up locomotive
                    drawAgain = false
                }
            // case 1b: selected card index is out of range
            } else {
                // draw from the pile if card is out of range
                selectedCard = draw()
                log.verbose("Drew \(selectedCard) - index out of range")
            }
        // case 2: selected card index is nil - draw from pile
        } else {
            selectedCard = draw()
            log.verbose("Drew \(selectedCard)")
        }
        
        return (selectedCard, drawAgain)
    }
    
    func runTurnForPlayer(_ player: Player) {
        switch player.interface.actionToTakeThisTurn(turn) {
        
        // TODO: Clean up this drawCards part
        case .drawCards(let fn):
            var c: Color
            var drawAgain: Bool
            
            // first card
            (c, drawAgain) = pickCard(fn: fn, cards: cards)
            
            player.addCardToHand(c)
            player.interface.drewCard(c)
            
            // if they didn't pick a face up locomotive, then they get a second card
            if drawAgain {
                // second card, filter locomotives, can't take one
                (c, drawAgain) = pickCard(fn: fn, cards: cards.filter({ $0 != .locomotive }))
            
                player.addCardToHand(c)
                player.interface.drewCard(c)
            }
        case .getNewDestinations(let fn):
            var destinations: [Destination] = []
            for _ in 0..<rules[Rules.kNumDestinationsToChooseFrom].int! {
                destinations.append(board.generateDestination())
            }
            
            var indices: [Int] = []
            while true {
                indices = fn(destinations)
                if !indices.isEmpty {
                    break
                }
            }
            
            var kept: [Destination] = []
            for index in indices {
                kept.append(destinations[index])
            }
            
            player.destinations.append(contentsOf: kept)
            player.interface.keptDestinations(kept)
            
        case .playTrack(let fn):
            let tracks = unownedTracks().filter({ player.canAffordTrack($0) })
            if tracks.isEmpty {
                log.warning("No avaliable tracks")
                runTurnForPlayer(player)
            }
            let (i, l, c) = fn(tracks)
            let track = tracks[i]
            
            if track.color != .unspecified && c != nil {
                log.error("Can't have color be specified if track has a specified color")
                fatalError()
            }
            
            var color: Color
            if c == nil {
                if track.color == .unspecified {
                    color = player.mostColorInHand()
                } else {
                    color = track.color
                }
            } else {
                color = c!
            }
            
            log.verbose("Color: \(color), Track: \(track.color)")
            
            var loc: Int
            if l == nil {
                // Use locomotives only if necessary
                if  track.length > player.cardsInHand(color) {
                    loc = track.length - player.cardsInHand(color)
                } else {
                    loc = 0
                }
            } else {
                // Otherwise use given number of locomotives
                loc = l!
            }
            
            player.spendCards(.locomotive, cost: loc)
            player.spendCards(color, cost: track.length - loc)
            
            trackIndex[track] = player
            player.interface.playedTrack(track)
        }
        
        log.verbose("\(String(describing: type(of: player))) Player \(players.index(of: player)!) " +
            "Turn \(turn / player.game.players.count) Complete")
    }
    
    public func start() -> [Int] {
        let start = DispatchTime.now()
        log.debug("Starting game: \(players) at \(start.uptimeNanoseconds)ns")
        for (i, player) in players.enumerated() {
            log.debug("\(String(describing: type(of: player))) Player \(i) choosing initial destinations")
            player.interface.startingTurn(turn)
            var destinations: [Destination] = [board.generateDestination(lengthMin: 20)]
            for _ in 1..<rules[Rules.kNumDestinationsToChooseFrom].int! {
                destinations.append(board.generateDestination(lengthMax:19))
            }
            let kept = player.interface.pickInitialDestinations(destinations).map({ destinations[$0] })
            player.destinations.append(contentsOf: kept)
            player.interface.keptDestinations(kept)
            log.debug("\(String(describing: type(of: player))) Player \(i) kept destinations: \(kept)")

            turn += 1
        }
        
        log.debug("All players have selected initial destinations")
        log.debug("===== Start normal game turns ======")

        var pt: Int! = nil
        while turn < 1000 {
            for player in players {
                if player.hand[.unspecified] != nil {
                    log.warning("Whoa there")
                }
                player.interface.startingTurn(turn)
                runTurnForPlayer(player)
                
                if (pt != nil && turn >= pt + players.count) || unownedTracks().isEmpty {
                    let end = DispatchTime.now()
                    self.time = Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000
                    log.debug("Ended on turn \(turn) at \(end.uptimeNanoseconds)ns, lasted \(time!) seconds")
                    return winners()
                } else if pt == nil && player.trainsLeft() < rules[Rules.kMinTrains].int! {
                    pt = turn
                }
                
                turn += 1
            }
        }
        log.error("Hit turn limit")
        return []
    }
    
    public func winners() -> [Int] {
        let rv = players.map({ (player: Player) -> Int in
            var points = 0
            for track in tracksOwnedBy(player) {
                points += track.points()!
            }
            for dest in player.destinations where playerMeetsDestination(player, dest) {
                points += dest.length
            }
            for dest in player.destinations where !playerMeetsDestination(player, dest) {
                points -= dest.length
            }
            return points
            
        })
        if rv.isEmpty {
            log.error("No Players")
        }
        return rv
    }
    
    func playerOwnsTrack(_ player: Player, _ track: Track) -> Bool {
        return trackIndex[track] == player
    }
    
    func isTrackUnowned(_ track: Track) -> Bool {
        return trackIndex[track] == nil
    }
    
    func tracksOwnedBy(_ player: Player) -> [Track] {
        var rv: [Track] = []
        for (track, _) in trackIndex where playerOwnsTrack(player, track) {
            rv.append(track)
        }
        return rv
    }
    
    func unownedTracks() -> [Track] {
        return board.getAllTracks().filter({ isTrackUnowned($0) })
    }
    
    func checkForMaxLocomotives() {
        if cards.reduce(0, { res, color in
            if color == .locomotive {
                return res + 1
            } else {
                return res
            }}) >= rules[Rules.kMaxLocomotivesFaceUp].int! {
            // Refresh cards, too many locomotives
            var newCards: [Color] = []
            for _ in 0..<rules[Rules.kFaceUpCards].int! {
                newCards.append(draw())
            }
            cards = newCards
            checkForMaxLocomotives()
        }
    }
    
    func takeCard(at index: Int) -> Color? {
        if index >= cards.count || index < 0 {
            return nil
        }
        
        let rv = cards.remove(at: index)
        log.verbose("Player took face up \(rv) card - draw a replacement card")
        cards.append(draw())
        checkForMaxLocomotives()
        return rv
    }
    
    public func playerMeetsDestination(_ player: Player, _ destination: Destination) -> Bool {
        var queue: [Track] = []
        let city = destination.cities[0]
        
        var fn: ((City) -> Bool)! = nil
        fn = { city in
            for track in city.tracks where self.playerOwnsTrack(player, track) && !queue.contains(track) {
                queue.append(track)
                let endpoint = track.getOtherCity(city)!
                
                if endpoint == destination.cities[1] {
                    return true
                }
                
                if fn(endpoint) {
                    return true
                }
                
                queue.removeLast()
            }
            return false
        }
        
        return fn(city)
    }
    
    func playerDestinationPoints(_ player: Player) -> Int {
        var rv = 0
        for destination in player.destinations {
            if playerMeetsDestination(player, destination) {
                rv += destination.length
            }
        }
        return rv
    }
}
