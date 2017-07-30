// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftPriorityQueue
import SwiftyJSON

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

public class City: CustomStringConvertible, Hashable {
    internal private(set) var name: String
    internal private(set) var tracks: [Track] = []

    public var description: String { return name }
    public var hashValue: Int { return ObjectIdentifier(self).hashValue }
    public static func == (lhs: City, rhs: City) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    init(withName name: String) {
        self.name = name
    }

    func addTrack(_ track: Track) {
        tracks.append(track)
    }

    func isAdjacentToCity(_ city: City) -> Bool {
        for track in tracks {
            if track.endpoints.contains(where: { $0 === city }) {
                return true
            }
        }
        return false
    }
}

public class Track: CustomStringConvertible, Hashable {
    internal private(set) var endpoints: [City]
    internal private(set) var color: Color
    internal private(set) var length: Int
    internal private(set) var tunnel: Bool
    internal private(set) var ferries: Int

    public var description: String { return "\(endpoints[0]) to \(endpoints[1])" }
    public var hashValue: Int { return ObjectIdentifier(self).hashValue }
    public static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    init(between cityA: City, and cityB: City, length: Int, color: Color,
         tunnel: Bool = false, ferries: Int = 0) {
        endpoints = [cityA, cityB]
        self.color = color
        self.length = length
        self.tunnel = tunnel
        self.ferries = ferries
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

    func points() -> Int? {
        switch length {
        case 1: return 1
        case 2: return 2
        case 3: return 4
        case 4: return 7
        case 6: return 15
        case 8: return 21
        default: return nil
        }
    }
}

public enum ConductorError: Error {
    case invalidJSON
}

public class Board: CustomStringConvertible {
    var cities: [City]

    public var description: String {
        let sorted = cities.sorted(by: { $0.tracks.count > $1.tracks.count })
        print(sorted)

        return sorted.map({ $0.description + ": " + $0.tracks.map({ $0.description }).joined(separator: ", ") }).joined(separator: "\n")
    }

    public init(fromJSONFile path: String) throws {

        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let json = JSON(data: data)

        self.cities = []

        for (_, subJson):(String, JSON) in json {

            guard let cityAName = subJson["endpoints"][0].string else {
                throw ConductorError.invalidJSON
            }
            guard let cityBName = subJson["endpoints"][1].string else {
                throw ConductorError.invalidJSON
            }

            var cityA: City
            let cityAlist = cities.filter({$0.name == cityAName})
            if cityAlist.isEmpty {
                cityA = City(withName: cityAName)
                cities.append(cityA)
            } else if cityAlist.count == 1 {
                cityA = cityAlist[0]
            } else {
                fatalError("Shouldn't be more than one city with same name")
            }

            var cityB: City
            let cityBlist = cities.filter({$0.name == cityBName})
            if cityBlist.isEmpty {
                cityB = City(withName: cityBName)
                cities.append(cityB)
            } else if cityBlist.count == 1 {
                cityB = cityBlist[0]
            } else {
                fatalError("Shouldn't be more than one city with same name")
            }

            guard let colorName = subJson["color"].string else {
                throw ConductorError.invalidJSON
            }
            guard let color = Color.colorForName(colorName) else {
                throw ConductorError.invalidJSON
            }
            guard let length = subJson["length"].int else {
                throw ConductorError.invalidJSON
            }
            guard let tunnel = subJson["tunnel"].bool else {
                throw ConductorError.invalidJSON
            }
            guard let ferries = subJson["ferries"].int else {
                throw ConductorError.invalidJSON
            }

            let track = Track(between: cityA, and: cityB, length: length, color: color, tunnel: tunnel, ferries: ferries)
            cityA.addTrack(track)
            cityB.addTrack(track)
        }
    }
}

