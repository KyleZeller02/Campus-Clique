//
//  ContentView.swift
//  NightOut
//
//  Created by Kyle Zeller on 7/9/22.
//

import SwiftUI
import Firebase
import KeyboardObserving


enum AlertType {
    case invalidInput, badLogin, badSignUp
}

struct AlertState {
    var showAlert: Bool
    var alertType: AlertType
    var message: String
}
 func hideKeyboard() {
#if os(iOS)
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
#endif
}

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @AppStorage("showOnboarding") var showOnboarding: Bool = true

    @State private var alertState = AlertState(showAlert: false, alertType: .invalidInput, message: "")
    
  
    @State private var selection: Int = 0
    @StateObject var onboardingViewModel: OnboardingViewModel = OnboardingViewModel()
    @State var showingSheetTab: Bool = false
    
    var body: some View {
        
            ZStack {
                Color.gray.ignoresSafeArea(.all)
                
                VStack(spacing: 20) {
                    Spacer().frame(height: 40)
                    
                    Text("\(ProgramConstants.AppName)")
                        .font(.system(size: 40))
                        .fontWeight(.semibold)
                        .foregroundColor(.Black)
                        .multilineTextAlignment(.center)
                    
                    Image("AppLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150)
                        .clipped()
                        .cornerRadius(150)
                    
                    Text("The College Experience Awaits")
                        .font(.headline)
                    
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.Gray)
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
                        .foregroundColor(.black)
                        
                    
                    SecureField("Password", text: $password)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.Gray)
                        .cornerRadius(5.0)
                        .padding(.bottom, 10)
                        .foregroundColor(.black)
                    VStack{
                        Spacer()
                        HStack(spacing: 20) {
                            Button(action: {
                                if email.isEmpty || password.isEmpty {
                                    self.alertState = AlertState(showAlert: true, alertType: .invalidInput, message: "Enter Email and Password")
                                    return
                                }
                                
                                onboardingViewModel.logIn(withEmail: email, withPassword: password) { result in
                                    DispatchQueue.main.async {
                                        switch result {
                                        case .success(_):
                                            //show inapp views
                                            showOnboarding = false
                                            
                                           
                                        case .failure(let error):
                                            alertState = AlertState(showAlert: true, alertType: .badLogin, message: error.localizedDescription)
                                        }
                                    }
                                }
                            }) {
                                Text("Log in")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        Color.Gray
                                    )
                                    .cornerRadius(15.0)
                            }
                            .alert(isPresented: $alertState.showAlert) {
                                Alert(title: Text(alertTitle()), message: Text(alertState.message), dismissButton: .default(Text("Got it!")))
                            }
                            
                            Button(action: {
                                if email.isEmpty || password.isEmpty {
                                    self.alertState = AlertState(showAlert: true, alertType: .invalidInput, message: "Enter Email and Password")
                                    return
                                }
                                
                                onboardingViewModel.signUp(withEmail: email, withPassword: password) { result in
                                    DispatchQueue.main.async {
                                        switch result {
                                        case .success(_):
                                            showingSheetTab = true
                                            
                                        case .failure(let error):
                                            alertState = AlertState(showAlert: true, alertType: .badSignUp, message: error.localizedDescription)
                                        }
                                    }
                                }
                            }) {
                                Text("Sign up")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.Purple, .Black]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(15.0)
                            }
                            .alert(isPresented: $alertState.showAlert) {
                                Alert(title: Text(alertTitle()), message: Text(alertState.message), dismissButton: .default(Text("Got it!")))
                            }
                        }
                    }
                    
                    
                   
                }
                
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            .navigationBarHidden(true)
            .onAppear {
                let user = Auth.auth().currentUser
                if user != nil {
                  
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .fullScreenCover(isPresented: $showingSheetTab){
                TabView(selection: $selection){
                    CreateUserProfile(selection: $selection)
                        .tag(0)
                        .environmentObject(onboardingViewModel)
                        .edgesIgnoringSafeArea(.all)
                    UserDataAcquisition(selection: $selection)
                        
                        .tag(1)
                        .environmentObject(onboardingViewModel)
                        .edgesIgnoringSafeArea(.all)
                    ProfilePictureAcquisition(selection: $selection, showingSheetTab: $showingSheetTab)
                        .tag(2)
                        .environmentObject(onboardingViewModel)
                        .edgesIgnoringSafeArea(.all)
                }
#if os(iOS)
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
#endif
                
                .background(Color.gray.edgesIgnoringSafeArea(.all))
            }
        
    }
     func alertTitle() -> String {
        switch alertState.alertType {
        case .invalidInput:
            return "Invalid Input"
        case .badLogin:
            return "Login Failed"
        case .badSignUp:
            return "Sign Up Failed"
        }
    }
}




struct ContentView_Previews: PreviewProvider{
    static var previews: some View{
        LoginView()
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
        Text("Log in")
            .font(.headline)
            .foregroundColor(.Purple)
            .padding()
            .frame(maxWidth: .infinity)
            .background(LinearGradient(gradient: Gradient(colors: [.Gray, .gray]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(15.0)
    }
}

struct SIGNUP: View {
    var body: some View {
        Text("Sign up")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(LinearGradient(gradient: Gradient(colors: [.Purple, .Black]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(15.0)
    }
}





struct MissionStatement: View {
    var body: some View {
        Text("The College Experience Awaits")
            .font(.headline)
    }
}

