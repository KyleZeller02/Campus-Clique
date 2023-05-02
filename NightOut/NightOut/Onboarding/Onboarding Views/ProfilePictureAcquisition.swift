//
//  ProfilePictureAcquisition.swift
//  NightOut
//
//  Created by Kyle Zeller on 12/21/22.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore

struct ProfilePictureAcquisition: View {
    @State var isPickerShowing = false
    @State var selectedImage :UIImage?
    @StateObject var viewRouter: ViewRouter
    @State private var showingAlert: Bool = false
    
    var body: some View {
        ZStack{
            
            Color.Gray
                .ignoresSafeArea()
            VStack{
                
                Text("ADD PROFILE PICTURE")
                    .fontWeight(.bold)
                    .font(.title)
                if selectedImage != nil{
                    //can force unwrap since its not nil
                    Image(uiImage: selectedImage!)
                        .resizable()
                        .frame(width:200, height:200)
                        .cornerRadius(100.0)
                }else{
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width:100, height:100)
                        .cornerRadius(100.0)
                }
                //button to chose from user's photo library
                Button{
                    //show image picker
                    isPickerShowing = true
                } label: {
                    Text("SELECT FROM PHOTO LIBRARY")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 60)
                        .background(.indigo)
                        .cornerRadius(15.0)
                }
                .padding(10)
                //Make Profile Button
                Button {
                    if selectedImage != nil{
                       // OnboardingDatabaseManager.addProfilePhotoToDocument(selectedImage: selectedImage)
                        viewRouter.CurrentViewState = .ClassPosts
                    }
                    else{
                        self.showingAlert = true
                    }
                } label: {
                    Text("Make Profile")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 60)
                        .background(.indigo)
                        .cornerRadius(15.0)
                }.alert(isPresented: $showingAlert) {
                    Alert(title: Text("Select a Profile Picture"), dismissButton: .default(Text("Got it!")))
                    
                }.sheet(isPresented: $isPickerShowing, onDismiss: nil) {
                    //Image Picker
                    ImagePicker(selectedImage: $selectedImage, isPickerShowing: $isPickerShowing)
                }
            }
        }
    }
}
struct ProfilePictureAcquisition_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePictureAcquisition(viewRouter: ViewRouter())
    }
}
