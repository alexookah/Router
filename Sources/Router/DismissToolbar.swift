import SwiftUI

#if os(iOS)
struct DismissToolbar: ToolbarContent {
    let dismissOptions: DismissButtonPresentationOptions
    let dismissAction: () -> Void

    var body: some ToolbarContent {
        if dismissOptions.dismissButtonPosition == .left {
            ToolbarItem(placement: .topBarLeading) {
                dismissButton
            }
        } else {
            ToolbarItem(placement: .topBarTrailing) {
                dismissButton
            }
        }
    }

    private var dismissButton: some View {
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
#endif
