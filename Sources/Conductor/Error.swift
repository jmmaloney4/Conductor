// Copyright © 2017-2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

internal enum ConductorError: Error {
    case fileInputError(path: String)
    case dataInputError
    case jsonDecodingError
    case outOfCardsError
}

internal enum ConductorCodingError: Error {
    case unknownValue
    case invalidState
}
