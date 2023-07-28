//
//  DatabaseFetcherSender.swift
//  NightOut
//
//  Created by Kyle Zeller on 1/4/23.
//

// Import necessary modules
import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

// This struct is responsible for interacting with the Firebase database for onboarding related tasks.
struct OnboardingDatabaseManager {
    
    // This function uploads an image to Firebase storage and returns the URL of the uploaded image.
    static func uploadProfileImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> ()) {

        // Fixes the orientation of the image (in case it was taken on an iPhone in landscape mode, for example)
        let fixedImage = image.fixedOrientation()

        // Convert the image to JPEG data so that it can be uploaded.
        guard let imageData = fixedImage.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Couldn't convert image to data"])))
            return
        }

        // Generate a unique name for the image file.
        let imageName = UUID().uuidString

        // Create a reference to the file location in Firebase storage.
        let imageReference = Storage.storage().reference().child("profileImages/\(imageName)")

        // Set the metadata for the image.
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        // Upload the image data to Firebase.
        imageReference.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                return completion(.failure(error))
            }

            // Retrieve the download URL of the image.
            imageReference.downloadURL { url, error in
                if let error = error {
                    return completion(.failure(error))
                }

                guard let url = url else {
                    return completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Couldn't retrieve URL"])))
                }

                // Return the URL as a string.
                completion(.success(url.absoluteString))
            }
        }
    }
}

// This extension adds a function to the UIImage class that fixes the orientation of the image.
extension UIImage {
    func fixedOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        // Define the transform for each case of image orientation.
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -(CGFloat.pi / 2))
        case .up, .upMirrored:
            break
        @unknown default:
            fatalError("Unknown image orientation")
        }
        
        // Create a new image context and apply the transform.
        let ctx: CGContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage!.bitsPerComponent, bytesPerRow: 0, space: cgImage!.colorSpace!, bitmapInfo: cgImage!.bitmapInfo.rawValue)!
        
        ctx.concatenate(transform)
        
        // Draw the image to the context.
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        
        // Get the image from the context.
        let cgImage: CGImage = ctx.makeImage()!
        
        // Return the new image.
        return UIImage(cgImage: cgImage)
    }
}





