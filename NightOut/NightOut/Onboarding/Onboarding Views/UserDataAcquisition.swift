//
//  UserDataAcquisition.swift
//  NightOut
//
//  Created by Kyle Zeller on 7/16/22.
//
//  This SwiftUI view facilitates user data collection, such as major and classes
//  The data is then used to personalize the user's experience on the app

import SwiftUI
import Firebase

struct UserDataAcquisition: View {
    // MARK: - Properties
    
    // State for managing alert presentation
    @State private var showingAlert = false
    
    // User's major and classes
    @State var major = ""
    @State var class1 = ""
    @State var class2 = ""
    @State var class3 = ""
    @State var class4 = ""
    @State var class5 = ""
    @State var class6 = ""
    
    // Navigation control flag
    @State private var navigateToNext = false
    
    // Control variable for selection management
    @Binding var selection: Int
    
    // Onboarding ViewModel instance
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    //@StateObject var onboardingVM:OnboardingViewModel = OnboardingViewModel()
    
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            ZStack {
                VStack(alignment: .center, spacing: 20) {
                    Text("Major and Classes")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.Black)
                    
                    // Textfield for user to enter their major
                    TextField("Your major (or Undecided)", text: $major)
                        .autocapitalization(UITextAutocapitalizationType.words)
                        .padding()
                        .background(Color.Gray)
                        .cornerRadius(5.0)
                        .foregroundColor(.Black)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                    
                    Text("Enroll in up to 6 classes")
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.Black)
                    
                    Text("These classes should match up with what is on your schedule. Make sure there are no spaces.")
                        .foregroundColor(.Black)
                    
                    // Textfields for user to enter their classes
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                // Class 1
                                TextField("CIS115", text: $class1)
                                    .padding()
                                    .background(Color.Gray)
                                    .cornerRadius(5.0)
                                    .padding(.bottom, 20)
                                    .padding(.trailing, 10)
                                    .minimumScaleFactor(0.7)
                                    .foregroundColor(.Black)
                                    .autocapitalization(.allCharacters)
                                
                                // Class 2
                                TextField("ECON500", text: $class2)
                                    .padding()
                                    .background(Color.Gray)
                                    .cornerRadius(5.0)
                                    .padding(.bottom, 20)
                                    .padding(.trailing, 10)
                                    .minimumScaleFactor(0.7)
                                    .autocapitalization(.allCharacters)
                                    .foregroundColor(.Black)
                                
                                // Class 3
                                TextField("MRK367", text: $class3)
                                    .padding()
                                    .background(Color.Gray)
                                    .cornerRadius(5.0)
                                    .padding(.bottom, 20)
                                    .padding(.trailing, 10)
                                    .minimumScaleFactor(0.7)
                                    .autocapitalization(.allCharacters)
                                    .foregroundColor(.Black)
                            }
                        }
                        
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                // Class 4
                                TextField("MATH222", text: $class4)
                                    .padding()
                                    .background(Color.Gray)
                                    .cornerRadius(5.0)
                                    //.padding(.bottom, 20)
                                    .padding(.trailing, 10)
                                    .minimumScaleFactor(0.7)
                                    .autocapitalization(.allCharacters)
                                    .foregroundColor(.Black)
                                
                                // Class 5
                                TextField("ARCH435", text: $class5)
                                    .padding()
                                    .background(Color.Gray)
                                    .cornerRadius(5.0)
                                    //.padding(.bottom, 20)
                                    .padding(.trailing, 10)
                                    .minimumScaleFactor(0.7)
                                    .autocapitalization(.allCharacters)
                                    .foregroundColor(.Black)
                                
                                // Class 6
                                TextField("BIO349", text: $class6)
                                    .padding()
                                    .background(Color.Gray)
                                    .cornerRadius(5.0)
                                    //.padding(.bottom, 20)
                                    .padding(.trailing, 10)
                                    .minimumScaleFactor(0.7)
                                    .autocapitalization(.allCharacters)
                                    .foregroundColor(.Black)
                            }
                        }
                        
                    }
                    .padding(.leading, 20)
                    .padding(.trailing, 15)
                    
                    // Button for submitting the form
                    HStack {
                        Spacer()
                        Button(action: {
                            if major != "", class1 != "" {
                                // If user gives data, upload data to document in Firebase
                                if let user = Auth.auth().currentUser {
                                    
                                    let major = major.trimmingCharacters(in: .whitespacesAndNewlines)
                                    var classes = [class1, class2, class3, class4, class5, class6]
                                    
                                    classes = classes.map { $0.replacingOccurrences(of: " ", with: "") }
                                                
                                    classes = classes.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                                    classes = classes.filter { !$0.isEmpty }
                                    
                                    // Add information to view model
                                    onboardingVM.updateClassesMajor(Classes: classes, Major: major)
                                    
                                    // Trigger navigation
                                    withAnimation {
                                        selection += 1
                                    }
                                }
                            } else {
                                // If there is missing data from the user, show an alert
                                showingAlert = true
                            }
                        }) {
                            NextButton()
                        }
                        .alert(isPresented: $showingAlert) {
                            Alert(title: Text("Please Answer Prompts"), dismissButton: .default(Text("Got it!")))
                        }
                        
                    }
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                }
            }
        }
        .onTapGesture {
            hideKeyboard() // Close the keyboard when tapping outside the text field
        }
    }
}

struct UserProfileSetUp_Previews: PreviewProvider {
    static var previews: some View {
        UserDataAcquisition(selection: .constant(1))
    }
}
