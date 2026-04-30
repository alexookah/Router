import SwiftUI

/// A type that maps an enum case to a SwiftUI view, used as the destination type for `Router`.
@MainActor
public protocol Routable: Hashable, Identifiable {
    associatedtype ViewType: View
    @ViewBuilder func destination() -> ViewType
}

extension Routable {
    public var id: Self { self }
}
