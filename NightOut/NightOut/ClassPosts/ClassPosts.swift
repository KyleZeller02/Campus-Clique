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
    
    func addReply(author: String, replyBody body: String) {
        let date = Date().timeIntervalSince1970
        let replyCollection = db.collection("Colleges").document(forCollege).collection(forClass).document(id).collection("Replies")
        let replyDocument = replyCollection.document()
        
        let data: [String: Any] = [
            "author": author,
            "forClass": forClass,
            "postBody": body,
            "votes": 0,
            "id": replyDocument.documentID,
            "date": date
        ]
        
        replyDocument.setData(data) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                // Handle error
                print(error.localizedDescription)
            } else {
                let reply = Replies(replyBody: body, replyAuthor: author, forClass: self.forClass, votes: 0, id: replyDocument.documentID)
                self.replies.append(reply)
                self.objectWillChange.send()
            }
        }
    }


    func getReplies(completion: @escaping ([Replies]) -> Void) {
        let postLocation = db.collection("Colleges").document(forCollege).collection(forClass).document(id).collection("Replies")
        
        postLocation.order(by: "date", descending: false).getDocuments { [weak self] querySnapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Something went wrong getting replies on post from Firebase: \(error.localizedDescription)")
                completion([])
            } else {
                var tempReplies: [Replies] = []
                
                for document in querySnapshot!.documents {
                    let data = document.data()
                    
                    let author = data["author"] as? String ?? ""
                    let forClass = data["forClass"] as? String ?? ""
                    let id = data["id"] as? String ?? ""
                    let postBody = data["postBody"] as? String ?? ""
                    let votes = data["votes"] as? Int64 ?? 0
                    let usersLiked = data["UsersLiked"] as? [String] ?? []
                    let usersDisliked = data["UsersDisliked"] as? [String] ?? []
                    let date = data["datePosted"] as? Double ?? 0.0
                    let reply = Replies(replyBody: postBody, replyAuthor: author, forClass: forClass, DatePosted: date, votes: votes, id: id, usersLiked: Set(usersLiked), usersDisliked: Set(usersDisliked))
                    tempReplies.append(reply)
                }
                
                self.replies = tempReplies
                self.objectWillChange.send()
                completion(tempReplies)
            }
        }
    }


}


class Replies: Identifiable, ObservableObject{
    var replyBody:String
    var replyAuthor: String
    var forClass:String
    @Published var votes:Int64
    let id: String
    var DatePosted:Double = 0.0
    var UsersLiked:Set = Set<String>()
    var UserDownVotes:Set = Set<String>()
    
    
    //this constructor is used when a new reply is made.
    init(replyBody:String, replyAuthor:String, forClass:String,votes:Int64 ,id: String ){
        
        self.replyBody = replyBody
        self.replyAuthor = replyAuthor
        self.forClass = forClass
        self.votes = votes
        self.id = id
        self.DatePosted = Date().timeIntervalSince1970
    }
    
    
    //this constructor is used when reading replies that have already been sent to firebase
    init(replyBody:String, replyAuthor:String, forClass:String, DatePosted: Double, votes:Int64,id: String,usersLiked: Set<String>, usersDisliked: Set<String>){
       
        self.replyBody = replyBody
        self.replyAuthor = replyAuthor
        self.forClass = forClass
        self.DatePosted = DatePosted
        self.votes = votes
        self.id = id
        self.UsersLiked = usersLiked
        self.UserDownVotes = usersDisliked
        
    }
    
   
    
}
