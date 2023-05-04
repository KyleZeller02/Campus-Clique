//
//  ConversationModel.swift
//  NightOut
//
//  Created by Kyle Zeller on 5/4/23.
//

import Foundation

class Conversation: ObservableObject{
    //the messages being sent back and forth
    @Published var conversation: Set<Message> = Set()
    
    var sender: String
    var receiver: String
    
    init(sender: String, receiver: String) {
        self.sender = sender
        self.receiver = receiver
    }
    
    func AddMessageToConversation(message: Message){
        
    }
    
    
}
