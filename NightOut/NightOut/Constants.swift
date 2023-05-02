//
//  Constants.swift
//  NightOut
//
//  Created by Kyle Zeller on 1/10/23.
//

import Foundation
import SwiftUI

struct ProgramConstants{
     static let AppName = "NightOut"
    //Cmapus Clique
    
    
}
extension Color {
    static let Purple = Color(red: 62/255, green:84/255 , blue: 172/255)
    static let White = Color(red: 238/255, green: 238/255, blue: 238/255)
    static let Gray = Color(red: 120/255, green: 122/255, blue: 145/255, opacity:0.5)
    static let Black = Color(red:5/255, green: 5/255, blue: 5/255, opacity: 1.0)
    
    
    
}

protocol ColorScheme {
    var background: Color {get}
    var buttons: Color {get}
    var textColor: Color {get}
    var foreground: Color {get}
}

enum Colors{
    case LightMode
    case DarkMode
}

struct LightColorScheme{
    var background: Color = Color.Black
    
    var buttons: Color = Color.Black
    
    var textColor: Color = Color.Black
    
    var foreground: Color = Color.Black
    
    
}

struct DarkColorScheme{
    
    var background: Color = Color.Black
    
    var buttons: Color = Color.Purple
    
    var textColor: Color =  Color.White
    
    var foreground: Color = Color.Gray
    
    
}
