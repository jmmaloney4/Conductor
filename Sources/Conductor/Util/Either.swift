// Copyright © 2017-2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

struct Either<U, V> {
    var left: U?
    var right: V?
}

extension Either: Codable where U: Codable, V: Codable {
    internal init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let u = try? container.decode(U.self) {
            self = Either(left: u, right: nil)
        } else if let v = try? container.decode(V.self) {
            self = Either(left: nil, right: v)
        } else {
            throw ConductorCodingError.unknownValue
        }
    }

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if left != nil, right != nil {
            throw ConductorCodingError.invalidState
        }
        if left != nil {
            try container.encode(left)
        } else {
            try container.encode(right)
        }
    }
}
