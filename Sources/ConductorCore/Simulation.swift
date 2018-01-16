// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Dispatch

public class Simulation {

    public struct Result: CustomStringConvertible {
        var sim: Simulation
        var scores: [[Int]]

        public var description: String {
            return "\(scores)"
        }

        init(sim: Simulation) {
            self.sim = sim
            self.scores = []
        }

        public func wins() -> [Int] {
            var rv = Array(repeating: 0, count: scores[0].count)
            for game in scores {
                let sorted = game.sorted(by: { $0 > $1 })
                let winner = sorted[0]
                // If theres a tie nobody wins
                if game.filter({ $0 == winner }).count == 1 {
                    rv[game.index(of: winner)!] += 1
                }
            }
            return rv
        }

        public func winrate() -> [Float] {
            return wins().map({ Float($0) / Float(scores.count) })
        }

        public func totalPoints() -> [Int] {
            var rv = Array(repeating: 0, count: scores[0].count)
            for game in scores {
                for (i, v) in game.enumerated() {
                    rv[i] += v
                }
            }
            return rv
        }

        public func averagePoints() -> [Float] {
            return totalPoints().map({ Float($0) / Float(scores.count) })
        }

        public func csv() -> String {
            var rv = ""
            for score in scores {
                for (i, v) in score.enumerated() {
                    if i != 0 {
                        rv += ","
                    }
                    rv += "\(v)"
                }
                rv += "\n"
            }
            return rv
        }
    }

    var rulesData: Data
    var boardData: Data
    var outFile: String?
    var players: [PlayerKind]

    public convenience init(rules: String, board: String, out: String? = nil, players: PlayerKind...) throws {
        try self.init(rules: rules, board: board, out: out, players: players)
    }

    public convenience init(rules: String, board: String, out: String? = nil, players: [PlayerKind]) throws {
        guard let rulesDataTmp = try? Data(contentsOf: URL(fileURLWithPath: rules)) else {
            throw ConductorError.fileError(path: rules)
        }

        guard let boardDataTmp = try? Data(contentsOf: URL(fileURLWithPath: board)) else {
            throw ConductorError.fileError(path: board)
        }

        self.init(rulesData: rulesDataTmp, boardData: boardDataTmp, out: out, players: players)
    }

    public init(rulesData: Data, boardData: Data, out: String?, players: [PlayerKind]) {
        self.rulesData = rulesData
        self.boardData = boardData
        self.outFile = out
        self.players = players
    }

    public func simulate(_ count: Int = 1, async: Bool = true) -> Result {
        var rv: Result = Result(sim: self)
        let group = DispatchGroup()
        for i in 0..<count {
            let fn = {
                let rules = try! Rules(fromData: self.rulesData)
                let board = try! Board(fromData: self.boardData)
                let game = Game(withRules: rules, board: board, andPlayerTypes: self.players)
                let res = game.start()
                log.debug("\(res)")

                if res.count == 0 {
                    log.error("Game Failed")
                }

                rv.scores.append(res)
                log.info("Simulation \(i+1)/\(count): \(res)")
                if async {
                    group.leave()
                }
            }
            if async {
                group.enter()
                DispatchQueue.global(qos: .default).async(execute: fn)
            } else {
                DispatchQueue.global(qos: .default).sync(execute: fn)
            }
        }
        if async {
            group.wait()
        }
        return rv
    }
    
}
