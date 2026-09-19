//
//  ShareSheetView.swift
//  ExampleRouterDemo
//

import SwiftUI

/// The system share sheet; its route skips the navigation stack, so it goes up bare.
struct ShareSheetView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}
