//
//  ProfilePictureAcquisition.swift
//  NightOut
//
//  Created by Kyle Zeller on 12/21/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct ProfilePictureAcquisition: View {
    @AppStorage("showOnboarding") var showOnboarding: Bool = true
    @State private var isPickerShowing = false
    @State private var selectedImage: UIImage?
    @Binding var selection: Int
    @State private var showingAlert = false
    @Binding var showingSheetTab: Bool
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    
    
    var body: some View {
        ZStack {
            
            
            VStack(alignment: .center, spacing: 40) {
                Text("ADD PROFILE PICTURE")
                    .font(.title)
                    .fontWeight(.bold)
                
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 128, height: 128)
                        .cornerRadius(64)
                        .overlay(RoundedRectangle(cornerRadius: 64).stroke(Color.black, lineWidth: 3))
                } else {
                    Image(systemName: "person.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                        .overlay(RoundedRectangle(cornerRadius: 64).stroke(Color.black, lineWidth: 3))
                }
                
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
                
                Button(action: {
                    if selectedImage == nil  {
                        showingAlert = true
                       
                        return
                    }
                    
                   //handle information in view model
                    //send all information
                    onboardingVM.updatePicture(image: selectedImage ?? UIImage(imageLiteralResourceName: "person.fill")) { result in
                        switch result {
                        case .success(let urlString):
                            print("Picture updated successfully: \(urlString)")
                            showingSheetTab = false
                            showOnboarding = false
                            // Use urlString to do something if needed
                        case .failure(let error):
                            print("Error updating picture: \(error)")
                            // Handle the error if needed
                        }
                    }
                   
                    
                    
                    // tab view not showing
                    
                    
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
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Missing Profile Picture"), message: Text("Select A Profile Picture"), dismissButton: .default(Text("Got it!")))
                }
                
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $isPickerShowing, onDismiss: nil) {
            ImagePicker(selectedImage: $selectedImage, isPickerShowing: $isPickerShowing)
        }
    }
}


struct ProfilePictureAcquisition_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePictureAcquisition(selection: .constant(1), showingSheetTab: .constant(true))
    }
}
    
