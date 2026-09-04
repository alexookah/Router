import SwiftUI

/// How a pushed or presented screen animates in and out; `nil` keeps the
/// system default.
public enum PresentationTransition: Equatable {
    /// Zooms out of the view marked `zoomSource(id:)` with the same id, and
    /// back into it on dismiss. Pushes, sheets, and covers, from iOS 18.
    case zoom(sourceID: AnyHashable)
}

/// The namespace a `RoutingView` (or `routerPresentations`) shares between
/// zoom sources inside it and the screens it pushes or presents.
struct TransitionNamespaceKey: EnvironmentKey {
    static let defaultValue: Namespace.ID? = nil
}

extension EnvironmentValues {
    var transitionNamespace: Namespace.ID? {
        get { self[TransitionNamespaceKey.self] }
        set { self[TransitionNamespaceKey.self] = newValue }
    }
}

extension View {
    @ViewBuilder
    func presentationTransition(_ transition: PresentationTransition?, in namespace: Namespace.ID) -> some View {
        #if os(iOS)
        if #available(iOS 18, *), let transition {
            switch transition {
            case let .zoom(sourceID):
                navigationTransition(.zoom(sourceID: sourceID, in: namespace))
            }
        } else {
            self
        }
        #else
        self
        #endif
    }
}

private struct ZoomSourceModifier: ViewModifier {
    let id: AnyHashable
    @Environment(\.transitionNamespace) private var namespace

    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 18, *), let namespace {
            content.matchedTransitionSource(id: id, in: namespace)
        } else {
            content
        }
        #else
        content
        #endif
    }
}

public extension View {
    /// Marks this view as the source a `transition: .zoom(sourceID: id)` push
    /// or presentation zooms out of. Must sit inside the `RoutingView` (or
    /// `routerPresentations`) that shows the destination.
    func zoomSource(id: some Hashable) -> some View {
        modifier(ZoomSourceModifier(id: AnyHashable(id)))
    }
}
