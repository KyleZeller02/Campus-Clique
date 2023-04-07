//
//  UserProfileSetUp.swift
//  NightOut
//
//  Created by Kyle Zeller on 7/16/22.
//

import SwiftUI

struct UserDataAcquisition: View {
    @StateObject var viewRouter: ViewRouter
    @State private var showingAlert: Bool = false
    
    @State var Major: String = ""
    // Classes will need to be parsed to a string array
    @State var Classes: String = ""
    var body: some View {
        ZStack{
            Color.Gray
                .ignoresSafeArea()
            VStack{
                Spacer()
                Text("About You")
                    .font(.system(size: 40))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.Purple)
                    .multilineTextAlignment(.center)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                Text("Declared Major: if undecided type Undecided")
                Text("Use a comma to seperate your Majors if you have multiple")
                TextField("Major", text: $Major)
                    .autocapitalization(UITextAutocapitalizationType.words)
                    .padding()
                    .background(Color.Gray)
                    .cornerRadius(5.0)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                Text("What classes are you taking? Type the class as it shows on your schedule, ie: CIS115, ECON110")
                Text("Use a comma to seperate your classes")
                TextField("Classes", text: $Classes)
                    .autocapitalization(UITextAutocapitalizationType.words)
                    .padding()
                    .background(Color.Gray)
                    .cornerRadius(5.0)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                
                Spacer()
                Button(action:
                        {
                    if Major != "" , Classes != ""{
                        //if user gives data, upload data to document in firebase
                        let email = Settings.Email
                        OnboardingDatabaseManager.addClassesMajorToDocument(Classes: Classes, Major: Major, email: email)
                        //change state
                        viewRouter.CurrentViewState = .UserBirthdayAcquistion
                    }
                    //if there is missing data from user, show alert
                    else{
                        self.showingAlert = true
                    }
                }) {
                    NextButton()
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Please Answer Prompts"), dismissButton: .default(Text("Got it!")))
                }
            }
        }
        
    }
}

struct UserProfileSetUp_Previews: PreviewProvider {
    static var previews: some View {
        UserDataAcquisition(viewRouter:ViewRouter())
    }
}
