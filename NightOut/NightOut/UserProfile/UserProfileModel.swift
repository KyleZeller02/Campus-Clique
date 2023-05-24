//
//  UserData.swift
//  NightOut
//
//  Created by Kyle Zeller on 8/20/22.
//

import Foundation
import SwiftUI

/// this struct currently does not have a use, but might so I will keep it around
/// -Kyle Zeller Thursday Dec 22
class UserDocument:Identifiable,ObservableObject{
    
    /// Properties for the UserDocument, htey are set in the constructor, except for FullName, it is a computed property
    var FirstName: String
    var LastName: String
    var College: String
    var Birthday: String
    var Major: [String]
    var Classes: [String]?
    var Email: String
    var FullName:String{
        return "\(FirstName) \(LastName)"
    }
    
    
    
    /// constructor for the user document
    init(FirstName: String, LastName: String, College: String, Birthday: String, Major: [String], Classes: [String], Email: String ) {
        self.FirstName = FirstName
        self.LastName = LastName
        self.College = College
        self.Birthday = Birthday
        self.Major = Major
        self.Classes = Classes
        self.Email = Email
    }
    
    
    
}
