//
//  TabBarItem.swift
//  CustomTabBar
//
//  Created by Kyle Zeller on 6/7/23.
//

import Foundation
import SwiftUI


enum TabBarItem:Hashable{
    case posts, profile
    
    var iconName:String{
        switch self{
        case.posts: return "list.bullet"
        
        case.profile: return "person"
        }
    }
    
    var title:String{
        switch self{
        case.posts: return "Posts"
       
        case.profile: return "Profile"
        }
    }
    var color:Color{
        switch self{
        case.posts: return Color.cyan
       
        case.profile: return Color.cyan
        }
    }
}


