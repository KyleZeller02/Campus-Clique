//
//  ClassPostsViewModel.swift
//  NightOut
//
//  Created by Kyle Zeller on 1/13/23.
//

import Foundation
import FirebaseFirestore
import Firebase

class ClassPostsViewModel: ObservableObject {
    
    @Published var postsArray: [ClassPost] = []
    private var userManager: UserManager
    let firebaseManager = FirestoreService()
    
    @Published var isLoading: Bool = false
    @Published var selectedClass:String = ""
    
    
    let db = Firestore.firestore()
    init(userManager: UserManager = UserManager.shared) {
        self.userManager = userManager
        guard let curUser = userManager.currentUser?.Email else { return }
        self.userManager.getDocument(user: curUser) { [weak self] doc in
            guard let self = self else { return }
            
            UserManager.shared.currentUser = doc
            UserManager.shared.currentUser?.Classes.sort()
            
            self.selectedClass = UserManager.shared.currentUser?.Classes.first ?? ""
            
            self.getPosts()
            
        }
    }
    
 //getting posts somehow reads email address wrong on init
    func getPosts() {
        guard !self.selectedClass.isEmpty, let college = self.userManager.currentUser?.College else {
            print("Error: Class or college is undefined")
            return
        }

        firebaseManager.fetchPosts(fromClass: self.selectedClass, fromCollege: college) { [weak self] (posts, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }

            self?.postsArray = posts ?? []
        }
    }


    
    func deletePostAndReplies(_ post: ClassPost) {
        firebaseManager.deletePostAndReplies(post) { success in
            if success {
                print("Post and replies successfully deleted!")
            } else {
                print("Error deleting post and replies.")
            }
        }
    }

    


    
    


    
    func addReply(_ replyBody: String, to post: ClassPost) {
        guard let author = userManager.currentUser?.FullName,
              let email = userManager.currentUser?.Email else {
            print("Error: Missing User Info")
            return
        }

        let datePosted = Date().timeIntervalSince1970

        firebaseManager.addReply(replyBody, to: post, author: author, email: email) { [weak self] result in
            switch result {
            case .success(let reply):
                post.replies.append(reply)
                self?.objectWillChange.send()
            case .failure(let error):
                print("Error adding reply: \(error)")
            }
        }
    }



    
    func addNewPost(_ postBody: String) {
        guard let college = userManager.currentUser?.College,
              let email = userManager.currentUser?.Email,
              let name = userManager.currentUser?.FullName else {
            print("Error: Missing User Info")
            return
        }

        let selectedClass = self.selectedClass

        firebaseManager.addNewPost(author: name, postBody: postBody, forClass: selectedClass, college: college, email: email) { result in
            if let result = result {
                let (postId, success) = result
                if success {
                    print("Post \(postId) added successfully.")
                    self.getPosts()
                } else {
                    print("Error adding new post.")
                }
            } else {
                print("Error adding new post.")
            }
        }
    }


    func handleVoteOnPost(UpOrDown voteType: VoteType, onPost post: ClassPost) {
        guard let user = Auth.auth().currentUser else {
            return // Return if user is not logged in
        }

        firebaseManager.performAction(vote: voteType, post: post, user: user) { success, error in
            if success {
                // Fetch the updated post from Firestore
                self.firebaseManager.fetchPost(byId: post.id) { updatedPost, error in
                    if let updatedPost = updatedPost {
                        DispatchQueue.main.async {
                            self.updatePostArray(with: updatedPost)
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

    private func updatePostArray(with post: ClassPost) {
           if let index = postsArray.firstIndex(where: { $0.id == post.id }) {
               postsArray[index] = post
           }
       }


    func handleVoteOnReply(_ vote: VoteType, onPost post: ClassPost, onReply reply: Replies) {
            guard let user = Auth.auth().currentUser else {
                return // Return if user is not logged in
            }

            firebaseManager.performActionOnReply(vote: vote, post: post, reply: reply, user: user) { success, error in
                if success {
                    switch vote {
                    case .up:
                        reply.UserDownVotes.remove(user.email!)
                        if reply.UsersLiked.contains(user.email!) {
                            reply.UsersLiked.remove(user.email!)
                            reply.votes -= 1
                        } else {
                            if reply.UserDownVotes.contains(user.email!) {
                                reply.votes += 2
                            } else {
                                reply.votes += 1
                            }
                            reply.UsersLiked.insert(user.email!)
                        }

                    case .down:
                        reply.UsersLiked.remove(user.email!)
                        if reply.UserDownVotes.contains(user.email!) {
                            reply.UserDownVotes.remove(user.email!)
                            reply.votes += 1
                        } else {
                            if reply.UsersLiked.contains(user.email!) {
                                reply.votes -= 2
                            } else {
                                reply.votes -= 1
                            }
                            reply.UserDownVotes.insert(user.email!)
                        }
                    }
                    // Call the UI update method here
                } else if let error = error {
                    // Handle the error here
                    print("Error updating vote: \(error)")
                }
            }
        }
    
    func deleteReply(_ reply: Replies, fromPost post: ClassPost) {
        firebaseManager.deleteReply(reply, fromPost: post) { [weak self] result in
                switch result {
                case .success:
                    // Update the local data after successful deletion
                    if let index = post.replies.firstIndex(where: { $0.id == reply.id }) {
                        post.replies.remove(at: index)
                    }
                    // Update any other necessary data
                    self?.objectWillChange.send()
                case .failure(let error):
                    print("Error deleting reply: \(error)")
                }
            }
        }
        
}
