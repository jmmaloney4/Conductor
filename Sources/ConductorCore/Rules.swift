// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftyJSON

// swiftlint:disable explicit_type_interface
public struct Rules {
    public static let kStartingHandSize = "startingHandSize"
    public static let kFaceUpCards = "faceUpCards"
    public static let kMaxLocomotivesFaceUp = "maxLocomotivesFaceUp"
    public static let kNumDestinationsToChooseFrom = "numDestinationsToChooseFrom"
    public static let kInitialTrains = "initialTrains"
    public static let kMinTrains = "minTrains"
    public static let kUseRealDeck = "useRealDeck"
    public static let kDeck = "deck"

    public static let allKeys = [kStartingHandSize, kFaceUpCards, kMaxLocomotivesFaceUp, kNumDestinationsToChooseFrom,
                                 kInitialTrains, kMinTrains, kUseRealDeck, kDeck]
}
