//
//  InAppViewModel.swift
//  Campus Clique
//
//  Created by Kyle Zeller on 6/4/23.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Firebase


class inAppViewVM: ObservableObject{
    @Published var postsForClass: [ClassPost] = []
    @Published var postsforUser: [ClassPost] = []
    @Published var userDoc: UserDocument = UserDocument(FirstName: "", LastName: "", College: "", Birthday: "", Major: "", Classes: [], Email: "", profilePictureURL: nil)
    @Published var curError: String = ""
    @Published var isVotingInProgress = false
    @Published var selectedClass: String = ""
    @Published var curReplies: [Reply] = []
    let firebaseManager = FirestoreService()
    let db = Firestore.firestore()
    
    
    
    init() {
//        isLoading = true
        self.getDocument { [weak self] doc, error in
            if error != nil {
                self?.curError = "There was an issue getting your profile. Please logout and log back in."
            }
            if let doc = doc {
                self?.userDoc = doc
                self?.selectedClass = self?.userDoc.Classes.first ?? ""
                self?.getPosts { completed in
                    if completed {
                        self?.getPostsForUser { completed in
                            if completed {
                                
//                                    self?.isLoading = false
                                
                               
                            }
                        }
                    }
                }
            }
        }
    }
    func getDocument(completion: @escaping (UserDocument?, Error?) -> Void) {
        firebaseManager.getDocument { doc, error in
            completion(doc, error)
        }
    }
    
    func getPosts(completion: @escaping (Bool) -> Void) {
        guard !self.selectedClass.isEmpty, !self.userDoc.College.isEmpty, Auth.auth().currentUser != nil else {
            if Auth.auth().currentUser == nil{
                self.curError = "You are not currently Authenticated. Log out and log back in."
            }
            else{
                self.curError = "Something went wrong getting your credentials. Log out and log back in."
            }
            return
        }
        
        
        firebaseManager.fetchPosts(fromClass: self.selectedClass, fromCollege: self.userDoc.College) { [weak self] (posts, error) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
               
                
                if let error = error {
                    self?.curError = "Something went wrong getting the posts for \(self?.selectedClass ?? "this class") : \(error)"
                    completion(false)
                    return
                }
                
                self?.postsForClass = posts ?? []
                completion(true)
            }
        }
    }

    
    
   
    
    
    
    
    func deletePostAndReplies(_ post: ClassPost) {
        firebaseManager.deletePostAndReplies(post) { success in
            if success {
                DispatchQueue.main.async {
                    if let index = self.postsForClass.firstIndex(where: { $0.id == post.id }) {
                        self.postsForClass.remove(at: index)
                    }
                    if let index = self.postsforUser.firstIndex(where: { $0.id == post.id }) {
                        self.postsforUser.remove(at: index)
                    }
                    self.objectWillChange.send()
                }
                print("Post and replies successfully deleted!")
            } else {
                self.curError = "Your post could not be deleted at this time."
            }
        }
    }
    
    
    
    func fetchReplies(forPost post: ClassPost) {
        firebaseManager.getReplies(forPost: post){replies in
            self.curReplies = replies
        }
    }
    
    
    
    
    
    
    func addReply(_ replyBody: String, to post: ClassPost, completion: @escaping (Result<Reply, Error>) -> Void) {
       
        guard !self.userDoc.FullName.isEmpty,
              !self.userDoc.Email.isEmpty else {
            return
        }
        
        firebaseManager.addReply(replyBody, to: post, author: self.userDoc.FullName, email: self.userDoc.Email, profilePictureURL: self.userDoc.profilePictureURL ?? "") { [weak self] result in
            switch result {
            case .success(let reply):
                //post.replies.append(reply)
                self?.objectWillChange.send()
                completion(.success(reply))
            case .failure(let error):
                print("Error adding reply: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    
    
    
    
    func addNewPost(_ postBody: String) {
       
        guard !self.userDoc.College.isEmpty,
              !self.userDoc.Email.isEmpty,
              !self.userDoc.FullName.isEmpty else {
            print("Error: Missing User Info")
            
            return
        }
        
        let selectedClass = self.selectedClass
        
        firebaseManager.addNewPost(author: self.userDoc.FullName, postBody: postBody, forClass: selectedClass, college: self.userDoc.College, email: self.userDoc.Email, profilePictureURL: self.userDoc.profilePictureURL ?? "") { result in
            if let result = result {
                let (postId, success) = result
                if success {
                    print("Post \(postId) added successfully.")
                    self.getPosts {_ in}
                    self.getPostsForUser(){_ in}
                } else {
                    self.curError = "Something went wrong publishing your post. Try Again"
                   
                }
            } else {
                self.curError = "Something went wrong publishing your post. Try Again"

            }
        }
    }

    
    
    func handleVoteOnPost(UpOrDown voteType: VoteType, onPost post: ClassPost) {
        guard let user = Auth.auth().currentUser else {
            return // Return if user is not logged in
        }
        isVotingInProgress = true
        firebaseManager.performAction(vote: voteType, post: post, user: user) { success, error in
            if success {
                // Fetch the updated post from Firestore
                self.firebaseManager.fetchPost(byId: post.id) { updatedPost, error in
                   
                    if let updatedPost = updatedPost {
                        DispatchQueue.main.async {
                            self.updatePostArrays(with: updatedPost)
                            self.isVotingInProgress = false
                            self.objectWillChange.send()
                        }
                    } else {
                        print(error?.localizedDescription ?? "Error fetching updated post.")
                    }
                }
            } else {
                // Handle error here
                print(error?.localizedDescription ?? "Error updating vote.")
            }
        }
    }
    

    
    private func updatePostArrays(with post: ClassPost) {
        if let index = postsForClass.firstIndex(where: { $0.id == post.id }) {
            postsForClass[index] = post
        }
        if let index = postsforUser.firstIndex(where: { $0.id == post.id }) {
            postsforUser[index] = post
        }
    }
    
    
    func handleVoteOnReply(_ vote: VoteType, onPost post: ClassPost, onReply reply: Reply) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            print("User is not authenticated.")
            return
        }
        self.isVotingInProgress = true
        firebaseManager.handleVoteOnReplyFirestore(UpOrDown: vote, post: post, reply: reply) { error in
            if let error = error {
                print("Error updating vote: \(error)")
                return
            }
          
            // Fetch the updated reply from Firestore
            self.firebaseManager.fetchReply(forPost: post, replyId: reply.id) { updatedReply, error in
                if let updatedReply = updatedReply {
                    DispatchQueue.main.async {
                        // Make sure to replace the `updateReplyArray(with:)` function with your own implementation
                        self.updateReplyArray(with: updatedReply)
                        self.isVotingInProgress = false
                        self.objectWillChange.send()
                       
                    }
                } else {
                    print(error?.localizedDescription ?? "Error fetching updated reply.")
                }
            }
        }
    }
    
    
    // Function to update the reply in the array
   private func updateReplyArray(with updatedReply: Reply) {
        if let index = self.curReplies.firstIndex(where: { $0.id == updatedReply.id }) {
            self.curReplies[index] = updatedReply
        }
    }
    
    
    func fetchUpdatedReply(_ reply: Reply, completion: @escaping (Reply?, Error?) -> Void) {
        let replyRef = db.collection("replies").document(reply.id)
        
        replyRef.getDocument { (document, error) in
            if let document = document, document.exists, let data = document.data() {
                // Try to create the updated reply object from the data
                if let reply = self.firebaseManager.createReplyFromData(data) {
                    // Reply creation succeeded
                    completion(reply, nil)
                } else {
                    // Reply creation failed
                    completion(nil, NSError(domain: "Reply data parsing error", code: 0))
                }
            } else if let error = error {
                // Error fetching document
                completion(nil, error)
            } else {
                // Document not found
                completion(nil, NSError(domain: "Reply document not found", code: 0))
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    func deleteReply(_ reply: Reply, fromPost post: ClassPost) {
        firebaseManager.deleteReply(reply, fromPost: post) { [weak self] result in
            switch result {
            case .success:
                // Update the local data after successful deletion
                if let index = self?.curReplies.firstIndex(where: { $0.id == reply.id }) {
                                self?.curReplies.remove(at: index)
                            }

                // Update any other necessary data
                self?.objectWillChange.send()
            case .failure(let error):
                print("Error deleting reply: \(error)")
            }
        }
    }
    
    func getPostsForUser(completion: @escaping (Bool) -> Void) {
        guard !self.userDoc.College.isEmpty else { return }
        //self.isLoadingPosts = true
        firebaseManager.getPostsForUser(college: self.userDoc.College, user: self.userDoc.Email) { [weak self] posts, error in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Adding 2 seconds delay
                //self?.isLoadingPosts = false
                
                if let error = error {
                    print("Error getting posts for user in UserProfileViewModel getPostsForUser(): \(error)")
                    self?.curError = "Something went wrong getting your posts. Close the app and try again."
                    completion(false)
                    return
                }

                self?.postsforUser = posts ?? []
                completion(true)
            }
        }
    }

    
    func handleEdit(newCollege: String, newClasses: [String], newMajor:String) -> String? {
        guard !newCollege.isEmpty,
              !self.userDoc.Email.isEmpty else {
            return "Edit could not be done. Log out and log back in."
        }

            var returnedError: String? = nil
            // Get reference to location in Firebase
            let userDocLocation = db.collection("Users").document(self.userDoc.Email)
    
            // Create a dictionary to store updated field values
            var updatedFields: [String: Any] = [:]
    
            // Update field values if they are different from current values
        if newCollege != self.userDoc.College {
                updatedFields["College"] = newCollege
    
                // Delete user's posts from the old college
            let oldCollege = self.userDoc.College
            let email = self.userDoc.Email
    
                firebaseManager.deletePostsAndRepliesOfUserFromCollege(fromCollege: oldCollege, userEmail: email) { success, error in
                    if error != nil {
                        // Handle the error
                        returnedError = "Posts could not be deleted from old college."
                    } else {
                        if !success {
                            // Deletion unsuccessful
                            returnedError = "Posts could not be deleted from old college."
                        }
                    }
                }
            }
        if newMajor != self.userDoc.Major{
                updatedFields["Major"] = newMajor
            }
            var deletedClasses: [String] = []
        let curUserClasses = self.userDoc.Classes
    
                for c in curUserClasses {
                    if !newClasses.contains(c) {
                        deletedClasses.append(c)
                    }
                }
                // Use the deletedClasses array as needed
            
    
            if deletedClasses.count > 0{
                firebaseManager.deleteUsersPostAndRepliesFromClass(fromClasses: deletedClasses,email: self.userDoc.Email, college: self.userDoc.College) { success, error in
                    if error != nil {
                        // Handle the error
                        returnedError = "Posts could not be deleted."
    
                    } else {
                        if !success {
                            // Deletion unsuccessful
                            returnedError = "Posts could not be deleted."
                        }
                    }
                }
            }
    
    
            if let returnedError = returnedError{
                return returnedError
            }
            updatedFields["Classes"] = newClasses
    
    
            // Update values in Firebase if there are any changes
            if !updatedFields.isEmpty {
                userDocLocation.setData(updatedFields, merge: true)
            }
    
            // Update local user document
        self.userDoc.College = newCollege
        self.userDoc.Classes = newClasses
        self.userDoc.Major = newMajor
    
            // Send objectWillChange notification
            objectWillChange.send()
            return nil
        }
    
    
}
