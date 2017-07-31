// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftyJSON

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

struct Destination: CustomStringConvertible {
    var cities: [City]

    var description: String {
        return "\(cities[0]) to \(cities[1])"
    }

    init(cityA: City, cityB: City) {
        cities = [cityA, cityB]
    }
}
