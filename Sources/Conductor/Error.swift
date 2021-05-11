import Foundation

public enum ConductorError: Error {
    case fileInputError(path: String)
    case dataInputError
    case jsonDecodingError
}
