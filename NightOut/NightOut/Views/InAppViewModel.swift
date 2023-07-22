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
    @Published var userDoc: UserDocument = UserDocument(FirstName: "", LastName: "", College: "",  Major: "", Classes: [], phoneNumber: "", profilePictureURL: nil)
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
        firebaseManager.deletePostsAndRepliesOfUser(phoneNumber: self.userDoc.PhoneNumber) { (success, error) in
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
    
    
    
    
    
    
    func addReply(_ replyBody: String, to post: ClassPost) {
           
        guard !self.userDoc.FullName.isEmpty,
              !self.userDoc.PhoneNumber.isEmpty else {
            return
        }
        
        firebaseManager.addReply(replyBody, to: post, firstName: self.userDoc.FirstName, LastName: self.userDoc.LastName, phoneNumber: self.userDoc.PhoneNumber, profilePictureURL: self.userDoc.profilePictureURL ?? "") { [weak self] result in
            switch result {
            case .success(let reply):
                self?.curReplies.append(reply)
                self?.objectWillChange.send()
            case .failure(let error):
                print("Error adding reply: \(error)")
            }
        }
    }

    
    
    
    
    func addNewPost(_ postBody: String) {
        guard !self.userDoc.College.isEmpty,
              !self.userDoc.PhoneNumber.isEmpty,
              !self.userDoc.FullName.isEmpty else {
            print("Error: Missing User Info")
            return
        }
        
        let selectedClass = self.selectedClass
        
        firebaseManager.addNewPost(firstName:self.userDoc.FirstName, lastName: self.userDoc.LastName, postBody: postBody, forClass: selectedClass, college: self.userDoc.College, phoneNumber:  self.userDoc.PhoneNumber, profilePictureURL: self.userDoc.profilePictureURL ?? "") { post, error in
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
        guard let user = Auth.auth().currentUser, let phoneNumber = user.phoneNumber else {
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
        firebaseManager.getPostsForUser(college: self.userDoc.College, user: self.userDoc.PhoneNumber) { [weak self] posts, error in
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

    
    

    func handleEdit(changedFields: Set<String>, updatedValues: [String: Any]) {
        let fieldPriority: [String: Int] = ["classes": 1, "major": 1, "college": 1, "first_name": 2, "last_name": 2, "profile_picture": 2]
        // Sort changedFields based on priority
        let sortedChangedFields = Array(changedFields).sorted(by: { fieldPriority[$0] ?? Int.max < fieldPriority[$1] ?? Int.max })
        
        let group = DispatchGroup()
        
        for field in sortedChangedFields {
            if let value = updatedValues[field] {
                group.enter()
                updateField(forPhoneNumber: self.userDoc.PhoneNumber, field: field, newValue: value) { err in
                    if let err = err {
                        print("Error updating field \(field): \(err.localizedDescription)")
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            if !sortedChangedFields.isEmpty {
                self.firebaseManager.getDocument() { doc, err in
                    if let doc = doc {
                        DispatchQueue.main.async {
                            self.userDoc = doc
                            if sortedChangedFields.contains("first_name") || sortedChangedFields.contains("last_name") {
                                self.updateNameOnPostAndReplies()
                            }
                            if sortedChangedFields.contains("profile_picture") {
                                self.updatePhotoUrl()
                            }
                            self.objectWillChange.send()
                        }
                    }
                }
            }
        }
    }



    func updateNameOnPostAndReplies(){
        for post in postsforUser{
            if isAuthorPost(ofPost: post){
                post.firstName = userDoc.FirstName
                post.lastName = userDoc.LastName
                objectWillChange.send()
            }
        }
        for post in postsForClass{
            if isAuthorPost(ofPost: post){
                post.firstName = userDoc.FirstName
                post.lastName = userDoc.LastName
                objectWillChange.send()
            }
        }
        for reply in curReplies {
            if isAuthorReply(ofReply: reply){
                reply.firstName = userDoc.FirstName
                reply.lastName = userDoc.LastName
                objectWillChange.send()
            }
        }
      
    }
    
    func updatePhotoUrl(){
        for post in postsforUser{
            if isAuthorPost(ofPost: post){
                post.profilePicURL = userDoc.profilePictureURL
              
                objectWillChange.send()
            }
        }
        for post in postsForClass{
            if isAuthorPost(ofPost: post){
                post.profilePicURL = userDoc.profilePictureURL
                objectWillChange.send()
            }
        }
        for reply in curReplies {
            if isAuthorReply(ofReply: reply){
                reply.profilePicURL = userDoc.profilePictureURL
                objectWillChange.send()
            }
        }
    }
    func updateField(forPhoneNumber phoneNumber: String, field: String, newValue: Any, completion: @escaping (Error?) -> Void) {
        switch field {
        case "first_name":
            updateFirstName(forPhoneNumber: phoneNumber, newFirstName: newValue as! String) { err in
                if let err = err {
                    completion(err)
                } else {
                    completion(nil)
                }
            }
        case "last_name":
            updateLastName(forPhoneNumber: phoneNumber, newLastName: newValue as! String) { err in
                if let err = err {
                    completion(err)
                } else {
                    completion(nil)
                }
            }
        case "classes":
            updateClasses(forPhoneNumber: phoneNumber, newClasses: newValue as! [String], oldClasses: self.userDoc.Classes) { err in
                if let err = err {
                    completion(err)
                } else {
                    completion(nil)
                }
            }
        case "major":
            updateMajor(forPhoneNumber: phoneNumber, newMajor: newValue as! String) { err in
                if let err = err {
                    completion(err)
                } else {
                    completion(nil)
                }
            }
        case "college":
            updateCollege(forPhoneNumber: phoneNumber, newCollege: newValue as! String) { err in
                if let err = err {
                    completion(err)
                } else {
                    completion(nil)
                }
            }
        case "profile_picture":
            updateProfilePicture(forPhoneNumber: phoneNumber, newProfilePicture: newValue as! UIImage) { err in
                if let err = err {
                    completion(err)
                } else {
                    KingfisherManager.shared.cache.removeImage(forKey: phoneNumber) //remove the cached image after successful update
                    completion(nil)
                }
            }
        default:
            print("Unsupported field: \(field)")
            let unsupportedError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Unsupported field: \(field)"])
            completion(unsupportedError)
        }
    }


    
    private func updateFirstName(forPhoneNumber phoneNumber: String, newFirstName: String, completion: @escaping (Error?) -> Void) {
        //update user document
        let userDocLocation = db.collection("Users").document(phoneNumber)
        
        userDocLocation.updateData(["first_name" : newFirstName]) { error in
            if let error = error {
                print("Error updating document in updateFirstName(): \(error)")
                completion(error)
            } else {
                //for all post documents and reply documents made by user, update first name
                self.firebaseManager.updateFirstNameOnPostsAndReplies(wherePhoneNumber: self.userDoc.PhoneNumber, firstName: newFirstName){ error in
                    if let error = error{
                        print("error in updateFirstNameOnPostsAndReplies(): \(error.localizedDescription) ")
                        completion(error)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }

    
    private func updateLastName( forPhoneNumber: String, newLastName: String, completion: @escaping (Error?) -> Void) {
        //update user document
        let userDocLocation = db.collection("Users").document(forPhoneNumber)
        userDocLocation.updateData(["last_name" : newLastName]) { error in
            if let error = error {
                print("Error updating document in updateLastName(): \(error)")
                completion(error)
            } else {
                //for all post documents and reply documents made by user, update last name
                self.firebaseManager.updateLastNameOnPostsAndReplies(wherePhoneNumber: self.userDoc.PhoneNumber, lastName: newLastName){ error in
                    if let error = error{
                        print("error in updateLastNameOnPostsAndReplies(): \(error.localizedDescription) ")
                        completion(error)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }

    
   
    private func updateClasses(forPhoneNumber phoneNumber: String, newClasses: [String], oldClasses: [String], completion: @escaping (Error?) -> Void) {
        //save out old classes and prep variables
        let newClassesSet = Set<String>(newClasses)
        let oldClassesSet = Set<String>(oldClasses)
        //update user document
        let userDocLocation = db.collection("Users").document(phoneNumber)
        userDocLocation.updateData(["classes": Array(newClassesSet)]) { error in
            if let error = error {
                print("Error updating classes in updateClasses(): \(error)")
                completion(error)
            } else {
                let classesToRemove = Array(oldClassesSet.subtracting(newClassesSet))
                if classesToRemove.count > 0 {
                    // remove all posts, their replies, as well as replies made by user on other posts, in classes they are no logner taking
                    self.firebaseManager.deleteUsersPostAndRepliesAndRepliesOnEachPostFromClass(fromClasses:classesToRemove, forPhoneNumber: self.userDoc.PhoneNumber, college: self.userDoc.College){ (res,err) in
                        if let err = err{
                            print("error in deleteUsersPostAndRepliesAndRepliesOnEachPostFromClass() : \(err.localizedDescription)")
                            completion(err)
                        } else {
                            completion(nil)
                        }
                    }
                } else {
                    completion(nil)
                }
            }
        }
    }


    
    private func updateMajor(forPhoneNumber phoneNumber: String, newMajor: String, completion: @escaping (Error?) -> Void) {
        //update user document
        let userDocLocation = db.collection("Users").document(phoneNumber)
        userDocLocation.updateData(["major": newMajor]) { error in
            if let error = error {
                print("Error updating major in updateMajor(): \(error)")
                completion(error)
            } else {
                completion(nil)
            }
        }
        //there is currently nothing that relies on major
    }

    private func updateCollege(forPhoneNumber phoneNumber: String, newCollege: String, completion: @escaping (Error?) -> Void) {
        //update user document
        let userDocLocation = db.collection("Users").document(phoneNumber)
        userDocLocation.updateData(["college": newCollege]) { error in
            if let error = error {
                print("Error updating college in updateCollege(): \(error)")
                completion(error)
                return
            }

            //remove all posts, their replies, and replies made by that user on other posts, in that old college
            self.firebaseManager.removePostsRepliesAndPostsOfUserRepliesFromCollege(wherePhoneNumber: self.userDoc.PhoneNumber, whereCollege: self.userDoc.College){ error in
                if let error = error {
                    print("Error in removePostsRepliesAndPostsOfUserRepliesFromCollege(): \(error)")
                    completion(error)
                } else {
                    completion(nil)
                }
            }
        }
    }

    func updateProfilePicture(forPhoneNumber phoneNumber: String, newProfilePicture: UIImage, completion: @escaping (Error?) -> Void) {
        firebaseManager.uploadProfileImage(newProfilePicture) { res in
            switch res {
            case .success(let newProfilePicURL):
                self.firebaseManager.deleteOldProfilePictureFromFirestore(forPhoneNumber: phoneNumber) { (isDeleted, error) in
                    if let error = error {
                        print("Error deleting old profile picture: \(error)")
                        completion(error)
                    } else {
                        print("Old profile picture deleted successfully.")
                        self.firebaseManager.updateProfilePictureURL(forPhoneNumber: phoneNumber, newProfilePicURL: newProfilePicURL) { error in
                            if let error = error {
                                print("Error updating user document: \(error)")
                                completion(error)
                            } else {
                                self.firebaseManager.updateProfilePicOnPostsAndReplies(wherePhoneNumber: phoneNumber, profilePicURL: newProfilePicURL) { error in
                                    if let error = error {
                                        print("Error updating posts and replies: \(error)")
                                        completion(error)
                                    } else {
                                        print("Posts and replies updated successfully.")
                                        completion(nil)
                                    }
                                }
                            }
                        }
                    }
                }
            case .failure(let error):
                print("Error uploading profile image: \(error)")
                completion(error)
            }
        }
    }



    

    

    //this method needs to be abstracted and modulated more
    
    


    
    
}
