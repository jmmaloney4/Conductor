// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftPriorityQueue
import SwiftyJSON

public class City: CustomStringConvertible, Hashable {
    var name: String
    public var description: String { return name }
    public var hashValue: Int { return ObjectIdentifier(self).hashValue }

    public static func == (lhs: City, rhs: City) -> Bool {

    }
}

public class Track {
    var endpoints: [City]
}

public class Board  {

    

}

