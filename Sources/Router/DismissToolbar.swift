import SwiftUI

struct DismissToolbar: ToolbarContent {
    let dismissOptions: DismissButtonPresentationOptions
    let dismissAction: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: dismissOptions.dismissButtonPosition == .left ? .topBarLeading : .topBarTrailing) {
            dismissButton
        }
    }

    @ViewBuilder
    private var dismissButton: some View {
        if #available(iOS 26, *) {
            Button(role: .close, action: dismissAction)
        } else {
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
}
