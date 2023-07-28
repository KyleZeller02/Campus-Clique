//
//  Reply.swift
//  Campus Clique
//
//  Created by Kyle Zeller on 7/17/23.
//

import Foundation

/// `Reply` is a model class representing a reply within a class discussion.
///
/// This class includes the relevant information for a reply made within a class discussion in the
/// Campus Clique application. This includes the body of the reply, the author's information, the
/// post it's associated with, and its votes, among others.
///
/// It conforms to the `Identifiable`, `ObservableObject`, and `Equatable` protocols, which allows
/// it to be used easily within SwiftUI views and to be compared for equality with other `Reply`
/// objects.
class Reply: Identifiable, ObservableObject, Equatable {

    /// The body of the reply, or the main content of the reply.
    var replyBody: String
    
    /// The first name of the author of the reply.
    @Published var firstName: String
    
    /// The last name of the author of the reply.
    @Published var lastName: String
    
    /// The phone number of the user who created the reply.
    var phoneNumber: String
    
    /// The total votes for the reply. This value can be positive or negative.
    @Published var votes: Int64
    
    /// The unique identifier of the reply.
    let id: String
    
    /// The date and time when the reply was created, represented as a Unix timestamp.
    var DatePosted: Double
    
    /// The set of user phone numbers who have liked the reply.
    @Published var UsersLiked: Set<String> = Set<String>()
    
    /// The set of user phone numbers who have disliked the reply.
    @Published var UserDownVotes: Set<String> = Set<String>()
    
    /// The URL of the profile picture of the author of the reply.
    var profilePicURL: String?
    
    /// The identifier of the post this reply is associated with.
    var forPostID: String
    
    /// The class associated with the reply.
    var forClass: String
    
    /// The college or university associated with the reply.
    var forCollege: String

    /// Initializes a new instance of `Reply`.
    ///
    /// - Parameters:
    ///   - replyBody: The body of the reply.
    ///   - firstName: The first name of the author.
    ///   - lastName: The last name of the author.
    ///   - DatePosted: The timestamp when the reply was created.
    ///   - votes: The total votes for the reply.
    ///   - id: The unique identifier for the reply.
    ///   - usersLiked: The set of users who have liked the reply.
    ///   - usersDisliked: The set of users who have disliked the reply.
    ///   - phoneNumber: The phone number of the author.
    ///   - picURL: The URL of the profile picture of the author.
    ///   - postID: The identifier of the post this reply is associated with.
    ///   - inClass: The associated class for the reply.
    ///   - inCollege: The associated college or university.
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

    /// Defines the criteria for equality between two `Reply` instances.
    ///
    /// Two `Reply` instances are considered equal if all their properties are equal.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side value to compare.
    ///   - rhs: The right-hand side value to compare.
    /// - Returns: `true` if the values are equal, `false` otherwise.
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

