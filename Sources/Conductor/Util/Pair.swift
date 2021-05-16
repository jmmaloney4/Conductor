// Copyright © 2017-2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

struct Pair<A, B> {
    var a: A
    var b: B
}

extension Pair: Codable where A: Codable, B: Codable {}

extension Pair: Collection where A == B {
    typealias Element = A

    var startIndex: Int { 0 }
    var endIndex: Int { 2 }

    subscript(index: Int) -> Element {
        switch index {
        case 0: return a
        case 1: return b
        default: fatalError("Index out of bounds.")
        }
    }

    func index(after i: Int) -> Int {
        precondition(i < endIndex, "Can't advance beyond endIndex")
        return i + 1
    } s
}
