//
//  ClassPosts.swift
//  NightOut
//
//  Created by Kyle Zeller on 1/13/23.
//

import Foundation
import Firebase

class ClassPost: Identifiable, ObservableObject, Equatable{
  
    // Field
    let id: String
    let email: String
    var postBody: String
    var postAuthor: String
    var forClass: String
    var forCollege: String
    @Published var replies: [Reply] = []
    var votes: Int64
    var datePosted: Double = 0.0
    var usersLiked: Set<String> = []
    var usersDisliked: Set<String> = []
    var profilePicURL: String?
   
    
    
    
    
    // This constructor is used when reading posts that have already been sent to Firebase.
    init(postBody: String, postAuthor: String, forClass: String, datePosted: Double, votes: Int64, id: String, usersLiked: Set<String>, usersDisliked: Set<String>, email: String, college: String, picURL:String? ) {
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
        self.profilePicURL = picURL
        
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
    

}



class Reply: Identifiable, ObservableObject, Equatable {
    var replyBody: String
    var replyAuthor: String
    var email: String
    @Published var votes: Int64
    let id: String
    var DatePosted: Double = 0.0
    @Published var UsersLiked: Set<String> = Set<String>()
    @Published var UserDownVotes: Set<String> = Set<String>()
    var profilePicURL: String?
    var forPostID: String
    var forClass:String
    var forCollege: String
 
   
    init(replyBody: String, replyAuthor: String,  DatePosted: Double, votes: Int64, id: String, usersLiked: Set<String>, usersDisliked: Set<String>, email: String, picURL: String?, postID:String, inClass:String, inCollege:String) {
        self.replyBody = replyBody
        self.replyAuthor = replyAuthor
        self.email = email
        self.DatePosted = DatePosted
        self.votes = votes
        self.id = id
        self.UsersLiked = usersLiked
        self.UserDownVotes = usersDisliked
        self.profilePicURL = picURL
        self.forPostID = postID
        self.forClass = inClass
        self.forCollege = inCollege
    }

    static func == (lhs: Reply, rhs: Reply) -> Bool {
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
