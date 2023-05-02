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
    @State private var User:Bool = false
    @StateObject var viewRouter: ViewRouter
    @State private var showingAlert: Bool = false
    
    
    
    var body: some View {
        ZStack{
            Color.Gray
                .ignoresSafeArea()
            VStack{
                Spacer()
                Text("Create Your Profile")
                    .font(.system(size: 40))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.Purple)
                    .multilineTextAlignment(.center)
                TextField("First Name", text: $FirstName)
                    .autocapitalization(UITextAutocapitalizationType.words)
                    .padding()
                    .background(Color.Gray)
                    .cornerRadius(5.0)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                TextField("Last Name", text: $LastName)
                    .autocapitalization(UITextAutocapitalizationType.words)
                    .padding()
                    .background(Color.Gray)
                    .cornerRadius(5.0)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                //I want the college to be a search and select like how crowdmark did
                TextField("Your College Initials, ie KSU", text: $College)
                    .autocapitalization(UITextAutocapitalizationType.words)
                    .padding()
                    .background(Color.Gray)
                    .cornerRadius(5.0)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                Spacer()
                Button(action:
                        { if FirstName != "" && LastName != "" && College != ""{
                            //add data to document
                            let user = Auth.auth().currentUser
                            if let user = user{
                                let email = user.email
                                OnboardingDatabaseManager.addFirstLastCollegeToDocument(firstName: FirstName, lastName: LastName, college: College, email: email ?? "")
                                //change view
                            viewRouter.CurrentViewState = .UserDataAcquisition
                            }
                           
                        }
                    //if there is missing data, show alert
                    else{
                        self.showingAlert = true
                    }
                }
                ) {
                    NextButton()
                }.alert(isPresented: $showingAlert) {
                    Alert(title: Text("Please Answer Prompts"), dismissButton: .default(Text("Got it!")))
                    
                }
        }
        }
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
            .background(.indigo)
            .cornerRadius(15.0)
    }
}
