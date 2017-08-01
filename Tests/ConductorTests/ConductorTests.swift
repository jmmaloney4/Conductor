// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import ConductorCore

func checkDirectory() {
    // Check for proper current directory
    if !FileManager.default.currentDirectoryPath.hasSuffix("/Tests") {
        fatalError("\n\n\n !!! Please run tests in Tests/ directory !!! \n\n\n")
    }
}

public class InitTests: XCTestCase {
    public static var allTests = {
        return [
            ("testRulesFromJSON", testRulesFromJSON),
            ("testBoardFromJSON", testBoardFromJSON),
            ]
    }()

    public override func setUp() {
        super.setUp()
        checkDirectory()
    }

    public override func tearDown() {
        super.tearDown()
    }

    func testRulesFromJSON() {
        XCTAssertNoThrow(try Rules(fromJSONFile: "Resources/rules.json"))
    }

    func testBoardFromJSON() {
        XCTAssertNoThrow(try Board(fromJSONFile: "Resources/europe.json"))
    }
}

public class RandomnessTests: XCTestCase {

    var game: Game! = nil

    public static var allTests = {
        return [
            ("testDrawRandomness", testDrawRandomness),
            ]
    }()

    public override func setUp() {
        super.setUp()
        checkDirectory()
        let rules = try! Rules(fromJSONFile: "Resources/rules.json")
        let board = try! Board(fromJSONFile: "Resources/europe.json")
        game = Game(withRules: rules, board: board, andPlayers: CLIPlayerInterface(), CLIPlayerInterface())
    }

    public override func tearDown() {
        super.tearDown()
    }

    func testDrawRandomness() {
        for _ in 0..<100_000 {
            game.players[0].addCardToHand(game.draw())
        }
        for (color, count) in game.players[0].hand {
            if color != .locomotive {
                XCTAssertGreaterThan(count, 10300)
                XCTAssertLessThan(count, 12200)
            } else {
                XCTAssertGreaterThan(count, 12300)
                XCTAssertLessThan(count, 13200)
            }
        }
    }
}

public class BoardTests: XCTestCase {
    public static var allTests = {
        return [
            ("testBoard", testBoard),
            ]
    }()

    public override func setUp() {
        super.setUp()
        checkDirectory()
    }

    public override func tearDown() {
        super.tearDown()
    }

    func testBoard() {
        let board = try! Board(fromJSONFile: "Resources/europe.json")

        print(board)

        let paris = board.getCityForName("Paris")
        let dieppe = board.getCityForName("Dieppe")
        let petrograd = board.getCityForName("Petrograd")

        XCTAssertNotNil(paris)
        XCTAssertNotNil(dieppe)
        XCTAssertNotNil(petrograd)

        XCTAssertEqual(paris!.name, "Paris")
        XCTAssertEqual(dieppe!.name, "Dieppe")
        XCTAssertEqual(petrograd!.name, "Petrograd")

        XCTAssertTrue(paris!.isAdjacentToCity(dieppe!))
        XCTAssertTrue(dieppe!.isAdjacentToCity(paris!))
        XCTAssertFalse(paris!.isAdjacentToCity(petrograd!))
        XCTAssertFalse(petrograd!.isAdjacentToCity(paris!))
    }
}
