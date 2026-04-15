import SwiftUI

public protocol Routable: Hashable, Identifiable {
    associatedtype ViewType: View
    @ViewBuilder func destination() -> ViewType
}

extension Routable {
    public var id: Self { self }
}
