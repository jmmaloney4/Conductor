import Foundation

internal enum ConductorError: Error {
    case fileInputError(path: String)
    case dataInputError
    case jsonDecodingError
}

internal enum ConductorCodingError: Error {
    case unknownValue
    case invalidState
}
