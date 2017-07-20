// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public class Track: CustomStringConvertible {
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
        case locomotive = 9 // Used for cards, not tracks

        static var count: Int = 9

        static func colorForIndex(_ index: Int) -> Color {
            switch index {
            case Color.red.rawValue: return .red
            case Color.blue.rawValue: return .blue
            case Color.black.rawValue: return .black
            case Color.white.rawValue: return .white
            case Color.orange.rawValue: return .orange
            case Color.yellow.rawValue: return .yellow
            case Color.pink.rawValue:
                return .pink
            case Color.green.rawValue:
                return .green
            case Color.locomotive.rawValue:
                return .locomotive
            default:
                fatalError()
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

    var endpoints: [City]
    var length: Int
    var color: Color
    var tunnel: Bool
    var ferries: Int
    var owner: Player?

    public var description: String {
        return "\(endpoints[0]) to \(endpoints[1])" +
        "(\(length), \(color), \(owner != nil ? owner!.description : "No Owner"))"
    }

    init(between cityA: City, and cityB: City, length: Int, color: Color,
         tunnel: Bool = false, ferries: Int = 0, addTracks: Bool = true) {
        endpoints = [cityA, cityB]
        self.length = length
        self.color = color
        self.tunnel = tunnel
        self.ferries = ferries

        if addTracks {
            cityA.addTrack(self)
            cityB.addTrack(self)
        }
    }

    func connectsToCity(_ city: City) -> Bool {
        if endpoints.contains(where: { $0 === city }) {
            return true
        }
        return false
    }

    func getOtherCity(_ city: City) -> City? {
        if !self.connectsToCity(city) {
            return nil
        }
        return endpoints.filter({ $0 !== city })[0]
    }
}
