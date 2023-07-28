//
//  ProfileSetUp.swift
//  NightOut
//
//  Created by Kyle Zeller on 7/16/22.
// this file may need to keep track of login information
//

// This is a SwiftUI view for creating a user profile during onboarding.

import SwiftUI
import Firebase

struct CreateUserProfile: View {
    // Variables to hold user's first name, last name, and selected college
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var selectedCollege: String = ""
    
    // Boolean variables to control UI states
    @State private var isReadyForNextView = false
    @State private var showingAlert = false
    @State private var isCollegeFieldSelected: Bool = false
    @State private var showAlert = false
    @FocusState private var isTextFieldFocused: Bool

    // This Binding variable 'selection' is used to control navigation between views
    @Binding var selection: Int
    
    // ViewModel to handle onboarding data and logic
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    
    // Filter for search function in college list
    @ObservedObject private var filter = SearchFilter()

    var body: some View {
        ScrollView {
            ZStack {
                VStack(alignment: .center, spacing: 20) {
                    Text("Create Your Profile")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.Black)

                    // First name input field
                    TextField("First Name", text: $firstName)
                        .autocapitalization(.words)
                        .padding()
                        .cornerRadius(5.0)
                        .foregroundColor(.Black)
                        .background(Color.Gray)
                        .onChange(of: firstName){ newValue in
                            firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
                        }

                    // Last name input field
                    TextField("Last Name", text: $lastName)
                        .autocapitalization(.words)
                        .padding()
                        .background(Color.Gray)
                        .cornerRadius(5.0)
                        .foregroundColor(.Black)
                        .onChange(of: lastName){ newValue in
                            lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
                        }

                    // College input field
                    TextField("Your College", text: $filter.searchQuery)
                        .autocapitalization(.words)
                        .padding()
                        .cornerRadius(5.0)
                        .foregroundColor(.Black)
                        .background(Color.Gray)
                        .onChange(of: filter.searchQuery) { newValue in
                            filter.setSearchQuery(to: newValue)
                        }
                        .focused($isTextFieldFocused)
                        .onTapGesture {
                            self.isCollegeFieldSelected = true
                        }

                    // College selection dropdown list
                    if isCollegeFieldSelected{
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                ForEach(filter.colleges, id: \.self) { college in
                                    Button(action: {
                                        self.filter.searchQuery = college
                                        self.filter.validateSearchQuery()
                                        isTextFieldFocused = false
                                    }) {
                                        Text(college)
                                            .padding(10)
                                            .background(Color.Gray)
                                            .foregroundColor(.Black)
                                            .cornerRadius(8)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                            .padding(.vertical, 10)
                        }
                        .frame(maxHeight: 300)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(10)
                        .listStyle(InsetGroupedListStyle())
                    }

                    // Next button
                    HStack{
                        Spacer()
                        Button(action: {
                            // Check if fields are filled correctly
                            if !filter.colleges.contains(filter.searchQuery) {
                                showAlert = true
                            }
                            else if !firstName.isEmpty && !lastName.isEmpty && !filter.searchQuery.isEmpty {
                                let trimmedFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
                                let trimmedLastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
                                onboardingVM.updateFirstLastCollege(first: trimmedFirstName, last: trimmedLastName, College: filter.searchQuery)
                                withAnimation{
                                    selection += 1
                                }
                            } else {
                                self.showAlert = true
                            }
                        }) {
                            NextButton()
                        }
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Please select a college from the list."), dismissButton: .default(Text("Got it!")))
                        }
                    }
                    .padding(.bottom, 10)
                }
                .padding(.horizontal, 20)
            }
            .navigationBarHidden(true)
        }
        .onTapGesture {
            hideKeyboard()
            self.isCollegeFieldSelected = false
        }
    }
}

// SwiftUI Preview provider
struct ProfileSetUp_Previews: PreviewProvider {
    static var previews: some View {
        CreateUserProfile(selection: .constant(1))
    }
}

// Next button view
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
