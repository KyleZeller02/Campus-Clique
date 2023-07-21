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
    let phoneNumber: String
    var postBody: String
   @Published var firstName : String
    @Published var lastName : String
    var forClass: String
    var forCollege: String
    
    var votes: Int64
    var datePosted: Double = 0.0
    var usersLiked: Set<String> = []
    var usersDisliked: Set<String> = []
    var profilePicURL: String?
   
    
    
    
    
    // This constructor is used when reading posts that have already been sent to Firebase.
    init(postBody: String, firstName: String, lastName: String,forClass: String, datePosted: Double, votes: Int64, id: String, usersLiked: Set<String>, usersDisliked: Set<String>, phoneNumber: String, college: String, picURL:String? ) {
        self.postBody = postBody
        self.firstName = firstName
        self.lastName = lastName
        self.forClass = forClass
        self.datePosted = datePosted
        self.votes = votes
        self.id = id
        self.usersLiked = usersLiked
        self.usersDisliked = usersDisliked
        self.phoneNumber = phoneNumber
        self.forCollege = college
        self.profilePicURL = picURL
        
    }
    static func == (lhs: ClassPost, rhs: ClassPost) -> Bool {
            return lhs.id == rhs.id
                && lhs.postBody == rhs.postBody
                && lhs.firstName == rhs.firstName
        && lhs.lastName == rhs.lastName
                && lhs.forClass == rhs.forClass
                && lhs.forCollege == rhs.forCollege
        && lhs.phoneNumber == rhs.phoneNumber
                && lhs.votes == rhs.votes
                && lhs.datePosted == rhs.datePosted
                && lhs.usersLiked == rhs.usersLiked
                && lhs.usersDisliked == rhs.usersDisliked
        }
    

}




