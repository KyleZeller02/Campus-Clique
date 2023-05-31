//
//  UserBirthdayAcquisition.swift
//  NightOut
//
//  Created by Kyle Zeller on 8/21/22.
//

import SwiftUI
import Firebase

struct UserBirthdayAcquisition: View {
    @State private var birthday: String = ""
    @State private var profileViewIsActive = false
    @StateObject  var viewRouter: ViewRouter
    @State private var showingAlert = false
    
    var body: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 40) {
              
                
                Text("Date of Birth")
                    .font(.system(size: 40))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                TextField("02/01/2002", text: $birthday)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5.0)
                    .padding(.top)
                
                Button(action: {
                    if !birthday.isEmpty {
                        let user = Auth.auth().currentUser
                        if let user = user {
                            let email = user.email
                            let trimmedBirthday = birthday.trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            OnboardingDatabaseManager.addBirthdayToDocument(birthday: trimmedBirthday, email: email ?? "")
                            viewRouter.CurrentViewState = .ProfilePictureAcquisition
                        }
                    } else {
                        self.showingAlert = true
                    }
                }) {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [.Purple, .Black]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Please Answer Prompts"), dismissButton: .default(Text("Got it!")))
                }
                
                Spacer() // Occupies remaining space
            }
            .padding(.horizontal, 20)
        }
    }
}


struct UserBirthdayAcquisition_Previews: PreviewProvider {
    static var previews: some View {
        UserBirthdayAcquisition(viewRouter: ViewRouter())
    }
}
struct MakeProfile: View {
    var body: some View {
        Text("Make Account")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(LinearGradient(gradient: Gradient(colors: [.Purple, .Black]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(15.0)
    }
}
