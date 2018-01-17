// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftPriorityQueue
import Weak
import SwiftyBeaver
import Squall

public let log = SwiftyBeaver.self
public let globalRng = Gust(seed: UInt32(Date().timeIntervalSinceReferenceDate))

public class Conductor {
    public static let console = ConsoleDestination()

    public class func initLog() {
        console.asynchronously = false
        console.minLevel = log.Level.info
        log.addDestination(console)
    }
}

public enum ConductorError: Error {
    case invalidJSON
    case fileError(path: String)
    case jsonToStringError
    case socketError
    case dataError
}

public enum Color: Int, CustomStringConvertible {
    case red = 0
    case blue = 1
    case black = 2
    case white = 3
    case orange = 4
    case yellow = 5
    case pink = 6
    case green = 7
    case unspecified = -1 // Used only for tracks
    case locomotive = 8 // Used for cards, not tracks

    static func colorForIndex(_ index: Int) -> Color? {
        switch index {
        case Color.red.rawValue: return .red
        case Color.blue.rawValue: return .blue
        case Color.black.rawValue: return .black
        case Color.white.rawValue: return .white
        case Color.orange.rawValue: return .orange
        case Color.yellow.rawValue: return .yellow
        case Color.pink.rawValue: return .pink
        case Color.green.rawValue: return .green
        case Color.locomotive.rawValue: return .locomotive
        default: return nil
        }
    }

    static func colorForName(_ name: String) -> Color? {
        switch name {
        case Color.red.description: return .red
        case Color.blue.description: return .blue
        case Color.black.description: return .black
        case Color.white.description: return .white
        case Color.orange.description: return .orange
        case Color.yellow.description: return .yellow
        case Color.pink.description: return .pink
        case Color.green.description: return .green
        case Color.unspecified.description: return .unspecified
        case Color.locomotive.description: return .locomotive
        default: return nil
        }
    }

    public var description: String {
        switch self {
        case .red: return "Red"
        case .blue: return "Blue"
        case .black: return "Black"
        case .white: return "White"
        case .orange: return "Orange"
        case .yellow: return "Yellow"
        case .pink: return "Pink"
        case .green: return "Green"
        case .unspecified: return "Unspecified"
        case .locomotive: return "Locomotive"
        }
    }
}
