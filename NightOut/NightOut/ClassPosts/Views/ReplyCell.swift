//
//  ReplyCell.swift
//  Campus Clique
//
//  Created by Kyle Zeller on 7/28/23.
//

import SwiftUI
import Kingfisher
/// `ReplyView` is a SwiftUI View that provides a layout to display a reply to a class post in the application.
struct ReplyView: View {
    
    // This binding variable allows the reply property to be mutable, meaning it can be changed from outside the struct
    @Binding var reply: Reply  // Represents the reply being displayed

    // This binding variable allows the selectedPost property to be mutable, meaning it can be changed from outside the struct
    @Binding var selectedPost: ClassPost  // Represents the selected post in the context of which the reply was made

    // EnvironmentObject allows the viewModel to be accessed by any child views
    @EnvironmentObject var viewModel: inAppViewVM  // ViewModel providing the needed functions for the view
    
    // A closure that will return true if the given Reply's author is the currently logged in user, false otherwise
    var isAuthorReply: (Reply) -> Bool

    // State variable to control the showing of the delete confirmation alert
    @State private var showingDeleteAlertReply = false
    
    /// Convert epoch time (number of seconds from 1970) to a readable date string
    ///
    /// - Parameter epochTime: The time in epoch format to be converted.
    /// - Returns: A string representing the converted date in a "time ago" format.
    func convertEpochTimeToDate(epochTime: Double) -> String {
        let timeInterval = Date().timeIntervalSince1970 -  epochTime
        let secondsInYear: TimeInterval = 31536000
        let secondsInDay: TimeInterval = 86400
        let secondsInHour: TimeInterval = 3600
        let secondsInMinute: TimeInterval = 60
        
        if timeInterval < secondsInMinute {
            let seconds = Int(timeInterval)
            return "\(seconds) second\(seconds == 1 ? "" : "s") ago"
        } else if timeInterval < secondsInHour {
            let minutes = Int(timeInterval / secondsInMinute)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else if timeInterval < secondsInDay {
            let hours = Int(timeInterval / secondsInHour)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else if timeInterval < secondsInYear {
            let days = Int(timeInterval / secondsInDay)
            return "\(days) day\(days == 1 ? "" : "s") ago"
        } else {
            let years = Int(timeInterval / secondsInYear)
            return "\(years) year\(years == 1 ? "" : "s") ago"
        }
    }
    
    /// Main SwiftUI body that defines the structure and components of the view.
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                // Displaying the author of the post
                HStack {
                    if let urlString = reply.profilePicURL, let url = URL(string: urlString) {
                        KFImage(url)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    }
                    // Displaying the name of the author and the time the reply was posted
                    Text("\(reply.firstName) \(reply.lastName)")
                        .padding(10)
                        .foregroundColor(.cyan)
                        .cornerRadius(10.0)
                    Spacer()
                    Text("\(convertEpochTimeToDate(epochTime: reply.DatePosted))")
                        .foregroundColor(Color.white)
                        .padding(10)
                }
                .padding(.top,10)
                .padding(.leading,5)
                
                // Displaying the body of the reply
                Text("\(reply.replyBody)")
                    .padding(10)
                    .foregroundColor(Color.white)
                    .cornerRadius(5.0)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading) // Push text all the way to the left
                
                // Buttons for voting and deleting the reply
                HStack {
                    // Displaying the number of votes on the post
                    Text("\(reply.votes)")
                        .foregroundColor(.cyan)
                    
                    // Button for upvoting the post
                    Button(action: {
                        DispatchQueue.main.async {
                            viewModel.handleVoteOnReply(.up, onPost: selectedPost, onReply: reply)
                        }
                    }) {
                        Image(systemName: "chevron.up")
                    }
                    .padding(10)
                    .buttonStyle(BorderlessButtonStyle())
                    .foregroundColor(reply.UsersLiked.contains(viewModel.userDoc.phoneNumber ) ? Color.green : Color.gray)
                    .cornerRadius(10)
                    .disabled(viewModel.isVotingInProgress) // this is done to allow correct voting on firebase
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.cyan, lineWidth: 1)
                    )
                    
                    // Button for downvoting the post
                    Button(action: {
                        DispatchQueue.main.async {
                            viewModel.handleVoteOnReply(.down, onPost: selectedPost, onReply: reply)
                        }
                    }) {
                        Image(systemName: "chevron.down")
                    }
                    .padding(10)
                    .buttonStyle(BorderlessButtonStyle())
                    .foregroundColor(reply.UserDownVotes.contains(viewModel.userDoc.phoneNumber ) ? Color.red : Color.gray)
                    .cornerRadius(10)
                    .disabled(viewModel.isVotingInProgress) // this is done to allow correct voting on firebase
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.cyan, lineWidth: 1)
                    )
                    
                    // Spacer to push the delete button to the right of the screen
                    Spacer()
                    // Button for deleting the reply
                    Button(action: {
                        showingDeleteAlertReply = true
                    }) {
                        Image(systemName: "trash")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding()
                            .foregroundColor(.red)
                            .cornerRadius(10)
                    }
                    // Alert for confirming the delete action
                    .alert(isPresented: $showingDeleteAlertReply) {
                        Alert(
                            title: Text("Delete Reply"),
                            message: Text("Are you sure you want to delete this reply?"),
                            primaryButton: .destructive(Text("Delete")) {
                                viewModel.deleteReply(reply, fromPost: selectedPost)
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    .opacity(isAuthorReply(reply) ? 1.0 : 0.0)  // Adjusts the opacity based on whether the post is authored by the current user
                    .disabled(!isAuthorReply(reply))  // Disables the button for posts not authored by the current user
                }
                .padding(.leading,10)
                .padding(.trailing,10)
            }
            .background(Color.Gray)
            .padding(.top,1)
        }
    }
}



