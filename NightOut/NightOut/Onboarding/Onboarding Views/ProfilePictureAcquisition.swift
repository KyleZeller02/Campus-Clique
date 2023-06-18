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
    @State private var isPickerShowing = false
    @State private var selectedImage: UIImage?
    @StateObject var viewRouter: ViewRouter
    @State private var showingAlert = false
    @State private var isAlertShownOnce = false
    
    var body: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()
            
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
                        .background(LinearGradient(gradient: Gradient(colors: [.purple, .black]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                })
                
                Button(action: {
                    if selectedImage == nil && !isAlertShownOnce {
                        showingAlert = true
                        isAlertShownOnce = true
                        return
                    }
                    
                    if let email = Auth.auth().currentUser?.email {
                        OnboardingDatabaseManager.uploadProfileImage(selectedImage!, forUserEmail: email) { url in
                            if let url = url {
                                print("Image uploaded successfully. Url: \(url)")
                                viewRouter.CurrentViewState = .ClassPosts
                            } else {
                                print("Failed to upload image.")
                            }
                        }
                    }
                }, label: {
                    Text("Make Profile")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [.purple, .black]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                })
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Missing Profile Picture"), message: Text("Adding a profile picture is encouraged, but not required. A default image will be shown as your profile picture if you do not chose one."), dismissButton: .default(Text("Got it!")))
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
        ProfilePictureAcquisition(viewRouter: ViewRouter())
    }
}
