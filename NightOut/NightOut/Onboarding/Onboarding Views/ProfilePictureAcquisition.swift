//
//  ProfilePictureAcquisition.swift
//  NightOut
//
//  Created by Kyle Zeller on 12/21/22.
//

// Imports the necessary libraries
import SwiftUI
import Firebase
import FirebaseFirestore

// A SwiftUI View that handles acquisition of profile pictures during onboarding
struct ProfilePictureAcquisition: View {

    // UserDefaults boolean variable to store whether to show the onboarding screen or not.
    @AppStorage("showOnboarding") var showOnboarding: Bool = true
    
    @AppStorage("showOnboardingTab") var showOnboardingTab: Bool = false

    // State variables for SwiftUI View
    @State private var isPickerShowing = false // controls the visibility of the image picker
    @State private var selectedImage: UIImage? // stores the selected profile image
    @Binding var selection: Int // parent view controller sends which tab should be selected in the tabView
    @State private var showingAlert = false // controls the visibility of the alert
    @State private var MissingInformtion = false // tracks if any information is missing
    
    // An environment object of OnboardingViewModel
    @EnvironmentObject var onboardingVM: OnboardingViewModel

    // The body of the SwiftUI view
    var body: some View {

        // ZStack allows overlay of views
        ZStack {
            // VStack aligns views vertically
            VStack(alignment: .center, spacing: 40) {

                // Title text
                Text("ADD PROFILE PICTURE")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.Black)

                // If the user has selected an image, we display it
                // If not, we show a placeholder image
                if let image = selectedImage {
                    // Display the selected image
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 128, height: 128)
                        .cornerRadius(64)
                        .overlay(RoundedRectangle(cornerRadius: 64).stroke(Color.black, lineWidth: 3))
                } else {
                    // Display a placeholder image
                    Image(systemName: "person.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                        .overlay(RoundedRectangle(cornerRadius: 64).stroke(Color.black, lineWidth: 3))
                }

                // Button to open the image picker
                Button(action: {
                    isPickerShowing = true
                }, label: {
                    Text("SELECT FROM PHOTO LIBRARY")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [.Purple, .Black]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                })

                // Button to proceed with the profile creation
                Button(action: {
                    self.MissingInformtion = false

                    // Checks if user selected an image or not
                    if selectedImage == nil  {
                        showingAlert = true
                        return
                    }

                    // Checks if all necessary information is provided
                    if onboardingVM.userInformation.firstName.isEmpty || onboardingVM.userInformation.lastName.isEmpty ||
                        onboardingVM.userInformation.classes.isEmpty ||
                        onboardingVM.userInformation.college.isEmpty ||
                        onboardingVM.userInformation.major.isEmpty {
                        self.MissingInformtion = true
                        return
                    }

                   
                    
                    // Sends all information to view model for processing
                    onboardingVM.updatePicture(image: selectedImage ?? UIImage(imageLiteralResourceName: "person.fill")) { result in
                        switch result {
                        case .success(let urlString):
                            print("Picture updated successfully: \(urlString)")
                            showOnboarding = false
                            showOnboardingTab = false
                        case .failure(let error):
                            print("Error updating picture: \(error)")
                        }
                    }
                }, label: {
                    Text("Make Profile")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors:[.Purple, .Black]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                })
                // Alert for missing profile picture
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Missing Profile Picture"), message: Text("Select A Profile Picture"), dismissButton: .default(Text("Got it!")))
                }
                // Alert for missing other information
                .alert(isPresented: $MissingInformtion) {
                    Alert(title: Text("Missing Data"), message: Text("Please fill out all information on other screens"), dismissButton: .default(Text("Got it!")))
                }
                
                // Takes up remaining space
                Spacer()
            }
            .padding() // Adds padding around VStack
        }

        // ImagePicker modal
        .sheet(isPresented: $isPickerShowing, onDismiss: nil) {
            ImagePicker(selectedImage: $selectedImage, isPickerShowing: $isPickerShowing)
        }
    }
}

// For previewing this view in Xcode's design canvas
struct ProfilePictureAcquisition_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePictureAcquisition(selection: .constant(1))
    }
}

