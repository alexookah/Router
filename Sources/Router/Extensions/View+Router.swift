import SwiftUI

// Internal — a generic name like `ifLet` doesn't belong in a routing
// package's public surface; apps define their own.
extension View {
    @ViewBuilder
    func ifLet<T, Content: View>(
        _ value: T?,
        transform: (Self, T) -> Content
    ) -> some View {
        if let value {
            transform(self, value)
        } else {
            self
        }
    }
}
