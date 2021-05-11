import Foundation

public enum CardColor: Hashable {
    case color(name: String)
    case locomotive
}

public enum TrackColor {
    case color(name: String)
    case unspecified
}
