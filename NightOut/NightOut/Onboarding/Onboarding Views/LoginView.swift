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

// A SwiftUI View for the login screen
struct LoginView: View {

    // State variables to store user's input
    @State private var phoneNumber: String = "" // stores phone number entered by user
    @State private var countryCode:String = "+1" // stores country code entered by user
    @State private var email: String = "" // stores email entered by user
    @State private var password: String = "" // stores password entered by user
    @AppStorage("showOnboarding") var showOnboarding: Bool = true // UserDefaults boolean variable to store whether to show the onboarding screen or not.
    
    @State private var showPasswordInput:Bool = false // Boolean flag to decide when to show password input field
    @State private var alertState = AlertState(showAlert: false, alertType: .invalidInput, message: "") // Controls the visibility and content of the alert

    // Environment object of OnboardingViewModel
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel

    // Boolean flag to show/hide sheet
    @State var showingSheetTab: Bool = false
    
    
    
    
    
    // Main View body
    var body: some View {
        
        ZStack {
            // Set background color of ZStack
            Color.gray.ignoresSafeArea(.all)
            
            VStack(spacing: 20) {

                // App name
                Text("\(ProgramConstants.AppName)")
                    .font(.system(size: 40))
                    .fontWeight(.semibold)
                    .foregroundColor(.Black)
                    .multilineTextAlignment(.center)

                // App logo
                Image("AppLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .clipped()
                    .cornerRadius(150)

                // Subtitle
                Text("The College Experience Awaits")
                    .font(.headline)
                    .foregroundColor(.Black)

                VStack{
                    HStack{
                        // Country code input field
                        TextField("CountryCode", text: $countryCode)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color.Gray)
                            .cornerRadius(5.0)
                            .padding(.bottom, 20)
                            .foregroundColor(.black)
                            .frame(maxWidth: 80)

                        // Phone number input field
                        TextField("Phone Number", text: $phoneNumber)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color.Gray)
                            .cornerRadius(5.0)
                            .padding(.bottom, 20)
                            .foregroundColor(.black)
                            .keyboardType(.phonePad) // set keyboard type as phonePad
                    }

                    // Button to send code
                    Button(action: {
                        
                        let finalNumber = self.countryCode + self.phoneNumber
                        if self.phoneNumber.isEmpty{
                            return
                        }

                        // Ask ViewModel to send the code
                        onboardingViewModel.sendCode(phoneNumber: finalNumber) { success in
                            if success {
                                self.showPasswordInput = true
                            } else {
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
                }
            }
            .padding() // Add padding to VStack
        }
        .navigationBarHidden(true) // Hide navigation bar
        .onAppear {
            let user = Auth.auth().currentUser
            if user != nil {
                
            }
        }
        .onTapGesture {
            hideKeyboard() // Hide keyboard when user taps outside the input field
        }
        
        // Show the VerifyPhoneNumber view as a sheet when showPasswordInput is true
        .sheet(isPresented: $showPasswordInput){
            VerifyPhoneNumber(showOnboarding: $showOnboarding, showPasswordInput: $showPasswordInput).environmentObject(onboardingViewModel)
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


// This struct represents the View for verifying a user's phone number.
struct VerifyPhoneNumber: View {
    // The input code entered by the user
    @State var code: String = ""
    
    // Boolean variables that control the display of onboarding and password input
    @Binding var showOnboarding: Bool
    @Binding  var showPasswordInput:Bool
    
    // Onboarding view model object for storing and managing UI-related data
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel
    
    @AppStorage("showOnboardingTab") var showOnboardingTab: Bool = false
    
    // The body property that renders the view content
    var body: some View {
        // Layering views on top of each other
        ZStack{
            // Apply gray color to the entire safe area
            Color.gray.ignoresSafeArea(.all)
            
            // Vertically stack views
            VStack{
                // Title text
                Text("Verify Your Phone Number")
                    .font(.title)
                    .foregroundColor(.Black)
                
                // Text field for the passcode input
                TextField("We Sent You A Passcode", text: $code)
                    .autocapitalization(.none) // Disable automatic capitalization
                    .padding()
                    .background(Color.Gray)
                    .cornerRadius(5.0) // Round the corners of the text field
                    .padding(.bottom, 20) // Padding at the bottom
                    .keyboardType(.numberPad) // Display numeric keypad for input
                    .foregroundColor(.black)
                
                // Button to verify the code
                Button {
                    // Retrieve the verification ID from UserDefaults
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
                        // Handle sign-in errors
                        if let error = error {
                            print("Sign-in failed with error: \(error.localizedDescription)")
                        } else {
                            // Sign-in was successful
                            print("Sign-in successful!")
                            
                            // Retrieve the phone number from UserDefaults
                            guard let phoneNumber = UserDefaults.standard.string(forKey: "phoneNumber") else {
                                print("Cannot retrieve phone number from UserDefaults")
                                return
                            }
                            
                            // Setup firestore database
                            let db = Firestore.firestore()
                            
                            // Define the user's document reference
                            let docRef = db.collection("Users").document(phoneNumber)
                            
                            // Check if document exists
                            docRef.getDocument { (document, error) in
                                if let document = document, document.exists {
                                    // The user exists, proceed with the login
                                    print("User exists, log them in")
                                    showOnboarding = false
                                    showOnboardingTab = false
                                    onboardingViewModel.objectWillChange.send()
                                } else {
                                    // Create a new user
                                    print("New user, create an account")
                                    docRef.setData(["phoneNumber" : phoneNumber])
                                    onboardingViewModel.updatePhoneNumber(number: phoneNumber)
                                    showPasswordInput = false
                                    showOnboarding = false
                                    showOnboardingTab = true
                                    onboardingViewModel.objectWillChange.send()
                                }
                            }
                        }
                    }
                    
                } label: {
                    // Button label
                    Text("Verify")
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
                
                // Take up remaining space
                Spacer()
            }
            .presentationDetents([.height(400)]) // Presentation mode (height of the sheet)
            .padding(.top,30) // Padding at the top
            .padding(.horizontal,20) // Horizontal padding
        }
    }
}

