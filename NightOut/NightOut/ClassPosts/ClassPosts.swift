//
//  ClassPosts.swift
//  NightOut
//
//  Created by Kyle Zeller on 1/13/23.
//

import Foundation
import Firebase

class ClassPost: Identifiable, ObservableObject {
    
    
    //fields
    let db = Firestore.firestore()
    var postBody:String
    var email: String
    var postAuthor: String
    var forClass:String
    var forCollege:String
    @Published var replies: [Replies] = []
    @Published var votes:Int64
    let id: String
    var DatePosted: Double = 0.0
    var UsersLiked:Set = Set<String>()
    var UserDownVotes:Set = Set<String>()
   
    
    
    //constructor
    //this constructor is used when a new post is made.
    init(postBody:String, postAuthor:String, forClass:String,votes:Int64 ,id: String,email:String, college:String){
        
        self.postBody = postBody
        self.postAuthor = postAuthor
        self.forClass = forClass
        self.votes = votes
        self.id = id
        self.email  = email
        self.forCollege = college
        self.DatePosted = Date().timeIntervalSince1970
        
    }
    //this constructor is used when reading posts that have already been sent to firebase
    init(postBody:String, postAuthor:String, forClass:String, DatePosted: Double, votes:Int64,id: String,usersLiked: Set<String>, usersDisliked: Set<String>, email:String,college:String   ){
       
        self.postBody = postBody
        self.postAuthor = postAuthor
        self.forClass = forClass
        self.DatePosted = DatePosted
        self.votes = votes
        self.id = id
        self.UsersLiked = usersLiked
        self.UserDownVotes = usersDisliked
        self.email = email
        self.forCollege = college
        
    }
    
    


    


}


class Replies: Identifiable, ObservableObject{
    var replyBody:String
    var replyAuthor: String
    
    @Published var votes:Int64
    let id: String
    var DatePosted:Double = 0.0
    var UsersLiked:Set = Set<String>()
    var UserDownVotes:Set = Set<String>()
    
    
    //this constructor is used when a new reply is made.
    init(replyBody:String, replyAuthor:String, votes:Int64 ,id: String ){
        
        self.replyBody = replyBody
        self.replyAuthor = replyAuthor
        
        self.votes = votes
        self.id = id
        self.DatePosted = Date().timeIntervalSince1970
    }
    
    
    //this constructor is used when reading replies that have already been sent to firebase
    init(replyBody:String, replyAuthor:String,  DatePosted: Double, votes:Int64,id: String,usersLiked: Set<String>, usersDisliked: Set<String>){
       
        self.replyBody = replyBody
        self.replyAuthor = replyAuthor
       
        self.DatePosted = DatePosted
        self.votes = votes
        self.id = id
        self.UsersLiked = usersLiked
        self.UserDownVotes = usersDisliked
        
    }
    
   
    
}
