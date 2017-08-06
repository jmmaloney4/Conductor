// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Socket
import Dispatch

public class Server {
    var game: Game
    var socket: Socket
    var listen: Bool = true

    public init(port: Int, game: Game) throws {
        self.game = game

        do {
            socket = try Socket.create(family: .inet6)
            try socket.listen(on: port)

            DispatchQueue.global(qos: .default).async(
                execute: {
                while self.listen {

                    guard let clientSocket = try? self.socket.acceptClientConnection() else {
                        print("Ran into error while listening for connections")
                        return
                    }
                    print("Accepted connection from: \(clientSocket.remoteHostname) on port \(clientSocket.remotePort)")
                    print("Socket Signature: \(clientSocket.signature?.description ?? "")")
                    game.addPlayer(clientSocket)
                }
            })
        } catch {
            throw error
        }
    }

    func start()  {
        self.listen = false
        game.start()
    }

}
