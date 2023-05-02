//
//  UserProfileViewMode.swift
//  NightOut
//
//  Created by Kyle Zeller on 1/10/23.
//

import SwiftUI
import Firebase

class UserProfileViewModel: ObservableObject{
    
    @Published var userDocument: UserDocument = UserDocument(FirstName: "Default", LastName: "", College: "", Birthday: "", Major: [], Classes: [], Email: "")
    
    @Published var usersPosts: [ClassPost] = []
    
    
    
    
    let db = Firestore.firestore()
   
    
    func getPostsForUser(for user: String, completion: @escaping(([ClassPost]) -> ())) {
        self.usersPosts.removeAll()
        var posts: [ClassPost] = []
        let g = DispatchGroup()
        
        let college = userDocument.College
        let path = db.collection("Colleges").document(college)
        let classes: [String] = userDocument.Classes ?? []
        
        for c in classes {
            let fullPath = path.collection(c)
            g.enter()
            fullPath.whereField("email", isEqualTo: user).getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents in getPostsForUser() in userprofileVM: \(err.localizedDescription)")
                } else {
                    let documents = querySnapshot?.documents ?? []
                    let dispatchGroup = DispatchGroup()
                    for document in documents {
                        dispatchGroup.enter()
                        let data = document.data()
                        let author = data["author"] as? String ?? ""
                        let postBody = data["postBody"] as? String ?? ""
                        let forClass = data["forClass"] as? String ?? ""
                        let date = data["datePosted"] as? Double ?? 0.0
                        let votes = data["votes"] as? Int64 ?? 0
                        let id = data["id"] as? String ?? ""
                        let usersLiked = data["UsersLiked"] as? [String] ?? []
                        let usersDisliked = data["UsersDisliked"] as? [String] ?? []
                        let email = data["email"] as? String ?? ""
                        let post = ClassPost(postBody: postBody, postAuthor: author, forClass: forClass, DatePosted: date, votes:votes, id: id,usersLiked: Set(usersLiked), usersDisliked: Set(usersDisliked),email: email)
                        posts.append(post)
                        dispatchGroup.leave()
                    }
                    dispatchGroup.notify(queue: .main) {
                        g.leave()
                    }
                }
            }
        }
        
        g.notify(queue:.main) {
            completion(posts)
            self.objectWillChange.send()
        }
    }

    
    func getDocument(user: String, completion: @escaping ((UserDocument) -> ())) {
        let doc = db.collection("Users").document(user)
        doc.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let firstName = data?["FirstName"] as? String ?? ""
                let lastName = data?["LastName"] as? String ?? ""
                let college = data?["College"] as? String ?? ""
                let birthday = data?["Birthday"] as? String ?? ""
                let major = data?["Major"] as? [String] ?? []
                let classes = data?["Classes"] as? [String] ?? []
                let email = data?["Email"] as? String ?? ""
                let retrievedDoc = UserDocument(FirstName: firstName, LastName: lastName, College: college, Birthday: birthday, Major: major, Classes: classes, Email: email)
                completion(retrievedDoc)
            } else {
                print("Document does not exist")
                completion(UserDocument(FirstName: "", LastName: "", College: "", Birthday: "", Major: [], Classes: [], Email: ""))
            }
        }
    }

    
    func handleEdit(firstName: String, lastName: String, college: String, birthday: String, major: String, classes: [String]) {
        // Get reference to location in Firebase
        let userDocLocation = db.collection("Users").document(userDocument.Email)

        // Create a dictionary to store updated field values
        var updatedFields: [String: Any] = [:]

        // Update field values if they are different from current values
        if firstName != userDocument.FirstName {
            updatedFields["FirstName"] = firstName
        }
        if lastName != userDocument.LastName {
            updatedFields["LastName"] = lastName
        }
        if college != userDocument.College {
            updatedFields["College"] = college
        }
        let majorArr = parseMajor(major: major)
        if !majorArr.elementsEqual(userDocument.Major) {
            updatedFields["Major"] = majorArr
        }
        if !classes.elementsEqual(userDocument.Classes ?? []) {
            updatedFields["Classes"] = classes
        }
        if birthday != userDocument.Birthday {
            updatedFields["Birthday"] = birthday
        }

        // Update values in Firebase if there are any changes
        if !updatedFields.isEmpty {
            userDocLocation.setData(updatedFields, merge: true)
        }

        // Update local user document
        userDocument = UserDocument(FirstName: firstName, LastName: lastName, College: college, Birthday: birthday, Major: majorArr, Classes: classes, Email: userDocument.Email)

        // Send objectWillChange notification
        objectWillChange.send()
    }

    
    init() {
        let curUser = self.CurUser()
        self.getDocument(user: curUser) { [weak self] retrieved in
            guard let self = self else { return } // Add weak self capture list to avoid retain cycle
            self.userDocument = retrieved
            self.getPostsForUser(for: curUser) { posts in
                self.usersPosts = posts
                self.sortUsersPost()
            }
        }

        if let classes = self.userDocument.Classes {
            self.userDocument.Classes = classes.sorted() // Sort classes in place
        }

        
    }
    
    private func parseMajor(major: String) -> [String]{
        return major.components(separatedBy: ",")
    }
    
     func CurUser() -> String{
        let curUser =  Auth.auth().currentUser
        if let curUser = curUser{
            return curUser.email ?? ""
        }
        return ""
    }
    
     func sortUsersPost(){
        self.usersPosts.sort(by: {$0.votes > $1.votes})
    }
}
