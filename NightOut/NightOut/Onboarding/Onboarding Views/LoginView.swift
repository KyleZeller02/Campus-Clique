//
//  ContentView.swift
//  NightOut
//
//  Created by Kyle Zeller on 7/9/22.
//

import SwiftUI
import Firebase
//this is the initial view the user sees, if there is no user storage showing they are already logged in
struct LoginView: View {
    @State var email: String = ""
    @State var password: String = ""
    @StateObject var viewRouter: ViewRouter
    @State private var showingAlert: Bool = false
    
    var body: some View {
        ZStack{
            Color.Gray
                .ignoresSafeArea()
            VStack {
                //app tital
                Title()
                // this image(Logo) is a place holder for the app logo
                Logo()
                //username field
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.Gray)
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                //password field
                SecureField("Password", text: $password)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.Gray)
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                
                //Login Button
                Button(action:
                        {
                    
                    if  !email.isEmpty, !password.isEmpty {
                        //attempt login
                        Auth.auth().signIn(withEmail: email, password: password) {  authResult, error in
                            //if there is an error, print the error
                            if let error = error{
                                
                                print(error.localizedDescription)
                            }
                            //otherwise, save the email, change the view
                            else{
                                //saves email to Settings struct
                                
                                //changes view
                                viewRouter.CurrentViewState = .InAppViews
                            }
                        }
                    }
                    // if either email or password is empty string, show alert to user asking to fill in data
                    else{
                        self.showingAlert = true
                    }
                }
                       
                ){
                    LoginButton()
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Enter Email and Password"), dismissButton: .default(Text("Got it!")))
                    
                }
                
                //sign up button
                Button(action:
                        //if user has provided some data,
                       { if  !email.isEmpty, !password.isEmpty {
                           //attempt to create user
                           Auth.auth().createUser(withEmail: email, password: password) {  authResult, error in
                               //if there is an error, print the error
                               if let e = error{
                                   print(e.localizedDescription)
                               }
                               //if there is no error, save email to Setting struct, add document to "Users" collection in firebase, change view
                               else{
                                   //saves the email in app storage
                                   
                                   //creates a user document with email
                                   OnboardingDatabaseManager.addDocumentWithEmail(email: email)
                                   //send the data to firebase
                                   viewRouter.CurrentViewState = .CreateUserProfile
                               }
                               
                           }
                       }
                    //if user has not given email or password, show alert
                    else
                    {
                        self.showingAlert = true
                    }
                }
                ) {
                    SIGNUP()
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Enter Email and Password"), dismissButton: .default(Text("Got it!")))
                    
                }
                
                
                
            } .padding()
            
        }
        .onAppear{
            let user = Auth.auth().currentUser
            if user != nil{
                viewRouter.CurrentViewState = .InAppViews
            }
       
    }
    }
        
        
        
    
}
    

struct ContentView_Previews: PreviewProvider{
    static var previews: some View{
        LoginView(viewRouter: ViewRouter())
    }
}

struct Title: View {
    var body: some View {
        Text("\(ProgramConstants.AppName)")
            .font(.system(size: UIScreen.main.bounds.width * 0.2))
            .minimumScaleFactor(0.1)
            .lineLimit(1)
            .padding(.bottom, 20)
            .foregroundColor(Color.Purple)

    }
}



struct Logo: View {
    var body: some View {
        Image("AppLogo")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 150, height: 150)
            .clipped()
            .cornerRadius(150)
            .padding()
            
    }
}

struct LoginButton: View {
    var body: some View {
        Text("LOGIN")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(.indigo)
            .cornerRadius(15.0)
    }
}

struct SIGNUP: View {
    var body: some View {
        Text("SIGN UP")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(.indigo)
            .cornerRadius(15.0)
    }
}
struct LoginWithAppleID: View {
    var body: some View {
        Text("Login With Apple ID")
            .font(.system(size:12))
            .foregroundColor(.white)
            .padding()
            .frame(width: 190, height: 60)
            .background(.indigo)
            .cornerRadius(15.0)
    }
}

struct LoginWithPhoneNumber: View {
    var body: some View {
        Text("Login With Phone Number")
            .font(.system(size:12))
            .foregroundColor(.white)
            .padding()
            .frame(width: 190, height: 60)
            .background(.indigo)
            .cornerRadius(15.0)
    }
}

