//  ClassPostCell.swift
//  Campus Clique
//
//  Created by Kyle Zeller on 7/28/23.
//

import SwiftUI
import Kingfisher
import FirebaseAuth

/// A view representing a single post cell in the app.
struct PostCellView: View {
    @State private var showingDeleteAlert = false
    
    /// The selected post to be displayed in the cell.
    var selectedPost: ClassPost // Replace `ClassPost` with your actual data type
    
    /// The view model for the entire app.
    @EnvironmentObject var viewModel: inAppViewVM // Replace `inAppViewVM` with your actual view model data type
    
    
    
    @Binding var showingReportPostSheet:Bool // this variable is held in the detail view, will show alert to report
    
    @Binding var showingReportPostActionSheet: Bool
    
    @State private var showingBlockUserAlert = false
    
    /// View's body property defining the layout and content of the post cell.
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                // Post author information
                HStack {
                    // Profile image of the post author
                    if let urlString = selectedPost.profilePicURL, let url = URL(string: urlString) {
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
                    // Post author's full name
                    Text("\(selectedPost.firstName) \(selectedPost.lastName)")
                        .padding(10)
                        .foregroundColor(.cyan)
                        .cornerRadius(10.0)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    // Time since the post was posted
                    Text("\(convertEpochTimeToDate(epochTime: selectedPost.datePosted))")
                        .foregroundColor(Color.white)
                        .padding(10)
                }
                .padding(.top, 10)
                .padding(.leading, 5)
                
                // Post body with rounded background color
                Text("\(selectedPost.postBody)")
                    .padding(10)
                    .foregroundColor(Color.white)
                    .cornerRadius(5.0)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                
                // Vote buttons for upvoting and downvoting
                HStack {
                    // Display the number of votes on the post
                    Text("\(selectedPost.votes)")
                        .foregroundColor(.cyan)
                    
                    // Upvote button
                    Button(action: {
                        DispatchQueue.main.async {
                            viewModel.handleVoteOnPost(UpOrDown: VoteType.up, onPost: selectedPost)
                        }
                    }) {
                        Image(systemName: "chevron.up")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .padding(10)
                    .foregroundColor(selectedPost.usersLiked.contains(viewModel.userDoc.phoneNumber) ? Color.green : Color.gray)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.cyan, lineWidth: 1)
                    )
                    .disabled(viewModel.isVotingInProgress) // this is done to allow correct voting on firebase
                    
                    // Downvote button
                    Button(action: {
                        DispatchQueue.main.async {
                            viewModel.handleVoteOnPost(UpOrDown: VoteType.down, onPost: selectedPost)
                        }
                    }) {
                        Image(systemName: "chevron.down")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .padding(10)
                    .foregroundColor(selectedPost.usersDisliked.contains(viewModel.userDoc.phoneNumber) ? Color.red : Color.gray)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.cyan, lineWidth: 1)
                    )
                    .disabled(viewModel.isVotingInProgress) // this is done to allow correct voting on firebase
                    
                    // Button for reporting the reply
                            Button(action: {
                                // When the button is tapped, it sets a state variable to true, triggering an action sheet for reporting
                                showingReportPostActionSheet = true
                            }) {
                                // Displays an image for the report button (exclamation mark inside a triangle)
                                    Image(systemName: "flag")
                                        .resizable() // Makes the image resizable
                                        .frame(width: 20, height: 20) // Sets the width and height of the image
                                        .padding() // Adds padding around the image
                                        .foregroundColor(.yellow) // Sets the foreground color to yellow
                                        .cornerRadius(10)
                            }
                            .opacity(isAuthorPost(ofPost: selectedPost) ? 0.0 : 1.0)  // Adjusts the opacity based on whether the post is authored by the current user
                            .disabled(isAuthorPost(ofPost: selectedPost))
                            .actionSheet(isPresented: $showingReportPostActionSheet) {
                                ActionSheet(title: Text("What would you like to do?"),
                                            buttons: [
                                                .default(Text("Report Content"), action: {
                                                    showingReportPostSheet = true
                                                }),
                                                .destructive(Text("Block User"), action: {
                                                    // Trigger the alert for blocking the user
                                                    showingBlockUserAlert = true
                                                }),
                                                .cancel()
                                            ])
                            }
                            .sheet(isPresented: $showingReportPostSheet) {
                                ReportSheet(postable: selectedPost).environmentObject(viewModel)
                            }
                            .alert(isPresented: $showingBlockUserAlert) {
                                Alert(
                                    title: Text("Block User"),
                                    message: Text("Are you sure you want to block this user?"),
                                    primaryButton: .destructive(Text("Block"), action: {
                                        
                                        // Add the action to actually block the user here
                                        
                                        viewModel.handleBlockUser(userToBlockPhoneNumber: selectedPost.phoneNumber)
                                    }),
                                    secondaryButton: .cancel()
                                )
                            }
                    
                    Spacer()
                    
                    // Delete post button (visible only to the post author)
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding()
                            .foregroundColor(.red)
                            .cornerRadius(10)
                    }
                    .alert(isPresented: $showingDeleteAlert) {
                        Alert(
                            title: Text("Delete Post"),
                            message: Text("Are you sure you want to delete this post?"),
                            primaryButton: .destructive(Text("Delete")) {
                                viewModel.deletePostAndReplies(selectedPost)
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    .opacity(isAuthorPost(ofPost: selectedPost) ? 1.0 : 0.0) // Adjusts the opacity based on whether the post is authored by the current user
                    .disabled(!isAuthorPost(ofPost: selectedPost))
                }
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .cornerRadius(15)
            }
            .background(Color.Gray)
            .padding(.top, 1)
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
        .cornerRadius(10)
    }
}

/// Determines if the current user is the author of a post.
/// - Parameter ofPost: The post to check authorship for.
/// - Returns: A boolean value indicating whether the current user is the author of the post.
func isAuthorPost(ofPost post: ClassPost) -> Bool {
    // Get the current user from Firebase Authentication
    let user = Auth.auth().currentUser
    let phoneNumber = user?.phoneNumber // Get the phone number of the current user
    
    // Compare the phone number of the current user with the phone number of the post's author
    // If they match, then the current user is the author of the post
    return phoneNumber == post.phoneNumber
}

/// Determines if the current user is the author of a reply.
/// - Parameter ofReply: The reply to check authorship for.
/// - Returns: A boolean value indicating whether the current user is the author of the reply.
func isAuthorReply(ofReply reply: Reply) -> Bool {
    // Get the current user from Firebase Authentication
    let user = Auth.auth().currentUser
    let phoneNumber = user?.phoneNumber // Get the phone number of the current user
    
    // Compare the phone number of the current user with the phone number of the reply's author
    // If they match, then the current user is the author of the reply
    return phoneNumber == reply.phoneNumber
}

/// Converts an epoch time (in seconds) to a human-readable time interval string, indicating how long ago the given time was compared to the current time.
/// - Parameter epochTime: The epoch time in seconds to convert.
/// - Returns: A string representing the time interval between the given epoch time and the current time in human-readable format (e.g., "2 minutes ago", "1 day ago").
func convertEpochTimeToDate(epochTime: Double) -> String {
    // Calculate the time interval between the current time and the given epoch time.
    let timeInterval = Date().timeIntervalSince1970 - epochTime
    
    // Constants representing the number of seconds in a year, day, hour, and minute.
    let secondsInYear: TimeInterval = 31536000
    let secondsInDay: TimeInterval = 86400
    let secondsInHour: TimeInterval = 3600
    let secondsInMinute: TimeInterval = 60
    
    // Compare the time interval with different time periods and return the appropriate human-readable string.
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
