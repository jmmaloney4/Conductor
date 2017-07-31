// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import ConductorCore

public class InitTests: XCTestCase {
    public static var allTests = {
        return [
            ("testRulesFromJSON", testRulesFromJSON),
            ("testBoardFromJSON", testBoardFromJSON),
            ]
    }()

    public override func setUp() {
        super.setUp()
        // Check for proper current directory
        if !FileManager.default.currentDirectoryPath.hasSuffix("/Tests") {
            fatalError("\n\n\n !!! Please run tests in Tests/ directory !!! \n\n\n")
        }
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
