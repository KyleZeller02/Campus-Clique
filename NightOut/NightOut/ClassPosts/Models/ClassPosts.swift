//
//  ClassPosts.swift
//  NightOut
//
//  Created by Kyle Zeller on 1/13/23.
//

import Foundation
import Firebase

class ClassPost: Identifiable, ObservableObject {
    
    // Fields
    let db = Firestore.firestore()
    let id: String
    let email: String
    var postBody: String
    var postAuthor: String
    var forClass: String
    var forCollege: String
    var replies: [Replies] = []
    var votes: Int64
    var datePosted: Double = 0.0
    var usersLiked: Set<String> = []
    var usersDisliked: Set<String> = []
    
    // Constructors
    
    // This constructor is used when a new post is made.
    init(postBody: String, postAuthor: String, forClass: String, votes: Int64, id: String, email: String, college: String) {
        self.postBody = postBody
        self.postAuthor = postAuthor
        self.forClass = forClass
        self.votes = votes
        self.id = id
        self.email = email
        self.forCollege = college
        self.datePosted = Date().timeIntervalSince1970
    }
    
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
}



class Replies: Identifiable, ObservableObject{
    var replyBody:String
    var replyAuthor: String
    var email:String
    @Published var votes:Int64
    let id: String
    var DatePosted:Double = 0.0
    var UsersLiked:Set = Set<String>()
    var UserDownVotes:Set = Set<String>()
    
    
    //this constructor is used when a new reply is made.
    init(replyBody:String, replyAuthor:String, votes:Int64 ,id: String, email:String ){
        
        self.replyBody = replyBody
        self.replyAuthor = replyAuthor
        self.email = email
        self.votes = votes
        self.id = id
        self.DatePosted = Date().timeIntervalSince1970
    }
    
    
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
    
   
    
}
