// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Weak

public class Track: CustomStringConvertible, Hashable {
    internal private(set) var endpoints: [Weak<City>]
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
        endpoints = [Weak(cityA), Weak(cityB)]
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
        return endpoints.filter({ $0 !== city })[0].value!
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
