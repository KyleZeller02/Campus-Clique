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
                db.collection("Users").document(email).setData(["Email": email])
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
    static func addClassesMajorToDocument(Classes:String,Major:String, email:String){
        //get reference to database
        let db = Firestore.firestore()
        //get reference to the document for the user
        let docRef = db.collection("Users").document(email)
        // convert classes and major to arrays
        let classesArray = Classes.split(separator: ",")
        let trimmedClasses = classesArray.map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}
        let majorArray = Major.split(separator: ",")
        let trimmedMajor = majorArray.map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}
        
        //add fields, while keeping existing data
        docRef.setData(["Classes": trimmedClasses, "Major": trimmedMajor],merge: true)
        
        
        
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
    
    
    /// this method uplaods a profile picture url to Fireabse Storage, and adds a field to user document in "Users" with a url to the photo in storage
    /// - Parameter selectedImage: the selected image. this should not ever be null, but the guard statement is just in case
   static func addProfilePhotoToDocument(selectedImage: UIImage?){
        //check to make sure the image passed in is not nil
        guard selectedImage != nil else{
            return
        }
        // get reference to the firebase storage
        let storageRef = Storage.storage().reference()
        // get the data from the image and compress it
        let imageData = selectedImage!.jpegData(compressionQuality: 0.8)
        // guard to make sure we were able to parse the data from the image
        //if we were unable to,we return from the function
        guard imageData != nil else{return}
        //the path of the image. this is the value for the field that we upload
        let path = "Images/\(UUID().uuidString).jpg"
        let fileRef =  storageRef.child("images/\(UUID().uuidString).jpg")
        //here we upload the photo
        let uploadTask = fileRef.putData(imageData!, metadata: nil){
            metadata, error in
            // if there was no error and we have the meta data,
            if error == nil && metadata != nil{
                //get refernce to the firebase
                let db = Firestore.firestore()
                //the static email var that is found in Settings
                let email = Settings.Email
                //get reference to the document for the user in "Users"
                let docRef = db.collection("Users").document(email)
                //add a field with the url string and add it to the document, while keeping existing data in the document
                docRef.setData(["ProfilePhotoURL" : path],merge: true)
            }
        }
    }
    
}




