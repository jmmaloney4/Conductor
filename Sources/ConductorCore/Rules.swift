// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftyJSON

public class Rules {
    public var startingHandSize: Int

    public init(fromJSONFile path: String) throws {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            throw ConductorError.fileError(path: path)
        }

        let json = JSON(data: data)

        switch json["startingHandSize"].int {
        case .some(let size):
            startingHandSize = size
        case .none:
            throw ConductorError.invalidJSON
        }

        
    }


}
