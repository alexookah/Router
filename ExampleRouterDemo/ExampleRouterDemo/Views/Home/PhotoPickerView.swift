//
//  PhotoPickerView.swift
//  ExampleRouterDemo
//

import PhotosUI
import Router
import SwiftUI

/// The system photo picker; its route skips the navigation stack, so it goes up bare.
struct PhotoPickerView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        PhotoPickerRepresentable { router.dismiss() }
            .ignoresSafeArea()
    }
}

private struct PhotoPickerRepresentable: UIViewControllerRepresentable {
    let onFinish: () -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_: PHPickerViewController, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onFinish: onFinish)
    }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onFinish: () -> Void
        init(onFinish: @escaping () -> Void) {
            self.onFinish = onFinish
        }

        func picker(_: PHPickerViewController, didFinishPicking _: [PHPickerResult]) {
            onFinish()
        }
    }
}
