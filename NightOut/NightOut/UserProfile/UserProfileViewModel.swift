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
    private var listener: ListenerRegistration?
    
    
    func getPostsForUser(for user: String, completion: @escaping ([ClassPost]) -> ()) {
        self.usersPosts.removeAll()
        var posts: [ClassPost] = []
        let college = userDocument.College
        let path = db.collection("Colleges").document(college)
        let classes: [String] = userDocument.Classes ?? []
        
        for c in classes {
            let fullPath = path.collection(c)
            let query = fullPath.whereField("email", isEqualTo: user)
            
            query.getDocuments { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error getting documents in getPostsForUser(): \(error?.localizedDescription ?? "")")
                    return
                }
                
                documents.forEach { document in
                    
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
                    let college = data["college"] as? String ?? ""
                    
                    let post = ClassPost(
                        postBody: postBody,
                        postAuthor: author,
                        forClass: forClass,
                        datePosted: date,
                        votes: votes,
                        id: id,
                        usersLiked: Set(usersLiked),
                        usersDisliked: Set(usersDisliked),
                        email: email,
                        college: college
                    )
                    posts.append(post)
                }
                //this needs to be fixed by creating an index in firebase. this is a lazy fix for now:
               
                completion(posts)
                self.objectWillChange.send()
            }
        }
        self.sortUsersPost()
    }

   
    
    func getReplies(forPost post: ClassPost, inClass c:String, completion: @escaping ([Replies]) -> ()) {
        post.replies.removeAll()

        let college: String = self.userDocument.College
        let postLocation = db.collection("Colleges").document(college).collection(c).document(post.id).collection("Replies")

        postLocation.order(by: "date", descending: false).addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Something went wrong getting replies on post from Firebase: \(err.localizedDescription)")
                completion([])
            } else {
                var tempReplies: [Replies] = []

                for document in querySnapshot!.documents {
                    let data = document.data()
                    let author = data["author"] as? String ?? ""
                   
                    let id = data["id"] as? String ?? ""
                    let postBody = data["postBody"] as? String ?? ""
                    let votes = data["votes"] as? Int64 ?? 0
                    let usersLiked = data["UsersLiked"] as? [String] ?? []
                    let usersDisliked = data["UsersDisliked"] as? [String] ?? []
                    let date = data["datePosted"] as? Double ?? 0.0
                    let reply = Replies(replyBody: postBody, replyAuthor: author,  DatePosted: date, votes: votes, id: id, usersLiked: Set(usersLiked), usersDisliked: Set(usersDisliked))
                    tempReplies.append(reply)
                }

                completion(tempReplies)
            }
        }
    }



    
    func getDocument(user: String, completion: @escaping ((UserDocument) -> ())) {
        let doc = db.collection("Users").document(user)
        
        doc.getDocument { documentSnapshot, error in
            if let error = error {
                print("Error fetching document: \(error)")
                completion(UserDocument(FirstName: "", LastName: "", College: "", Birthday: "", Major: [], Classes: [], Email: ""))
                return
            }
            
            guard let data = documentSnapshot?.data(),
                  let firstName = data["FirstName"] as? String,
                  let lastName = data["LastName"] as? String,
                  let college = data["College"] as? String,
                  let birthday = data["Birthday"] as? String,
                  let major = data["Major"] as? [String],
                  let classes = data["Classes"] as? [String],
                  let email = data["Email"] as? String
            else {
                print("Invalid document data or missing fields")
                completion(UserDocument(FirstName: "", LastName: "", College: "", Birthday: "", Major: [], Classes: [], Email: ""))
                return
            }
            
            let retrievedDoc = UserDocument(FirstName: firstName, LastName: lastName, College: college, Birthday: birthday, Major: major, Classes: classes, Email: email)
            completion(retrievedDoc)
        }
    }



    
    func handleEdit(college: String, classes: [String]) {
        // Get reference to location in Firebase
        let userDocLocation = db.collection("Users").document(userDocument.Email)

        // Create a dictionary to store updated field values
        var updatedFields: [String: Any] = [:]

        // Update field values if they are different from current values
        if college != userDocument.College {
            updatedFields["College"] = college
        }
        if !classes.elementsEqual(userDocument.Classes ?? []) {
            updatedFields["Classes"] = classes
        }

        // Update values in Firebase if there are any changes
        if !updatedFields.isEmpty {
            userDocLocation.setData(updatedFields, merge: true)
        }

        // Update local user document
        userDocument.College = college
        userDocument.Classes = classes

        // Send objectWillChange notification
        objectWillChange.send()
    }
 
    func refresh() {
        guard let userEmail = Auth.auth().currentUser?.email else {
            return
        }
        
        if userEmail == userDocument.Email {
            getPostsForUser(for: userDocument.Email) { posts in
                self.usersPosts = posts
                self.sortUsersPost()
            }
        }
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
