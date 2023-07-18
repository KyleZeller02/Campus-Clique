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
import Kingfisher

class inAppViewVM: ObservableObject{
    @Published var postsForClass: [ClassPost] = []
    @Published var postsforUser: [ClassPost] = []
    @Published var userDoc: UserDocument = UserDocument(FirstName: "", LastName: "", College: "",  Major: "", Classes: [], Email: "", profilePictureURL: nil)
    @Published var curError: String = ""
    @Published var isVotingInProgress = false
    @Published var selectedClass: String = ""
    @Published var curReplies: [Reply] = []
    let firebaseManager = FirestoreService()
    let db = Firestore.firestore()
    var lastDocumentSnapshot: DocumentSnapshot?
        var isLastPage: Bool = false
    @Published var canRefresh: Bool = true
    
    
    
    init() {
//        isLoading = true
        self.getDocument { [weak self] doc, error in
            if error != nil {
                self?.curError = "There was an issue getting your profile. Please logout and log back in."
            }
            if let doc = doc {
                self?.userDoc = doc
                self?.userDoc.Classes.sort()
                self?.selectedClass = self?.userDoc.Classes.first ?? ""
                self?.fetchFirst30PostsForClass() { completed in
                    print("There are \(self?.postsForClass.count) posts")
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
    
    
    
    func fetchNext30PostsForClass(completion: @escaping (Bool) -> Void) {
            guard !self.selectedClass.isEmpty, !self.userDoc.College.isEmpty, Auth.auth().currentUser != nil else {
                if Auth.auth().currentUser == nil{
                    self.curError = "You are not currently Authenticated. Log out and log back in."
                }
                else{
                    self.curError = "Something went wrong getting your credentials. Log out and log back in."
                }
                return
            }
            
            if isLastPage { return }  // Return if there is no more data to fetch
            
            firebaseManager.fetchNext30PostsForClass(fromClass: self.selectedClass, fromCollege: self.userDoc.College, after: lastDocumentSnapshot) { [weak self] (posts, lastSnapshot, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.curError = "Something went wrong getting the posts for \(self?.selectedClass ?? "this class") : \(error)"
                        completion(false)
                        return
                    }
                    if self?.lastDocumentSnapshot == nil{
                        self?.postsForClass = posts ?? []
                    }
                    else{
                        self?.postsForClass += posts ?? []
                    }
                   
                    self?.lastDocumentSnapshot = lastSnapshot
                    
                    if posts?.count ?? 0 < 30 {
                        self?.isLastPage = true
                    }
                    
                    completion(true)
                }
            }
        }
    func refreshPosts(completion: @escaping (Bool) -> Void) {
        if canRefresh{
            canRefresh = false
            self.lastDocumentSnapshot = nil
            self.isLastPage = false
            
            
            fetchFirst30PostsForClass(completion: completion)
            canRefresh = true
        }
        
        self.getPostsForUser(){_ in}
       
    }
    func fetchFirst30PostsForClass(completion: @escaping (Bool) -> Void) {
        guard !self.selectedClass.isEmpty, !self.userDoc.College.isEmpty, Auth.auth().currentUser != nil else {
            if Auth.auth().currentUser == nil {
                self.curError = "You are not currently Authenticated. Log out and log back in."
            } else {
                self.curError = "Something went wrong getting your credentials. Log out and log back in."
            }
            return
        }
        
        firebaseManager.fetchFirst30PostsForClass(fromClass: self.selectedClass, fromCollege: self.userDoc.College) { [weak self] (posts, lastSnapshot, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.curError = "Something went wrong getting the posts for \(self?.selectedClass ?? "this class") : \(error)"
                    completion(false)
                    return
                }
                
                self?.postsForClass = posts ?? []
                self?.lastDocumentSnapshot = lastSnapshot
                
                if posts?.count ?? 0 < 30 {
                    self?.isLastPage = true
                }
                
                completion(true)
            }
        }
    }


    
    
    func removeAllPostsFromUser(){
        firebaseManager.deletePostsAndRepliesOfUser(userEmail: self.userDoc.Email) { (success, error) in
            if success {
                print("Successfully deleted all posts and replies for the user.")
                // Update your UI or take further actions here.
            } else if let error = error {
                print("An error occurred while deleting posts and replies: \(error.localizedDescription)")
                // Handle the error here, perhaps by notifying the user of the problem.
            }
        }
    }

    
    
    
    
    func deletePostAndReplies(_ post: ClassPost) {
        firebaseManager.deletePostAndItsReplies(post) { success in
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
        
        firebaseManager.addNewPost(author: self.userDoc.FullName, postBody: postBody, forClass: selectedClass, college: self.userDoc.College, email: self.userDoc.Email, profilePictureURL: self.userDoc.profilePictureURL ?? "") { post, error in
            if let error = error {
                print("Error adding new post: \(error)")
                self.curError = "Something went wrong publishing your post. Try Again"
            } else if let post = post {
                DispatchQueue.main.async{
                    self.postsForClass.insert(post, at: 0)
                }
               
                
                self.getPostsForUser(){_ in}
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

    //this method needs to be abstracted and modulated more
    func handleEdit(newCollege: String, newClasses: [String], newMajor: String, newFirstName: String, newLastName: String, newProfilePicture: UIImage?, didEditPhoto:Bool) -> String? {
        guard !newCollege.isEmpty, !self.userDoc.Email.isEmpty else {
            return "Edit could not be done. Log out and log back in."
        }

        var returnedError: String? = nil
        let userDocLocation = db.collection("Users").document(self.userDoc.Email)
        var updatedFields: [String: Any] = [:]

        if newCollege != self.userDoc.College {
            updatedFields["college"] = newCollege
            let oldCollege = self.userDoc.College
            let email = self.userDoc.Email
            // if college has changed: delete all posts made by that user in that college, as well as its replies. delete all replies made from that user
            firebaseManager.deletePostsAndRepliesOfUserFromCollege(fromCollege: oldCollege, userEmail: email) { success, error in
                if error != nil {
                    returnedError = "Posts could not be deleted from old college."
                } else {
                    if !success {
                        returnedError = "Posts could not be deleted from old college."
                    }
                }
            }
        }

        if newMajor != self.userDoc.Major {
            updatedFields["major"] = newMajor
        }

        if newFirstName != self.userDoc.FirstName {
            updatedFields["first_name"] = newFirstName
        }

        if newLastName != self.userDoc.LastName {
            updatedFields["last_name"] = newLastName
        }

        var deletedClasses: [String] = []
        let curUserClasses = self.userDoc.Classes

        for c in curUserClasses {
            if !newClasses.contains(c) {
                deletedClasses.append(c)
            }
        }

        if deletedClasses.count > 0 {
            firebaseManager.deleteUsersPostAndRepliesFromClass(fromClasses: deletedClasses, email: self.userDoc.Email, college: self.userDoc.College) { success, error in
                if error != nil {
                    returnedError = "Posts could not be deleted."
                } else {
                    if !success {
                        returnedError = "Posts could not be deleted."
                    }
                }
            }
        }

        if let returnedError = returnedError {
            return returnedError
        }

        updatedFields["classes"] = newClasses

        // Update the Firestore document with the new values
        userDocLocation.updateData(updatedFields) { error in
            if let error = error {
                print("Error updating document: \(error)")
                returnedError = "Error updating profile."
            } else {
                print("Document successfully updated")
            }
        }

        // Handle the newProfilePicture
        if didEditPhoto {
            if let newImage = newProfilePicture {
                // Delete the old picture from Firestore.
                firebaseManager.deleteProfilePictureFromFirestore(forEmail: self.userDoc.Email) { success, error in
                    
                    if error != nil {
                        returnedError = "Old profile picture could not be deleted."
                        print("Old profile picture could not be deleted")
                    } else {
                        print("success: \(success)")
                        if success {
                            // Upload the new picture to Firestore.
                            self.firebaseManager.uploadProfileImage(newImage) { result in
                                switch result {
                                case .success(let urlString):
                                    print("url is \(urlString)")
                                    updatedFields["profile_picture_url"] = urlString
                                    userDocLocation.updateData(updatedFields)
                                    
                                    // Update 'profile_pic_url' in any posts and replies made by the user
                                    self.firebaseManager.updateProfilePicUrlForPostAndReplies(forEmail: self.userDoc.Email, withUrl: urlString) { (success, error) in
                                        if let error = error {
                                            print("Error occurred: \(error)")
                                        } else if success {
                                            KingfisherManager.shared.cache.clearMemoryCache()
                                            KingfisherManager.shared.cache.clearDiskCache()
                                            self.refreshPosts() { success in }
                                            print("Profile picture URLs updated successfully!")
                                        } else {
                                            print("Operation did not complete successfully.")
                                        }
                                    }

                                case .failure(let error):
                                    returnedError = "New profile picture could not be uploaded: \(error.localizedDescription)"
                                    print("New profile picture could not be uploaded: \(error.localizedDescription)")
                                }
                            }
                        } else {
                            returnedError = "Old profile picture could not be deleted."
                        }
                    }
                }
            }
        }
        
      

        objectWillChange.send()

        return returnedError
    }

    


    
    
}
