import SwiftUI

/// Runs `action` with implicit animations disabled, mirroring `withAnimation { ... }`.
@MainActor
@discardableResult
func withoutAnimation<R>(_ action: () throws -> R) rethrows -> R {
    var transaction = Transaction()
    transaction.disablesAnimations = true
    return try withTransaction(transaction, action)
}
