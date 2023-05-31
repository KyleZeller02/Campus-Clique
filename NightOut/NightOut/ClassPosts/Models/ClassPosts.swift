//
//  ClassPosts.swift
//  NightOut
//
//  Created by Kyle Zeller on 1/13/23.
//

import Foundation
import Firebase

class ClassPost: Identifiable, ObservableObject, Equatable{
    
    // Fields
    let db = Firestore.firestore()
    let id: String
    let email: String
    var postBody: String
    var postAuthor: String
    var forClass: String
    var forCollege: String
    @Published var replies: [Replies] = []
    var votes: Int64
    var datePosted: Double = 0.0
    var usersLiked: Set<String> = []
    var usersDisliked: Set<String> = []
    
    // Constructors
    
    // This constructor is used when a new post is made.
    
    
    // This constructor is used when reading posts that have already been sent to Firebase.
    init(postBody: String, postAuthor: String, forClass: String, datePosted: Double, votes: Int64, id: String, usersLiked: Set<String>, usersDisliked: Set<String>, email: String, college: String) {
        self.postBody = postBody
        self.postAuthor = postAuthor
        self.forClass = forClass
        self.datePosted = datePosted
        self.votes = votes
        self.id = id
        self.usersLiked = usersLiked
        self.usersDisliked = usersDisliked
        self.email = email
        self.forCollege = college
    }
    static func == (lhs: ClassPost, rhs: ClassPost) -> Bool {
            return lhs.id == rhs.id
                && lhs.postBody == rhs.postBody
                && lhs.postAuthor == rhs.postAuthor
                && lhs.forClass == rhs.forClass
                && lhs.forCollege == rhs.forCollege
                && lhs.replies == rhs.replies
                && lhs.votes == rhs.votes
                && lhs.datePosted == rhs.datePosted
                && lhs.usersLiked == rhs.usersLiked
                && lhs.usersDisliked == rhs.usersDisliked
        }
    func getReplies( completion: @escaping ([Replies]) -> Void) {
        guard let college = UserManager.shared.currentUser?.College else { return }
        let postLocation = db.collection("posts").document(self.id).collection("replies")

        postLocation.order(by: "time_stamp", descending: false).getDocuments() { [weak self] querySnapshot, error in
            guard let self = self, let documents = querySnapshot?.documents else {
                print("Error getting documents: \(error?.localizedDescription ?? "")")
                completion([])
                return
            }

            var replies: [Replies] = []

            documents.forEach { document in
                let data = document.data()
                let reply = self.createReplyFromData(data)
                replies.append(reply)
            }

            completion(replies)
        }
    }

    func createReplyFromData(_ data: [String: Any]) -> Replies {
        let email = data["email"] as? String ?? ""
        
        let author = data["author"] as? String ?? ""
        let id = data["id"] as? String ?? ""
        let replyBody = data["reply_body"] as? String ?? ""
        let votes = data["votes"] as? Int64 ?? 0
        let usersLiked = data["users_liked"] as? [String] ?? []
        let usersDisliked = data["users_disliked"] as? [String] ?? []
        let date = data["time_stamp"] as? Double ?? 0.0
        
        return Replies(replyBody: replyBody, replyAuthor: author, DatePosted: date, votes: votes, id: id, usersLiked: Set(usersLiked), usersDisliked: Set(usersDisliked), email: email)
    }

}



class Replies: Identifiable, ObservableObject,Equatable{
    var replyBody:String
    var replyAuthor: String
    var email:String
    @Published var votes:Int64
    let id: String
    var DatePosted:Double = 0.0
    var UsersLiked:Set = Set<String>()
    var UserDownVotes:Set = Set<String>()
    
    
    //this constructor is used when a new reply is made.
    
    
    //this constructor is used when reading replies that have already been sent to firebase
    init(replyBody:String, replyAuthor:String,  DatePosted: Double, votes:Int64,id: String,usersLiked: Set<String>, usersDisliked: Set<String>, email:String){
       
        self.replyBody = replyBody
        self.replyAuthor = replyAuthor
        self.email = email
        self.DatePosted = DatePosted
        self.votes = votes
        self.id = id
        self.UsersLiked = usersLiked
        self.UserDownVotes = usersDisliked
        
    }
    static func == (lhs: Replies, rhs: Replies) -> Bool {
        return lhs.id == rhs.id
            && lhs.replyBody == rhs.replyBody
            && lhs.replyAuthor == rhs.replyAuthor
            && lhs.email == rhs.email
            && lhs.votes == rhs.votes
            && lhs.DatePosted == rhs.DatePosted
            && lhs.UsersLiked == rhs.UsersLiked
            && lhs.UserDownVotes == rhs.UserDownVotes
    }
    
   
    
}
