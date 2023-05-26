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
    
    static func addDefaultData(email: String){
        let db = Firestore.firestore()
        let docRef = db.collection("Users").document(email)

        // Set default data for the user
        let defaultData: [String: Any] = [
            "FirstName": "FirstName",
            "LastName": "LastName",
            "College": "Kansas State University",
            "Classes": ["MATH100"],
            "Major": ["Math"],
            "Birthday": "01/01/2000"
        ]

        // setData for each field, merging so existing data is not overwritten
        docRef.setData(defaultData, merge: true)
    }

    
    
    
    
}




