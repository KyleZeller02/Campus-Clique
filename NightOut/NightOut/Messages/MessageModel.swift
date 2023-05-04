//
//  MessageModel.swift
//  NightOut
//
//  Created by Kyle Zeller on 5/4/23.
//

import Foundation

struct Message:Hashable {
    var sender: String
    var receivers: Set<String>
    var messageBody: String
    var Timestamp: Double
    
    //constructor
    init(sender: String, receivers: Set<String>, messageBody: String) {
        self.sender = sender
        self.receivers = receivers
        self.messageBody = messageBody
        self.Timestamp = Date().timeIntervalSince1970
        
    }
}
