//
//  UserProfileSetUp.swift
//  NightOut
//
//  Created by Kyle Zeller on 7/16/22.
//

import SwiftUI
import Firebase

struct UserDataAcquisition: View {
    @StateObject var viewRouter: ViewRouter
    @State private var showingAlert: Bool = false
    
    @State var Major: String = ""
    // Classes will need to be parsed to a string array
    @State var Class1: String = ""
    @State var Class2: String = ""
    @State var Class3: String = ""
    @State var Class4: String = ""
    @State var Class5: String = ""
    @State var Class6: String = ""
    @State private var navigateToNext = false
    
    
    var body: some View {
       
            
            ZStack{
                Color.Gray
                    .ignoresSafeArea()
                VStack(alignment:.leading){
                    
                    Text("Major and Classes")
                        .font(.system(size: 40))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.Black)
                        .multilineTextAlignment(.center)
                    
                    
                    TextField("Your major (or Undecided)", text: $Major)
                        .autocapitalization(UITextAutocapitalizationType.words)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(5.0)
                    
                    Text("Enroll in up to 6 classes")
                    
                    VStack(spacing: 0){
                        VStack(spacing: 0){
                            HStack(spacing: 0){
                                TextField("CIS115", text: $Class1)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(5.0)
                                    .padding(.bottom, 20)
                                    .padding(.trailing,10)
                                    .minimumScaleFactor(0.7)
                                    .autocapitalization(.allCharacters)
                                TextField("ECON500", text: $Class2)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(5.0)
                                    .padding(.bottom, 20)
                                    .padding(.trailing,10)
                                    .minimumScaleFactor(0.7)
                                    .autocapitalization(.allCharacters)
                                TextField("MRK367", text: $Class3)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(5.0)
                                    .padding(.bottom, 20)
                                    .padding(.trailing,10)
                                    .minimumScaleFactor(0.7)
                                    .autocapitalization(.allCharacters)
                            }
                        }
                        VStack(spacing: 0){
                            HStack(spacing: 0){
                                TextField("MATH222", text: $Class4)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(5.0)
                                    .padding(.bottom, 20)
                                    .padding(.trailing,10)
                                    .minimumScaleFactor(0.7)
                                    .autocapitalization(.allCharacters)
                                TextField("ARCH435", text: $Class5)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(5.0)
                                    .padding(.bottom, 20)
                                    .padding(.trailing,10)
                                    .minimumScaleFactor(0.7)
                                    .autocapitalization(.allCharacters)
                                TextField("BIO349", text: $Class6)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(5.0)
                                    .padding(.bottom, 20)
                                    .padding(.trailing,10)
                                    .minimumScaleFactor(0.7)
                                    .autocapitalization(.allCharacters)
                            }
                        }
                        
                    }
                    
                    
                    Button(action: {
                                            if Major != "" , Class1 != ""{
                                                //if user gives data, upload data to document in firebase
                                                let user = Auth.auth().currentUser
                                                if let user = user{
                                                    let email = user.email
                                                    let Major = Major.trimmingCharacters(in: .whitespacesAndNewlines)
                                                    Class1 = Class1.trimmingCharacters(in: .whitespacesAndNewlines)
                                                    Class2 = Class2.trimmingCharacters(in: .whitespacesAndNewlines)
                                                    Class3 = Class3.trimmingCharacters(in: .whitespacesAndNewlines)
                                                    Class4 = Class4.trimmingCharacters(in: .whitespacesAndNewlines)
                                                    Class5 = Class5.trimmingCharacters(in: .whitespacesAndNewlines)
                                                    Class6 = Class6.trimmingCharacters(in: .whitespacesAndNewlines)
                                                    var classes = [Class1, Class2, Class3, Class4, Class5, Class6]
                                                    classes = classes.filter { !$0.isEmpty }
                                                    let classesString = classes.joined(separator: ", ")

                                                    
                                                    OnboardingDatabaseManager.addClassesMajorToDocument(Classes: classesString, Major: Major, email: email ?? "")
                                                //trigger navigation
                                                    viewRouter.CurrentViewState = .UserBirthdayAcquistion
                                                }
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
                                        
                                        Spacer()
                                    }
                                    .padding(.leading,20)
                                    .padding(.trailing,20)
                
            
            
        }
    }
}

struct UserProfileSetUp_Previews: PreviewProvider {
    static var previews: some View {
        UserDataAcquisition(viewRouter:ViewRouter())
    }
}
