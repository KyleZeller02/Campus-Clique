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
    @Published var profileVM: UserProfileViewModel = UserProfileViewModel()
    @Published var userPosts: [ClassPost] = []
    @Published var curReplies: [Replies] = []
    
    @Published var selectedClass: String = "Selected Class"
    
    let db = Firestore.firestore()
    
    init() {
        let curUser = profileVM.CurUser()
        profileVM.getDocument(user: curUser) { [weak self] doc in
            guard let self = self else { return }
            self.profileVM.userDocument = doc
            self.selectedClass = doc.Classes?.first ?? "Selected Class"
            self.getPosts(selectedClass: self.selectedClass)
            self.getPostsForUser(for: self.profileVM.userDocument.Email)
        }
        
        profileVM.userDocument.Classes?.sort()
    }
    
    func getPostsForUser(for user: String) {
        self.userPosts.removeAll()
        let college = profileVM.userDocument.College
        let path = db.collection("Colleges").document(college)
        let classes: [String] = profileVM.userDocument.Classes ?? []
        
        for c in classes {
            let fullPath = path.collection(c)
            let query = fullPath.whereField("email", isEqualTo: user)
            
            query.getDocuments { [weak self] querySnapshot, error in
                guard let self = self, let documents = querySnapshot?.documents else { return }
                
                var posts: [ClassPost] = []
                
                documents.forEach { document in
                    let data = document.data()
                    let post = self.createPostFromData(data)
                    posts.append(post)
                }
                
                self.userPosts = posts
                self.sortUsersPost()
            }
        }
    }
    
    func getPosts(selectedClass: String) {
        if selectedClass == "Selected Class" {
            return
        }
        
        let college: String = profileVM.userDocument.College
        let postLocation = db.collection("Colleges").document(college).collection(selectedClass)
        
        postLocation.order(by: "datePosted", descending: true).getDocuments() { [weak self] querySnapshot, error in
            guard let self = self, let documents = querySnapshot?.documents else { return }
            
            var posts: [ClassPost] = []
            
            documents.forEach { document in
                let data = document.data()
                let post = self.createPostFromData(data)
                posts.append(post)
            }
            
            self.postsArray = posts
            self.sortPosts()
        }
    }
    
    func createPostFromData(_ data: [String: Any]) -> ClassPost {
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
        
        return ClassPost(
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
    }
    
    func sortPosts() {
        postsArray.sort { $0.datePosted > $1.datePosted }
    }
    
    func sortUsersPost() {
        userPosts.sort { $0.votes > $1.votes }
    }
    func sortReplies() {
        curReplies.sort { $0.DatePosted > $1.DatePosted }
    }

    
    func addReply(_ replyBody: String, to post: ClassPost) {
        let college = profileVM.userDocument.College
        let postPath = db.collection("Colleges").document(college).collection(post.forClass).document(post.id)
        let replyPath = postPath.collection("Replies").document()
        let replyId = replyPath.documentID
        let author = profileVM.userDocument.FullName
        
        let replyData: [String: Any] = [
            "author": author,
            "replyBody": replyBody,
            "datePosted": Date().timeIntervalSince1970,
            "id": replyId
        ]
        
        replyPath.setData(replyData) { error in
            if let error = error {
                print("Error adding reply: \(error)")
            }
        }
        let reply = Replies(replyBody: replyBody, replyAuthor:author, votes: 0, id: replyId)
        self.curReplies.append(reply)
        self.sortReplies()
        self.objectWillChange.send()
        
        
    }
    
    func addNewPost(_ postBody: String) {
        let college = profileVM.userDocument.College
        let selectedClass = self.selectedClass
        let email = profileVM.userDocument.Email
        let name = profileVM.userDocument.FullName
        
        let postPath = db.collection("Colleges").document(college).collection(selectedClass).document()
        let postId = postPath.documentID
        
        let postData: [String: Any] = [
            "author":profileVM.userDocument.FullName,
            "postBody": postBody,
            "forClass": selectedClass,
            "datePosted": Date().timeIntervalSince1970,
            "votes": 0,
            "id": postId,
            "email": email as Any,
            "college": college
        ]
        
        postPath.setData(postData) { error in
            if let error = error {
                print("Error adding new post: \(error)")
            }
        }
        let newPost = ClassPost(postBody: postBody, postAuthor: name, forClass: selectedClass, votes: 0, id: postId, email: email, college: college)
        self.postsArray.append(newPost)
        self.sortPosts()
        self.userPosts.append(newPost)
        self.sortUsersPost()
        self.objectWillChange.send()
        
    }
    
    
    func getReplies(forPost post: ClassPost) {
        let postLocation = db.collection("Colleges").document(profileVM.userDocument.College).collection(selectedClass).document(post.id).collection("Replies")
        
        postLocation.order(by: "datePosted", descending: false).getDocuments() { [weak self] querySnapshot, error in
            guard let self = self, let documents = querySnapshot?.documents else { return }
            
            var replies: [Replies] = []
            
            documents.forEach { document in
                let data = document.data()
                let reply = self.createReplyFromData(data)
                replies.append(reply)
            }
            
            self.curReplies = replies
            
        }
    }

    
    func handleVoteOnPost(UpOrDown vote: String, onPost post: ClassPost) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            return // Return if user is not logged in
        }
        
        let ref = db.collection("Colleges").document(profileVM.userDocument.College).collection(post.forClass).document(post.id)
        
        switch vote {
        case "up":
            if post.usersLiked.contains(email) {
                // Revoke the upvote
                post.usersLiked.remove(email)
                castDownVote(for: post)
                ref.updateData([
                    "votes": FieldValue.increment(Int64(-1)),
                    "UsersLiked": FieldValue.arrayRemove([email])
                ])
            } else if post.usersDisliked.contains(email) {
                // Revoke the downvote and cast an upvote
                castUpVote(for: post)
                castUpVote(for: post)
                post.usersDisliked.remove(email)
                post.usersLiked.insert(email)
                ref.updateData([
                    "votes": FieldValue.increment(Int64(2)),
                    "UsersLiked": FieldValue.arrayUnion([email]),
                    "UsersDisliked": FieldValue.arrayRemove([email])
                ])
            } else {
                // Cast an upvote
                post.usersLiked.insert(email)
                castUpVote(for: post)
                ref.updateData([
                    "votes": FieldValue.increment(Int64(1)),
                    "UsersLiked": FieldValue.arrayUnion([email])
                ])
            }
            ref.updateData([
                "UsersDisliked": FieldValue.arrayRemove([email])
            ])
            post.usersDisliked.remove(email)
            
        case "down":
            if post.usersDisliked.contains(email) {
                // Revoke the downvote
                castUpVote(for: post)
                post.usersDisliked.remove(email)
                ref.updateData([
                    "votes": FieldValue.increment(Int64(1)),
                    "UsersDisliked": FieldValue.arrayRemove([email])
                ])
            } else if post.usersLiked.contains(email) {
                // Revoke the upvote and cast a downvote
                castDownVote(for: post)
                castDownVote(for: post)
                post.usersLiked.remove(email)
                post.usersDisliked.insert(email)
                ref.updateData([
                    "votes": FieldValue.increment(Int64(-2)),
                    "UsersLiked": FieldValue.arrayRemove([email]),
                    "UsersDisliked": FieldValue.arrayUnion([email])
                ])
            } else {
                // Cast a downvote
                castDownVote(for: post)
                post.usersDisliked.insert(email)
                ref.updateData([
                    "votes": FieldValue.increment(Int64(-1)),
                    "UsersDisliked": FieldValue.arrayUnion([email])
                ])
            }
            ref.updateData([
                "UsersLiked": FieldValue.arrayRemove([email])
            ])
            post.usersLiked.remove(email)
            
        default:
            break
        }
        
        if let index = postsArray.firstIndex(where: { $0.id == post.id }) {
            postsArray[index] = post
        }
    }
    
    func createReplyFromData(_ data: [String: Any]) -> Replies {
        let author = data["author"] as? String ?? ""
        let id = data["id"] as? String ?? ""
        let postBody = data["replyBody"] as? String ?? ""
        let votes = data["votes"] as? Int64 ?? 0
        let usersLiked = data["UsersLiked"] as? [String] ?? []
        let usersDisliked = data["UsersDisliked"] as? [String] ?? []
        let date = data["datePosted"] as? Double ?? 0.0
        
        return Replies(replyBody: postBody, replyAuthor: author, DatePosted: date, votes: votes, id: id, usersLiked: Set(usersLiked), usersDisliked: Set(usersDisliked))
    }

    
    func handleVoteOnReply(UpOrDown vote: String, onPost post: ClassPost ,onReply reply: Replies){
            guard let user = Auth.auth().currentUser, let email = user.email else {
                return // Return if user is not logged in
            }
            
            let ref = db.collection("Colleges").document(profileVM.userDocument.College).collection(selectedClass).document(post.id).collection("Replies").document(reply.id)
            
            // Update vote count and user vote status based on the vote type
            switch vote {
            case "up":
                if reply.UsersLiked.contains(email) { // If already upvoted, remove upvote
                    reply.UsersLiked.remove(email)
                    castDownVoteReply(for: reply)
                    ref.updateData([
                        "votes": FieldValue.increment(Int64(-1)),
                        "UsersLiked": FieldValue.arrayRemove([email])
                    ])
                } else if reply.UserDownVotes.contains(email) { // If already downvoted, change to upvote
                    castUpVoteReply(for: reply)
                    castUpVoteReply(for: reply)
                    reply.UserDownVotes.remove(email)
                    reply.UsersLiked.insert(email)
                    ref.updateData([
                        "votes": FieldValue.increment(Int64(2)),
                        "UsersLiked": FieldValue.arrayUnion([email]),
                        "UsersDisliked": FieldValue.arrayRemove([email])
                    ])
                } else { // If not voted, add upvote
                    reply.UsersLiked.insert(email)
                    castUpVoteReply(for: reply)
                    ref.updateData([
                        "votes": FieldValue.increment(Int64(1)),
                        "UsersLiked": FieldValue.arrayUnion([email])
                    ])
                }
                // Remove from downvote list
                ref.updateData([
                    "UsersDisliked": FieldValue.arrayRemove([email])
                ])
                reply.UserDownVotes.remove(email)
            case "down":
                if reply.UserDownVotes.contains(email) { // If already downvoted, remove downvote
                    castUpVoteReply(for: reply)
                    reply.UserDownVotes.remove(email)
                    ref.updateData([
                        "votes": FieldValue.increment(Int64(1)),
                        "UsersDisliked": FieldValue.arrayRemove([email])
                    ])
                } else if reply.UsersLiked.contains(email) { // If already upvoted, change to downvote
                    castDownVoteReply(for: reply)
                    castDownVoteReply(for: reply)
                    reply.UsersLiked.remove(email)
                    reply.UserDownVotes.insert(email)
                    ref.updateData([
                        "votes": FieldValue.increment(Int64(-2)),
                        "UsersLiked": FieldValue.arrayRemove([email]),
                        "UsersDisliked": FieldValue.arrayUnion([email])
                    ])
                } else { // If not voted, add downvote
                    castDownVoteReply(for: reply)
                    reply.UserDownVotes.insert(email)
                    ref.updateData([
                        "votes": FieldValue.increment(Int64(-1)),
                        "UsersDisliked": FieldValue.arrayUnion([email])
                    ])
                }
                // Remove from upvote list
                ref.updateData([
                    "UsersLiked": FieldValue.arrayRemove([email])
                ])
                reply.UsersLiked.remove(email)
            default:
                break
            }
        }
    /// will increase vote count by 1 for a specific post
        /// - Parameter post: the post we are adding 1 to vote property
        func castUpVote(for post:ClassPost){
            objectWillChange.send()
            post.votes += 1
        }
        /// will decrease vote count by 1 for a specific post
        /// - Parameter post: the post we are subtracting 1 from the  vote property
        func castDownVote(for post:ClassPost){
            objectWillChange.send()
            post.votes -= 1
        }
        // same methods as above, for replies
        /// will increase vote count by 1 for a specific post
        /// - Parameter post: the post we are adding 1 to vote property
        func castUpVoteReply(for reply:Replies){
            objectWillChange.send()
            reply.votes += 1
            
        }
        
        /// will decrease vote count by 1 for a specific post
        /// - Parameter post: the post we are subtracting 1 from the  vote property
        func castDownVoteReply(for reply:Replies){
            objectWillChange.send()
            reply.votes -= 1
        }

}
