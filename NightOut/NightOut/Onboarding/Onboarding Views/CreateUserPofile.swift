//
//  ProfileSetUp.swift
//  NightOut
//
//  Created by Kyle Zeller on 7/16/22.
// this file may need to keep track of login information
//

import SwiftUI
import Firebase


struct CreateUserProfile: View {
    @State var FirstName: String = ""
    @State var LastName: String = ""
    @State var College: String = ""
    @State private var isReadyForNextView: Bool = false
    @State private var showingAlert: Bool = false
    @StateObject var viewRouter: ViewRouter
    

    var body: some View {
        NavigationView {
            ZStack{
                Color.Gray
                    .ignoresSafeArea()
                VStack(alignment: .leading){
                    Text("Create Your Profile")
                        .font(.system(size: 40))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.Purple)
                        .multilineTextAlignment(.leading)
                    TextField("First Name", text: $FirstName)
                        .autocapitalization(UITextAutocapitalizationType.words)
                        .padding()
                        .background(Color.Gray)
                        .cornerRadius(5.0)
                        
                    TextField("Last Name", text: $LastName)
                        .autocapitalization(UITextAutocapitalizationType.words)
                        .padding()
                        .background(Color.Gray)
                        .cornerRadius(5.0)
                        
                    TextField("Your College" , text: $College)
                        .autocapitalization(UITextAutocapitalizationType.words)
                        .padding()
                        .background(Color.Gray)
                        .cornerRadius(5.0)
                        
                        .padding(.bottom, 20)

                    
                    Button(action: {
                        if FirstName != "" && LastName != "" && College != ""{
                           
                            let user = Auth.auth().currentUser
                            let email = user?.email
                           FirstName = FirstName.trimmingCharacters(in: .whitespacesAndNewlines)
                            LastName = LastName.trimmingCharacters(in: .whitespacesAndNewlines)
                            College = College.trimmingCharacters(in: .whitespacesAndNewlines)
                            OnboardingDatabaseManager.addFirstLastCollegeToDocument(firstName: FirstName, lastName: LastName, college: College, email: email ?? "")
                                
                                //change view
                            viewRouter.CurrentViewState = .UserDataAcquisition
                            
                        } else {
                            self.showingAlert = true
                        }
                    }) {
                        NextButton()
                    }.alert(isPresented: $showingAlert) {
                        Alert(title: Text("Please Answer Prompts"), dismissButton: .default(Text("Got it!")))
                    }
                    Spacer()
                }
                .padding(.leading,20)
                .padding(.trailing,20)
                
            }
        }
        .accentColor(.Purple)
    }
}


struct ProfileSetUp_Previews: PreviewProvider {
    static var previews: some View {
        CreateUserProfile(viewRouter: ViewRouter())
    }
}

struct NextButton: View {
    var body: some View {
        Text("Next")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(Color.Purple)
            .cornerRadius(15.0)
            
    }
}
