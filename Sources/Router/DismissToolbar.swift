import SwiftUI

struct DismissToolbar: ToolbarContent {
    let dismissOptions: DismissButtonPresentationOptions
    let dismissAction: () -> Void

    var body: some ToolbarContent {
        #if os(iOS)
        ToolbarItem(placement: dismissOptions.dismissButtonPosition == .left ? .topBarLeading : .topBarTrailing) {
            dismissButton
        }
        #else
        // macOS: use the semantic cancellation slot; the platform picks the native location
        ToolbarItem(placement: .cancellationAction) {
            dismissButton
        }
        #endif
    }

    @ViewBuilder
    private var dismissButton: some View {
        #if os(iOS)
        if #available(iOS 26, *) {
            Button(role: .close, action: dismissAction)
        } else {
            customCloseButton
        }
        #else
        customCloseButton
        #endif
    }

    private var customCloseButton: some View {
        Button {
            dismissAction()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.secondary)
                .padding(6)
                .background(.ultraThinMaterial, in: Circle())
        }
    }
}
