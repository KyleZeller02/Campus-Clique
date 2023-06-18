//
//  UserData.swift
//  NightOut
//
//  Created by Kyle Zeller on 8/20/22.
//

import Foundation
import SwiftUI


class UserDocument: Identifiable, ObservableObject {
    // Properties for the UserDocument
    var FirstName: String
    var LastName: String
    var College: String
    var Birthday: String
    var Major: String
    var Classes: [String]
    var Email: String
   
    var profilePictureURL: String?
    
    var FullName: String {
        return "\(FirstName) \(LastName)"
    }
    
    init(FirstName: String, LastName: String, College: String, Birthday: String, Major: String, Classes: [String], Email: String, profilePictureURL: String?) {
        self.FirstName = FirstName
        self.LastName = LastName
        self.College = College
        self.Birthday = Birthday
        self.Major = Major
        self.Classes = Classes
        self.Email = Email
        self.profilePictureURL = profilePictureURL
    }
}

