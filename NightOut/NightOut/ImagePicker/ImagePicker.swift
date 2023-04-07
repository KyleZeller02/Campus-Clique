//
//  ImagePicker.swift
//  NightOut
//
//  Created by Kyle Zeller on 12/21/22.
//


//

import Foundation
import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable{
    @Binding var selectedImage: UIImage?
    @Binding var isPickerShowing: Bool
    
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let ImagePicker  = UIImagePickerController()
        ImagePicker.sourceType = .photoLibrary
        ImagePicker.delegate = context.coordinator
        return ImagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    
}


class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var parent: ImagePicker
    init(_ picker : ImagePicker){
        self.parent = picker
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // run code when user has cancled the picker ui
       print("cancled")
        parent.isPickerShowing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //run the code when the user has selected an image
        print("image selected")
        if let image =  info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            //we were able to get the image
            // we do not want to change view on a background thread, lets switch to main thread
            DispatchQueue.main.async {
                self.parent.selectedImage = image
            }
        }
        //dismiss the picker
        parent.isPickerShowing = false
    }
    
}

