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
    
    var Major: String
    var Classes: [String]
    var PhoneNumber: String
   
    var profilePictureURL: String?
    
    var FullName: String {
        return "\(FirstName) \(LastName)"
    }
    
    init(FirstName: String, LastName: String, College: String,  Major: String, Classes: [String], phoneNumber: String, profilePictureURL: String?) {
        self.FirstName = FirstName
        self.LastName = LastName
        self.College = College
       
        self.Major = Major
        self.Classes = Classes
        self.PhoneNumber = phoneNumber
        self.profilePictureURL = profilePictureURL
    }
}

