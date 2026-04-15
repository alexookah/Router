import SwiftUI
import Router

struct EditProfileView: View {
    @Environment(Router<AppRoute>.self) var router

    var body: some View {
        List {
            Section("Edit Profile") {
                Text("This is presented as a full-screen cover.")
                Text("The dismiss button is on the right (dismissButtonPosition: .right).")
            }

            Section("Actions") {
                Button("Save & Dismiss") {
                    router.dismissSelf()
                }
                Button("Dismiss All From Root") {
                    router.dismissAllFromRoot()
                }
            }
        }
        .navigationTitle("Edit Profile")
    }
}
