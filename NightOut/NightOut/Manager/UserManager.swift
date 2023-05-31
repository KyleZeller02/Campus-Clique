//  UserManager.swift
//  Campus Clique
//
//  Created by Kyle Zeller on 5/29/23.
//

import Foundation
import Firebase

class UserManager: ObservableObject {
    static let shared = UserManager()
    let db = Firestore.firestore()

    @Published var currentUser: UserDocument?

    private init() {
        getCurrentUserDocument()
        
    }
    func initializeUser(completion: @escaping ((UserDocument?) -> Void)) {
            let user = getCurrentUserEmail()
            getDocument(user: user) { userDocument in
                guard let userDocument = userDocument else {
                    // Handle the error or incomplete data here if needed
                    completion(nil)
                    return
                }
                self.currentUser = userDocument
                completion(userDocument)
            }
        }
    private func getCurrentUserEmail() -> String {
        let currentUser = Auth.auth().currentUser
        return currentUser?.email ?? ""
    }

     func getCurrentUserDocument() {
        let user = getCurrentUserEmail()
        getDocument(user: user) { [weak self] userDocument in
            guard let userDocument = userDocument else {
                // Handle the error or incomplete data here if needed
                return
            }
            self?.currentUser = userDocument
        }
    }

    func getDocument(user: String, completion: @escaping (UserDocument?) -> Void) {
        guard !user.isEmpty else {
            completion(nil)
            return
        }
        let doc = db.collection("Users").document(user)

        doc.getDocument { documentSnapshot, error in
            if let error = error {
                print("Error fetching document: \(error)")
                completion(nil)
                return
            }

            guard let data = documentSnapshot?.data(),
                let firstName = data["FirstName"] as? String,
                let lastName = data["LastName"] as? String,
                let college = data["College"] as? String,
                let birthday = data["Birthday"] as? String,
                let major = data["Major"] as? String,
                let classes = data["Classes"] as? [String],
                let email = data["Email"] as? String,
                let profilePictureURL = data["profile_picture"] as? String
            else {
                print("Invalid document data or missing fields")
                completion(nil)
                return
            }

            var retrievedDoc = UserDocument(FirstName: firstName, LastName: lastName, College: college, Birthday: birthday, Major: major, Classes: classes, Email: email)

            self.downloadImage(from: profilePictureURL) { image in
                retrievedDoc.profilePicture = image
                completion(retrievedDoc)
            }
        }
    }

    func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            return completion(nil)
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else {
                return completion(nil)
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }

    
    
    func handleEdit(college: String, classes: [String]) {
        guard !college.isEmpty else {
            return
        }
        
        // Get reference to location in Firebase
        let userDocLocation = db.collection("Users").document(UserManager.shared.currentUser?.Email ?? "")
        
        // Create a dictionary to store updated field values
        var updatedFields: [String: Any] = [:]
        
        // Update field values if they are different from current values
        if college != UserManager.shared.currentUser?.College {
            updatedFields["College"] = college
        }
        if !classes.elementsEqual(UserManager.shared.currentUser?.Classes ?? []) {
            updatedFields["Classes"] = classes
        }
        
        // Update values in Firebase if there are any changes
        if !updatedFields.isEmpty {
            userDocLocation.setData(updatedFields, merge: true)
        }
        
        // Update local user document
        UserManager.shared.currentUser?.College = college
        UserManager.shared.currentUser?.Classes = classes
        
        // Send objectWillChange notification
        objectWillChange.send()
    }
}
