// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftyJSON

public class Rules {
    public static let kStartingHandSize = "startingHandSize"
    public static let kFaceUpCards = "faceUpCards"
    public static let kMaxLocomotivesFaceUp = "maxLocomotivesFaceUp"
    public static let kNumDestinationsToChooseFrom = "numDestinationsToChooseFrom"
    public static let kInitialTrains = "initialTrains"
    public static let kMinTrains = "minTrains"

    public static let allKeys = [kStartingHandSize, kFaceUpCards, kMaxLocomotivesFaceUp, kNumDestinationsToChooseFrom, kInitialTrains, kMinTrains]

    public enum Rule {
        case int(Int)
        case bool(Bool)
        case string(String)
        case double(Double)

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
    }

    var dictionary: [String:Rule] = [:]

    convenience public init(fromJSONFile path: String) throws {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            throw ConductorError.fileError(path: path)
        }
        try self.init(fromData: data)
    }

    init(fromData data: Data) throws {
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
            } else {
                throw ConductorError.invalidJSON
            }
        }
    }

    func get(_ key: String) -> Rule {
        if let rv = dictionary[key] {
            return rv
        } else {
            fatalError("Rule \(key) not defined")
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
            }
        }
        return JSON(dict)
    }
    
}
