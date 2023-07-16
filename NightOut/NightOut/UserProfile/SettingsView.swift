//
//  SettingsView.swift
//  Campus Clique
//
//  Created by Kyle Zeller on 6/5/23.
//

import SwiftUI

struct SettingsView: View {
    @State private var isShowingEditProfileView = false
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("showOnboarding") var showOnboarding: Bool = false
    @EnvironmentObject var inAppVM: inAppViewVM
    
    var body: some View {
        ZStack {
            Color.Black
                .ignoresSafeArea()
            
            VStack {
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
                
                Text("Settings")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.bottom, 50)
                
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
                
                Button(action: {
                    AccountActions.deleteAccount()
                    inAppVM.removeAllPostsFromUser()
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
