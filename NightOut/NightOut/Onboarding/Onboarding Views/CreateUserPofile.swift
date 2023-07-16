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
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var college: String = ""
    @State private var isReadyForNextView = false
    @State private var showingAlert = false
    @Binding var selection: Int
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    
    
    var body: some View {
       
            ZStack {
               
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Create Your Profile")
                        .font(.system(size: 40))
                        .fontWeight(.semibold)
                        .foregroundColor(.Black)
                    
                    
                    TextField("First Name", text: $firstName)
                        .autocapitalization(.words)
                        .padding()
                        
                        .cornerRadius(5.0)
                        .foregroundColor(.Black)
                        .background(Color.Gray)
                    
                    TextField("Last Name", text: $lastName)
                        .autocapitalization(.words)
                        .padding()
                        .background(Color.Gray)
                        .cornerRadius(5.0)
                        .foregroundColor(.Black)
                    
                    TextField("Your College", text: $college)
                        .autocapitalization(.words)
                        .padding()
                        .background(Color.Gray)
                        .cornerRadius(5.0)
                        .foregroundColor(.Black)
                    HStack{
                        Spacer()
                        Button(action: {
                            if !firstName.isEmpty && !lastName.isEmpty && !college.isEmpty {
                                let user = Auth.auth().currentUser
                                let email = user?.email
                                let trimmedFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
                                let trimmedLastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
                                let trimmedCollege = college.trimmingCharacters(in: .whitespacesAndNewlines)
                                
                                //add information to view model
                                onboardingVM.updateFirstLastCollege(first: trimmedFirstName, last: trimmedLastName, College: trimmedCollege)
                                //
                                
                                withAnimation{
                                    selection += 1
                                }
                                
                                
                            } else {
                                self.showingAlert = true
                            }
                        }) {
                            NextButton()
                        }
                    }
                    
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("Please Answer Prompts"), dismissButton: .default(Text("Got it!")))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationBarHidden(true)
            .onTapGesture {
                hideKeyboard()
            }
        
    }
}



struct ProfileSetUp_Previews: PreviewProvider {
    static var previews: some View {
        CreateUserProfile(selection: .constant(1))
    }
}

struct NextButton: View {
    var body: some View {
        Text("Next")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(LinearGradient(gradient: Gradient(colors: [.Purple, .Black]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(15.0)
            
    }
}
