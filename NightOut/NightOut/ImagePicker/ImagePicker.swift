//  ImagePicker.swift
//  NightOut
//
//  Created by Kyle Zeller on 12/21/22.
//
// This SwiftUI component represents an image picker interface
// where users can choose images from their photo library.

import Foundation
import SwiftUI
import UIKit

// The ImagePicker struct conforms to UIViewControllerRepresentable protocol
// which allows it to bridge a UIKit view controller for use inside of SwiftUI's view hierarchy.
struct ImagePicker: UIViewControllerRepresentable {
    // Binding variables that will be updated and observed for changes
    @Binding var selectedImage: UIImage?
    @Binding var isPickerShowing: Bool

    // Method to create and configure an image picker controller.
    func makeUIViewController(context: Context) -> some UIViewController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    // Method to update the image picker controller.
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // No need to update anything here since it's handled in the Coordinator.
    }

    // Method to create a coordinator that handles delegation from the image picker controller.
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}

// A Coordinator class that acts as a bridge for the ImagePicker to be its delegate.
class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var parent: ImagePicker

    init(_ picker: ImagePicker) {
        self.parent = picker
    }

    // Method called when the user cancels the picker.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Picker was canceled")
        parent.isPickerShowing = false
    }

    // Method called when the user selects an image.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Image was selected")
        if let image =  info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // Image selection is made on a background thread, switch to main thread to update UI.
            DispatchQueue.main.async {
                self.parent.selectedImage = image
            }
        }
        // After image selection, the picker is dismissed.
        parent.isPickerShowing = false
    }
}
