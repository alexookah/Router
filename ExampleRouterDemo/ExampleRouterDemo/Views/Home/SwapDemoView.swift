//
//  SwapDemoView.swift
//  ExampleRouterDemo
//

import SwiftUI
import Router

/// Compares `replace`, which keeps the sheet and its detent, with a
/// re-present, which shows a new sheet. The controller's address is the tell.
struct SwapDemoView: View {
    let step: Int
    @Environment(AppRouter.self) private var router
    @State private var controller = "—"

    /// Kept by `replace`; a re-present must restate them.
    private let sheetOptions = SheetPresentationOptions(detents: [.medium, .large])

    var body: some View {
        List {
            Section {
                LabeledContent("Step", value: "\(step)")
                LabeledContent("Presented controller", value: controller)
                    .font(.caption.monospaced())
            }

            Section("Swap the content") {
                Button("replace(with:) — same identity") {
                    router.replace(with: .home(.swap(step + 1)))
                }
                Button("presentSheet — animated") {
                    router.presentSheet(route: .home(.swap(step + 1)), options: sheetOptions, target: .parent)
                }
            }

            Section {
                Button("Push a layer first") {
                    router.push(route: .home(.detail("swap \(step)")))
                }
            } footer: {
                Text("Push, then swap: a replaced sheet keeps its controller but gets a fresh stack.")
            }
        }
        .navigationTitle("Swap \(step)")
        .scrollContentBackground(.hidden)
        .background(Color(hue: Double(step % 6) / 6, saturation: 0.25, brightness: 1))
        .onAppear(perform: refresh)
        .task(id: step) {
            try? await Task.sleep(for: .seconds(0.6))
            refresh()
        }
    }

    private func refresh() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.keyWindow?.rootViewController else { return }
        var top = root
        while let presented = top.presentedViewController { top = presented }
        controller = String(describing: Unmanaged.passUnretained(top).toOpaque()).suffix(6).description
    }
}
