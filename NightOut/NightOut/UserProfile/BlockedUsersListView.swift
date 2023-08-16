//
//  BlockedUsersListView.swift
//  Campus Clique
//
//  Created by Kyle Zeller on 8/14/23.
//

import SwiftUI

/// `BlockedUsersListView`
/// A SwiftUI View that shows a list of blocked users, fetched from Firestore.
/// Users have the option to unblock any of the listed users, and the view provides
/// a "Back" button to dismiss itself.
///
/// - Note:
///   - `blockedUsers`: A dictionary containing the phone numbers and names of blocked users.
///   - `firebaseManager`: A Firestore service object to handle the fetching of blocked users.
///   - `vm`: A view model object that contains the logic to handle the unblocking process.
///
struct BlockedUsersListView: View {
    @Environment(\.presentationMode) var presentationMode // To handle the dismissing of this view
    @EnvironmentObject var vm: inAppViewVM // The view model for handling unblock actions
    @State var blockedUsers: [String: String] = [:] // State variable to hold the blocked users
    let firebaseManager = FirestoreService() // Firestore service to fetch blocked users

    var body: some View {
        NavigationView {
            Group {
                // If there are no blocked users, display a message
                if blockedUsers.isEmpty {
                    Text("You don't have anyone blocked")
                        .font(.headline)
                        .padding()
                } else {
                    // List the blocked users
                    List {
                        ForEach(Array(blockedUsers.keys), id: \.self) { phoneNumber in
                            let user = blockedUsers[phoneNumber] ?? "unknown user" // Retrieve user's name or set a default value
                            HStack {
                                Text(user) // Display user's name
                                    .font(.headline)

                                Spacer()

                                // Unblock button with the associated action
                                Button(action: {
                                    vm.handleUnblock(unblocking: phoneNumber) { result in
                                        switch result {
                                        case .success:
                                            blockedUsers.removeValue(forKey: phoneNumber) // Remove the unblocked user
                                        case .failure(let error):
                                            print("Failed to unblock user \(user): \(error)") // Print an error message
                                        }
                                    }
                                }) {
                                    Text("Unblock")
                                        .foregroundColor(.red)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 5)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.red, lineWidth: 1)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding()
                        }
                    }
                }
            }
            .padding(.bottom, 20)
            .navigationBarTitle("Blocked Users", displayMode: .inline)
            .toolbar {
                // Back button to dismiss the view
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Back")
                            .foregroundColor(.cyan)
                            .font(.system(size: 18))
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            // Fetch the blocked users when the view appears
            firebaseManager.fetchBlockedUsers(users: vm.userDoc.blockedUsers) { dict in
                self.blockedUsers = dict
            }
        }
    }
}




//struct BlockedUsersListView_Previews: PreviewProvider {
//    static var previews: some View {
//        BlockedUsersListView()
//    }
//}
