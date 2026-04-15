import SwiftUI

public enum NavigationType {
    case push
    case fullScreenCover
    case sheet
}

public enum NavigationTarget {
    case current
    case parent
    case child
    case root
    case deepest
}
