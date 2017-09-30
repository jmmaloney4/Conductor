// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public class City: CustomStringConvertible, Hashable {
    public private(set) var name: String
    internal private(set) var tracks: [Track] = []
    internal private(set) weak var board: Board?

    public var description: String { return name }
    public var hashValue: Int { return ObjectIdentifier(self).hashValue }
    public static func == (lhs: City, rhs: City) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    init(withName name: String, board: Board) {
        self.name = name
        self.board = board
    }

    func addTrack(_ track: Track) {
        tracks.append(track)
    }

    public func isAdjacentToCity(_ city: City) -> Bool {
        for track in tracks where track.connectsToCity(city) {
            return true
        }
        return false
    }

    func tracksToAdjacentCity(_ city: City) -> [Track]? {
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

    func shortestTrackToAdjacentCity(_ city: City) -> Track {
        let tracks = self.tracksToAdjacentCity(city)!
            return tracks.reduce(tracks[0], {
            if $1.length < $0.length {
                return $1
            } else {
                return $0
            }
        })
    }
}
