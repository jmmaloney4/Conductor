// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Socket
import KituraNet
import SwiftyJSON

public class Client {
    var game: Game
    var socket: Socket

    public init(host: String, port: Int) throws {
        do {
            socket = try Socket.create()
            try socket.connect(to: host, port: Int32(port))

            let rulesMessage = try Message(from: socket)
            let boardMessage = try Message(from: socket)

            let rules = try Rules(fromData: rulesMessage.data)
            let board = try Board(fromData: boardMessage.data)


        } catch {
            throw error
        }
    }

}
