//
//  Reply.swift
//  Campus Clique
//
//  Created by Kyle Zeller on 7/17/23.
//

import Foundation

class Reply: Identifiable, ObservableObject, Equatable {
    var replyBody: String
    @Published var firstName : String
     @Published var lastName : String
    var phoneNumber: String
    @Published var votes: Int64
    let id: String
    var DatePosted: Double = 0.0
    @Published var UsersLiked: Set<String> = Set<String>()
    @Published var UserDownVotes: Set<String> = Set<String>()
    var profilePicURL: String?
    var forPostID: String
    var forClass:String
    var forCollege: String
 
   
    init(replyBody: String, firstName: String, lastName: String,  DatePosted: Double, votes: Int64, id: String, usersLiked: Set<String>, usersDisliked: Set<String>, phoneNumber: String, picURL: String?, postID:String, inClass:String, inCollege:String) {
        self.replyBody = replyBody
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
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
            && lhs.firstName == rhs.firstName
        && lhs.lastName == rhs.lastName
            && lhs.phoneNumber == rhs.phoneNumber
            && lhs.votes == rhs.votes
            && lhs.DatePosted == rhs.DatePosted
            && lhs.UsersLiked == rhs.UsersLiked
            && lhs.UserDownVotes == rhs.UserDownVotes
    }
}
