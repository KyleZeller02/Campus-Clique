//
//  ClassPosts.swift
//  NightOut
//
//  Created by Kyle Zeller on 1/13/23.
//

import Foundation

class ClassPost: Identifiable, ObservableObject {
    //fields
    var postBody:String
    var postAuthor: String
    var forClass:String
    var replies: [Replies] = []
    @Published var votes:Int64
    let id: String
    var DatePosted: String = ""
    var UsersLiked:Set = Set<String>()
    var UserDownVotes:Set = Set<String>()
    
    
    //constructor
    //this constructor is used when a new post is made.
    init(postBody:String, postAuthor:String, forClass:String,votes:Int64 ,id: String){
        
        self.postBody = postBody
        self.postAuthor = postAuthor
        self.forClass = forClass
        self.votes = votes
        self.id = id
        self.DatePosted = GenerateDateTime()
    }
    //this constructor is used when reading posts that have already been sent to firebase
    init(postBody:String, postAuthor:String, forClass:String, DatePosted: String, votes:Int64,id: String,usersLiked: Set<String>, usersDisliked: Set<String>   ){
       
        self.postBody = postBody
        self.postAuthor = postAuthor
        self.forClass = forClass
        self.DatePosted = DatePosted
        self.votes = votes
        self.id = id
        self.UsersLiked = usersLiked
        self.UserDownVotes = usersDisliked
        
    }
    
 // this method is used to time stamp posts when a new post is made
    private func GenerateDateTime() -> String{
        let df: DateFormatter = DateFormatter()
        df.dateFormat = "yyy-MM-DD HH:mm:ss"
        let date = Date()
       DatePosted = df.string(from: date)
        return DatePosted
    }
    
}


class Replies: Identifiable, ObservableObject{
    var replyBody:String
    var replyAuthor: String
    var forClass:String
    @Published var votes:Int64
    let id: String
    var DatePosted: String = ""
    var UsersLiked:Set = Set<String>()
    var UserDownVotes:Set = Set<String>()
    
    
    //this constructor is used when a new reply is made.
    init(replyBody:String, replyAuthor:String, forClass:String,votes:Int64 ,id: String ){
        
        self.replyBody = replyBody
        self.replyAuthor = replyAuthor
        self.forClass = forClass
        self.votes = votes
        self.id = id
        self.DatePosted = GenerateDateTime()
    }
    
    
    //this constructor is used when reading replies that have already been sent to firebase
    init(replyBody:String, replyAuthor:String, forClass:String, DatePosted: String, votes:Int64,id: String,usersLiked: Set<String>, usersDisliked: Set<String>){
       
        self.replyBody = replyBody
        self.replyAuthor = replyAuthor
        self.forClass = forClass
        self.DatePosted = DatePosted
        self.votes = votes
        self.id = id
        self.UsersLiked = usersLiked
        self.UserDownVotes = usersDisliked
        
    }
    
    // this method is used to time stamp posts when a new post is made
       private func GenerateDateTime() -> String{
           let df: DateFormatter = DateFormatter()
           df.dateFormat = "yyy-MM-DD HH:mm:ss"
           let date = Date()
          DatePosted = df.string(from: date)
           return DatePosted
       }
    
}
