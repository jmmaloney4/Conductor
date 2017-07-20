// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public class Destination: CustomStringConvertible {
    var endpoints: [City]
    var length: Int
    public var description: String { return "\(endpoints[0]) to \(endpoints[1]) (\(length))" }

    init(from cityA: City, to cityB: City, length: Int) {
        endpoints = [cityA, cityB]
        self.length = length
    }
}
