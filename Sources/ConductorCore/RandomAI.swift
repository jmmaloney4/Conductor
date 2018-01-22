//
//  RandomAI.swift
//  An agent that randomly selects an action from the available actions.  This
//  agent can be used to verify that the logic of another agent actually performs
//  better than just randomly selecting an action.
//
//  Created by John Maloney on 1/19/18.
//

import Foundation
import Squall

public class RandomAI: AI {
    /// instance variables
    private var rng: Gust

    // initialize a random agent
    public override init() {
        let seed = UInt32(Date().timeIntervalSinceReferenceDate) + (globalRng.random() / 100000)
        self.rng = Gust(seed: seed)
    }

    /// Return this players kind
    public override var kind: PlayerKind {
        return .randomAI
    }

    /// Randomly select an action from the available actions
    ///
    /// The agent does the following:
    ///  (1) Construct a list of potential actions to take:
    ///      (a) If affordable tracks are avaiable then "play track" is an option
    ///      (b) Draw cards is always an option
    ///      (c) Take another destination is NEVER an option
    ///  (2) If more than one action is available, randomly choose an action
    ///  (3) Take the selected action:
    ///      (a) If selected
    ///  (4) If the selected action is to purchase a track then randomly
    ///      selected one of the affordable tracks and allow the system to
    ///      choose the cards to use to purchase the track
    ///  (5) If selected action is draw a card then randomly choose among
    ///      the available face up cards and the 2 card piles
    ///
    public override func actionToTakeThisTurn(_ turn: Int) -> Action {
        // initially, assume there are not tracks available
        var playTrack = false

        // get list of the affordable tracks
        let affordableTracks = player.game.unownedTracks().filter({player.canAffordTrack($0)})
        let numTracks = affordableTracks.count
        log.verbose("Number of affordable tracks: \(numTracks)")

        if numTracks > 0 {
            // randomly choose between playing track and drawing cards
            // - 33% chance to play track
            // - 66% chance to draw cards
            if genRandomInt(3) < 1 {
                playTrack = true
                log.verbose("Agent choose to play track")
            }
            else {
                log.verbose("Agent choose to draw cards")
            }
        }
        
        /// take the selected action
        let action: Action
        if playTrack {
            action = .playTrack({ (tracks: [Track]) -> (Int, Int?, Color?) in
                return (self.genRandomInt(tracks.count), nil, nil)
            })
        }
        else { // draw cards
            action = .drawCards({ (cards: [Color]) -> Int? in
                let selectedCard = self.genRandomInt(cards.count + 2)
                if (selectedCard >= cards.count) {
                    /// draw a random card from the deck
                    return (nil)
                }
                // pick up the selected face up card
                return (selectedCard)
            })
        }

        return action
    }
    
    /// Generate a random integer between zero and the specified value
    private func genRandomInt(_ max: Int) -> Int {
        let rngout: UInt64 = rng.random()
        return Int(rngout % UInt64(max))
    }
}
