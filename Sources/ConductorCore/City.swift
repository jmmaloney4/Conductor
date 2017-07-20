// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public class City: CustomStringConvertible {
    var name: String
    var tracks: [Track] = []
    public var description: String { return name }

    public init(withName name: String) {
        self.name = name
    }

    internal func addTrack(_ track: Track) {
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

    func tracksToCity(_ city: City) -> [Track]? {
        if !self.isAdjacentToCity(city) {
            return nil
        }

        var rv: [Track] = []
        for track in tracks {
            if track.connectsToCity(city) {
                rv.append(track)
            }
        }

        return rv
    }

    func shortestTrackToCity(_ city: City) -> Int {
        return self.tracksToCity(city)!.reduce(Int.max, {
            if $1.length < $0 {
                return $1.length
            } else {
                return $0
            }
        })
    }
}
