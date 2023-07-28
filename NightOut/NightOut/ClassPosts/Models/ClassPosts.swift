//
//  ClassPosts.swift
//  NightOut
//
//  Created by Kyle Zeller on 1/13/23.
//

import Foundation
import Firebase

/// `ClassPost` is a model class representing a post within a class discussion.
///
/// This class includes the relevant information for a post made within a class discussion in the
/// NightOut application. This includes the body of the post, the author's information, the class
/// it's associated with, and its votes, among others.
///
/// It conforms to the `Identifiable`, `ObservableObject`, and `Equatable` protocols, which allows
/// it to be used easily within SwiftUI views and to be compared for equality with other `ClassPost`
/// objects.
class ClassPost: Identifiable, ObservableObject, Equatable {
  
    /// The unique identifier of the post.
    let id: String
    
    /// The phone number of the user who created the post.
    let phoneNumber: String
    
    /// The body of the post, or the main content of the post.
    var postBody: String
    
    /// The first name of the author of the post.
    @Published var firstName: String
    
    /// The last name of the author of the post.
    @Published var lastName: String
    
    /// The class associated with the post.
    var forClass: String
    
    /// The college or university associated with the post.
    var forCollege: String
    
    /// The total votes for the post. This value can be positive or negative.
    var votes: Int64
    
    /// The date and time when the post was created, represented as a Unix timestamp.
    var datePosted: Double = 0.0
    
    /// The set of user phone numbers who have liked the post.
    var usersLiked: Set<String> = []
    
    /// The set of user phone numbers who have disliked the post.
    var usersDisliked: Set<String> = []
    
    /// The URL of the profile picture of the author of the post.
    var profilePicURL: String?

    /// Initializes a new instance of `ClassPost`.
    ///
    /// This constructor is used when reading posts that have already been sent to Firebase.
    ///
    /// - Parameters:
    ///   - postBody: The body of the post.
    ///   - firstName: The first name of the author.
    ///   - lastName: The last name of the author.
    ///   - forClass: The associated class for the post.
    ///   - datePosted: The timestamp when the post was created.
    ///   - votes: The total votes for the post.
    ///   - id: The unique identifier for the post.
    ///   - usersLiked: The set of users who have liked the post.
    ///   - usersDisliked: The set of users who have disliked the post.
    ///   - phoneNumber: The phone number of the author.
    ///   - college: The associated college or university.
    ///   - picURL: The URL of the profile picture of the author.
    init(postBody: String, firstName: String, lastName: String, forClass: String, datePosted: Double, votes: Int64, id: String, usersLiked: Set<String>, usersDisliked: Set<String>, phoneNumber: String, college: String, picURL: String? ) {
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
    
    /// Defines the criteria for equality between two `ClassPost` instances.
    ///
    /// Two `ClassPost` instances are considered equal if all their properties are equal.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side value to compare.
    ///   - rhs: The right-hand side value to compare.
    /// - Returns: `true` if the values are equal, `false` otherwise.
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




