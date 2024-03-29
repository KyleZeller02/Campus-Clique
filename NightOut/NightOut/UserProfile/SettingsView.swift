//
//  SettingsView.swift
//  Campus Clique
//
//  Created by Kyle Zeller on 6/5/23.
//

import SwiftUI

/// SettingsView represents the settings page of the Campus Clique app.
///
/// It allows the user to navigate to the Edit Profile view, log out, and delete their account.
struct SettingsView: View {
    /// Indicates whether the EditProfileView is presented.
    @State private var isShowingEditProfileView = false
    /// indicates whether the BlockedUsersListView is presented
    @State private var isShowingBlockedUsersView = false
    
    /// The mechanism to dismiss the view.
    @Environment(\.presentationMode) var presentationMode
    
    /// Indicates whether the onboarding view is shown.
    @AppStorage("showOnboarding") var showOnboarding: Bool = false
    
    /// ViewModel that manages the app's shared state.
    @EnvironmentObject var inAppVM: inAppViewVM
    
    /// Instance of FirestoreService to manage Firebase operations.
    let firebaseManager = FirestoreService()
    
    var body: some View {
        ZStack {
            // Background color.
            Color.black
                .ignoresSafeArea()
            
            VStack {
                // Button to dismiss the view.
                HStack {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding()
                
                // Title of the view.
                Text("Settings")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.bottom, 50)
                
                // Button to navigate to the Edit Profile view.
                Button(action: {
                    self.isShowingEditProfileView = true
                }) {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                        Text("Edit Profile")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.cyan, lineWidth: 4)
                    )
                    .cornerRadius(10)
                }
                .padding(.horizontal, 10)
                .fullScreenCover(isPresented: $isShowingEditProfileView, content: {
                    EditProfileView()
                        .environmentObject(inAppVM)
                })
                
                
                
                // Button to delete the account.
                Button(action: {
                    // Action to navigate to the blocked users list or perform the blocking operation
                    self.isShowingBlockedUsersView = true
                }) {
                    HStack {
                        Image(systemName: "person.badge.minus") // Image representing blocking a user
                            .foregroundColor(.white)
                        Text("Blocked Users")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.Black)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.cyan, lineWidth: 4)
                    )
                    .cornerRadius(10)
                }
                .fullScreenCover(isPresented: $isShowingBlockedUsersView, content: {
                    BlockedUsersListView()
                        .environmentObject(inAppVM)
                })

                .padding(.horizontal, 10)
                
                // Button to log out.
                Button(action: {
                    AccountActions.LogOut()
                    showOnboarding = true
                }) {
                    HStack {
                        Image(systemName: "power")
                            .foregroundColor(.white)
                        Text("Log Out")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.cyan, lineWidth: 4)
                    )
                    .cornerRadius(10)
                }
                .padding(.horizontal, 10)
                // Button to delete the account.
                Button(action: {
                    inAppVM.removeAllPostsFromUser(){ (success, error) in
                        if success {
                            firebaseManager.deleteOldProfilePictureFromFirestore(forPhoneNumber: inAppVM.userDoc.phoneNumber){(res, err) in
                                if res{
                                    print("profile picture deleted")
                                    AccountActions.deleteAccount(usersPhoneNumber: inAppVM.userDoc.phoneNumber)
                                }
                                if let err = err{
                                    print("Error: \(err.localizedDescription)")
                                }
                            }
                            
                        }
                    }
                    showOnboarding = true
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.white)
                        Text("Delete Account")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 10)
                
                
                
                
                Spacer()
            }
        }
    }
}

/// A PreviewProvider for the SettingsView.
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

