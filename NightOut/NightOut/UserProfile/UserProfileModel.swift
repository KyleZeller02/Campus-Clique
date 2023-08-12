//
//  UserData.swift
//  NightOut
//
//  Created by Kyle Zeller on 8/20/22.
//

import Foundation
import SwiftUI


/// Represents a User Document.
///
/// This class provides a structured representation of a User, including the user's first name, last name, college, major, classes, phone number and profile picture URL.
class UserDocument: Identifiable, ObservableObject {
    // MARK: - Properties
    
    /// The user's first name.
    var firstName: String
    
    /// The user's last name.
    var lastName: String
    
    /// The college that the user attends.
    var college: String
    
    /// The user's major field of study.
    var major: String
    
    /// The list of classes the user is currently taking.
    var classes: [String]
    
    /// The user's phone number.
    var phoneNumber: String
    
    /// The URL for the user's profile picture.
    var profilePictureURL: String?
    
    /// The user's full name, constructed by concatenating the first and last name.
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    var blockedUsers: Set<String>
    
    // MARK: - Initialization
    
    /// Creates a new User Document.
    ///
    /// - Parameters:
    ///   - firstName: The user's first name.
    ///   - lastName: The user's last name.
    ///   - college: The college that the user attends.
    ///   - major: The user's major field of study.
    ///   - classes: The list of classes the user is currently taking.
    ///   - phoneNumber: The user's phone number.
    ///   - profilePictureURL: The URL for the user's profile picture.
    init(firstName: String, lastName: String, college: String, major: String, classes: [String], phoneNumber: String, profilePictureURL: String?, usersBlocked: Set<String>) {
        self.firstName = firstName
        self.lastName = lastName
        self.college = college
        self.major = major
        self.classes = classes
        self.phoneNumber = phoneNumber
        self.profilePictureURL = profilePictureURL
        self.blockedUsers = usersBlocked
    }
}

