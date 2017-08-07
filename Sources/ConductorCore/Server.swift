// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Socket
import Dispatch
import SwiftyJSON

struct Message {
    var data: Data

    init(string: String) throws {
        switch string.data(using: .utf8) {
        case .some(let data): self.data = data
        case .none: throw ConductorError.dataError
        }
    }

    init(json: JSON) throws {
        guard let string = json.rawString() else {
            throw ConductorError.jsonToStringError
        }
        try self.init(string: string)
    }

    init(from socket: Socket) throws {
        let countPointer = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        try countPointer.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: Int()), {
            try _ = socket.read(into: $0, bufSize: MemoryLayout.size(ofValue: Int()), truncate: true)
        })

        let dataPointer = UnsafeMutablePointer<CChar>.allocate(capacity: countPointer.pointee)
        try _ = socket.read(into: dataPointer, bufSize: countPointer.pointee, truncate: true)
        self.data = Data(bytes: dataPointer, count: countPointer.pointee)

        dataPointer.deallocate(capacity: countPointer.pointee)
        countPointer.deallocate(capacity: 1)
    }

    func send(on socket: Socket) throws {
        var count = data.count
        try socket.write(from: Data(bytes: &count, count: MemoryLayout.size(ofValue: count)))
        try socket.write(from: data)
    }

    var string: String? {
        return String(data: self.data, encoding: .utf8)
    }
}

public class Server {
    var game: Game
    var socket: Socket
    var listen: Bool = true

    public init(port: Int, game: Game) throws {
        self.game = game

        let lock = DispatchQueue(label: "Conductor")

        do {
            socket = try Socket.create(family: .inet6)
            try socket.listen(on: port)

            DispatchQueue.global(qos: .default).async {
                while self.listen {
                    lock.sync {
                        guard let clientSocket = try? self.socket.acceptClientConnection() else {
                            print("Ran into error while listening for connections")
                            return
                        }
                        print("Accepted connection from: \(clientSocket.remoteHostname) on port \(clientSocket.remotePort)")
                        print("Socket Signature: \(clientSocket.signature?.description ?? "")")

                        do {
                            let rulesMessage = try Message(json: self.game.rules.json)
                            try rulesMessage.send(on: clientSocket)

                            let boardMessage = try Message(json: self.game.board.json)
                            try boardMessage.send(on: clientSocket)
                        } catch {
                            print("Failed to send game info to client")
                            return
                        }
                    }
                }
            }
        } catch {
            throw error
        }
    }

    func getNextGameID() -> Int {
        struct const {
            static var next = -1
        }
        const.next += 1
        return const.next
    }

    /*
    func start()  {
        self.listen = false
        game.start()
    }
    */
}
