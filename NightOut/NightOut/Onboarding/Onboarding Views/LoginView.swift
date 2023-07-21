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
    @State var code: String = "111111"
    @State private var phoneNumber: String = "+17852246907"
    @State private var email: String = ""
    @State private var password: String = ""
    
    @State private var showPasswordInput:Bool = false
    @State private var alertState = AlertState(showAlert: false, alertType: .invalidInput, message: "")
    
    
    
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel 
    @State var showingSheetTab: Bool = false
    
    var body: some View {
        
        ZStack {
            Color.gray.ignoresSafeArea(.all)
            
            VStack(spacing: 20) {
                //Spacer().frame(height: 40)
                
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
                    .foregroundColor(.White)
                
                
                
                

                VStack{
                    TextField("Phone Number", text: $phoneNumber)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.Gray)
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
                        .foregroundColor(.black)
                    
                        Button(action: {
                            onboardingViewModel.sendCode(phoneNumber: phoneNumber) { success in
                                    if success {
                                        self.showPasswordInput = true
                                    } else {
                                        // Optionally, handle the error case here
                                        print("Failed to send code.")
                                    }
                                }
                        }, label: {
                            Text("Send Code")
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
                        })
                        .alert(isPresented: $alertState.showAlert) {
                            Alert(title: Text(alertTitle()), message: Text(alertState.message), dismissButton: .default(Text("Got it!")))
                        }

                        .alert(isPresented: $alertState.showAlert) {
                            Alert(title: Text(alertTitle()), message: Text(alertState.message), dismissButton: .default(Text("Got it!")))
                        }
                    
                }
                Spacer()
                
                
            }
            
            .padding()
            
            
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
        
        .sheet(isPresented: $showPasswordInput){
           
            ZStack{
                Color.gray.ignoresSafeArea(.all)
                VStack{
                    Text("Verify Your Phone Number")
                        .font(.title)
                    
                    TextField("Your Passcode", text: $code)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.Gray)
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
                        .foregroundColor(.black)
                    Button {
                        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else {
                               print("Cannot retrieve verification ID from UserDefaults")
                               return
                           }

                           // Log the contents of the code variable
                           print("Verification code: \(code)")

                           // Create a credential with the verification ID and the code entered by the user
                           let credential = PhoneAuthProvider.provider().credential(
                               withVerificationID: verificationID,
                               verificationCode: code)

                                        // Sign in with the provided credential
                        Auth.auth().signIn(with: credential) { authResult, error in
                            if let error = error {
                                print("Sign-in failed with error: \(error.localizedDescription)")
                            } else {
                                print("Sign-in successful!")

                                // Retrieve the phone number from UserDefaults
                                guard let phoneNumber = UserDefaults.standard.string(forKey: "phoneNumber") else {
                                    print("Cannot retrieve phone number from UserDefaults")
                                    return
                                }

                                let db = Firestore.firestore()
                                let docRef = db.collection("Users").document(phoneNumber) // Use the phone number as the document ID

                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        print("User exists, log them in")
                                        onboardingViewModel.showlogin = false
                                        onboardingViewModel.showOnboardingTab = false
                                        // Perform login actions here
                                    } else {
                                        print("New user, create an account")
                                        // Here you would create a new user document in your Firestore
                                    docRef.setData(["phoneNumber" : phoneNumber])
                                        onboardingViewModel.updatePhoneNumber(number: phoneNumber)
                                        // Make sure to customize to fit your user model
                                        showPasswordInput = false
                                        onboardingViewModel.showlogin = false
                                        onboardingViewModel.showOnboardingTab = true
                                        onboardingViewModel.objectWillChange.send()
                                    }
                                }
                            }
                        }

                    } label: {
                        Text("Verify")
                    }

                }
            }
           
                
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

