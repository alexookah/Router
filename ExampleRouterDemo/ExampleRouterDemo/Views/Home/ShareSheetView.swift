//
//  ShareSheetView.swift
//  ExampleRouterDemo
//

import SwiftUI

/// The system share sheet; its route owns its navigation, so it goes up bare.
struct ShareSheetView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
