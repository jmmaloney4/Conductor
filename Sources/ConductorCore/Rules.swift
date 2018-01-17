// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftyJSON

public struct Rules {
    public static let kStartingHandSize = "startingHandSize"
    public static let kFaceUpCards = "faceUpCards"
    public static let kMaxLocomotivesFaceUp = "maxLocomotivesFaceUp"
    public static let kNumDestinationsToChooseFrom = "numDestinationsToChooseFrom"
    public static let kInitialTrains = "initialTrains"
    public static let kMinTrains = "minTrains"
    public static let kUseRealDeck = "useRealDeck"
    public static let kDeck = "deck"
    
    public static let allKeys = [kStartingHandSize, kFaceUpCards, kMaxLocomotivesFaceUp, kNumDestinationsToChooseFrom, kInitialTrains, kMinTrains, kUseRealDeck, kDeck]
}
    /*
    
    public enum Rule {
        case int(Int)
        case bool(Bool)
        case string(String)
        case double(Double)
        case deck([Color:Int])

        var int: Int? {
            switch self {
            case .int(let rv): return rv
            default: return nil
            }
        }

        var bool: Bool? {
            switch self {
            case .bool(let rv): return rv
            default: return nil
            }
        }

        var string: String? {
            switch self {
            case .string(let rv): return rv
            default: return nil
            }
        }

        var double: Double? {
            switch self {
            case .double(let rv): return rv
            default: return nil
            }
        }

        var deck: [Color:Int]? {
            switch self {
            case .deck(let rv): return rv
            default: return nil
            }
        }
    }

    private var dictionary: [String:Rule] = [:]

    convenience public init(fromJSONFile path: String) throws {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            throw ConductorError.fileError(path: path)
        }
        try self.init(fromData: data)
    }

    public init(fromData data: Data) throws {
        let json = JSON(data: data)

        for key in Rules.allKeys {
            let subJson = json[key]
            if let int = subJson.int {
                dictionary[key] = .int(int)
            } else if let bool = subJson.bool {
                dictionary[key] = .bool(bool)
            } else if let string = subJson.string {
                dictionary[key] = .string(string)
            } else if let double = subJson.double {
                dictionary[key] = .double(double)
            } else if key == Rules.kDeck {
                guard let dict = subJson.dictionary else {
                    log.debug("Failed to parse deck from Rules JSON, using random deck.")
                    dictionary[key] = nil
                    continue;
                }

                var deck: [Color:Int] = [:]
                for (key, value) in dict {
                    deck[Color.colorForName(key)!] = value.int!
                }

                dictionary[key] = .deck(deck)
            } else {
                throw ConductorError.invalidJSON
            }
        }
    }

    public func get(_ key: String) -> Rule {
        if let rv = dictionary[key] {
            return rv
        } else {
            log.error("Rule \(key) not defined")
            fatalError()
        }
    }

    public var json: JSON {
        var dict: [String:Any?] = [:]
        for (key, value) in dictionary {
            switch value {
            case .int(let int):
                dict[key] = int
            case .bool(let bool):
                dict[key] = bool
            case .string(let string):
                dict[key] = string
            case .double(let double):
                dict[key] = double
            case .deck(let deck):
                dict[key] = deck
            }
        }
        return JSON(dict)
    }
 }
    */
