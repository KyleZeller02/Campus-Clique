//
//  DatabaseFetcher:Sender.swift
//  NightOut
//
//  Created by Kyle Zeller on 1/4/23.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

struct OnboardingDatabaseManager {
    /// this method is called on LoginView to create a new document with the inputed email, then generate a document id, and set that id in the document
    /// - Parameter email: the email address given by the user
    static func addDocumentWithEmail(email:String){
        
        let db = Firestore.firestore()
        let docRef = db.collection("Users").document(email)
        
        docRef.getDocument{ (document, error) in
            // this check may be redundant since the login method also only allows signup with one email.
            if let document = document, document.exists{
                //the document exists
            }
            else{
                //add it to the database
                db.collection("Users").document(email).setData(["Email": email], merge: true)
            }
            
        }
    }
    
    
    /// this method will add fields for the users first name, last name, and college to the  document in the "Users" collection in the Firestore Data
    /// - Parameters:
    ///   - firstName: the first name. This will never be null or empty string.
    ///   - lastName: the last name. This will never be null or empty string.
    ///   - college: the college. This will never be null or empty string.
    ///   - email: the email associated with the user. this is set when the user presses the signup button on the LoginView. This is found in the Settings file.
    static func addFirstLastCollegeToDocument(firstName:String, lastName:String, college:String, email:String){
        //get reference to database
        let db = Firestore.firestore()
        // get refernce to the current users document
        let docRef = db.collection("Users").document(email)
        // sets the fields and merges with current data in the document, so as not to overwrite existing data
        docRef.setData(["FirstName": firstName, "LastName": lastName, "College": college],merge: true)
        
    }
    
    
    /// this method adds fields for classes and major(s) to the document in the "Users" collection in the Firestore Data
    /// - Parameters:
    ///   - Classes: the classes input from the user. this is input as a string, but is parsed to a string array
    ///   - Major: the major or majors input from the user. this is input as a string, but is parsed to a string array.
    ///   - email: the email associated with the user. this is set when the user presses the signup button on the LoginView. This is found in the Settings file.
    static func addClassesMajorToDocument(Classes: String, Major: String, email: String) {
        // get reference to database
        let db = Firestore.firestore()
        
        // get reference to the document for the user
        let docRef = db.collection("Users").document(email)
        
        // convert classes to array
        let classesArray = Classes.split(separator: ",")
        let trimmedClasses = classesArray.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        // Major is a string, no need to split or map.
        
        // add fields, while keeping existing data
        docRef.setData(["Classes": trimmedClasses, "Major": Major], merge: true)
    }

    
    
    /// this method adds a field for the user's Birthday to the document in the "Users" collection in the Firestore Data
    /// - Parameters:
    ///   - birthday: the birthday given by user
    ///   - email: the email associated with the user. this is set when the user presses the signup button on the LoginView. This is found in the Settings file.
    static func addBirthdayToDocument(birthday:String, email:String){
        //get reference to the database
        let db = Firestore.firestore()
        //get reference to the document for the current user
        let docRef = db.collection("Users").document(email)
        //add fields, while keeping existing data
        docRef.setData(["Birthday" : birthday],merge: true)
        
        
    }
    
   
    
    static func uploadProfileImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> ()) {

        let fixedImage = image.fixedOrientation()

        guard let imageData = fixedImage.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Couldn't convert image to data"])))
            return
        }

        let imageName = UUID().uuidString
        let imageReference = Storage.storage().reference().child("profileImages/\(imageName)")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        imageReference.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                return completion(.failure(error))
            }

            imageReference.downloadURL { url, error in
                if let error = error {
                    return completion(.failure(error))
                }

                guard let url = url else {
                    return completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Couldn't retrieve URL"])))
                }

                // Return the URL as a string without updating the Firestore
                completion(.success(url.absoluteString))
            }
        }
    }


    
}

extension UIImage {
    func fixedOrientation() -> UIImage {
        
        if imageOrientation == .up {
            return self
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
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
        
        let ctx: CGContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage!.bitsPerComponent, bytesPerRow: 0, space: cgImage!.colorSpace!, bitmapInfo: cgImage!.bitmapInfo.rawValue)!
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        
        let cgImage: CGImage = ctx.makeImage()!
        
        return UIImage(cgImage: cgImage)
    }
}





