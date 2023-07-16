//
//  EditProfileVIew.swift
//  Campus Clique
//
//  Created by Kyle Zeller on 6/5/23.
//

import SwiftUI
import Kingfisher

struct EditProfileView: View {
    @State private var newCollege:String = ""
    @State private var newClass1:String = ""
    @State private var newClass2:String = ""
    @State private var newClass3:String = ""
    @State private var newClass4:String = ""
    @State private var newClass5:String = ""
    @State private var newClass6:String = ""
    @State private var newMajor:String = ""
    @State private var newFirstName:String = ""
    
    @State private var newLastName:String = ""
    @State private var profilePicture: String?
    @EnvironmentObject var vm: inAppViewVM
    @State private var isPickerShowing = false
        @State private var selectedImage: UIImage?
    @State private var didChangeImage:Bool = false
       
    @Environment(\.presentationMode) var presentationMode
    
    
    
    var body: some View {
        Spacer().frame(maxHeight: 10)
        ScrollView{
            ZStack{
                Color.Black.ignoresSafeArea()
                VStack{
                    
                    cancelButton
                    Button(action: {
                        self.didChangeImage = true
                                        self.isPickerShowing = true
                                    }) {
                                        if let image = selectedImage {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 200, height: 200)
                                                .clipShape(Circle())
                                                .padding(.trailing,10)
                                        } else if let urlString = vm.userDoc.profilePictureURL, let url = URL(string: urlString) {
                                            KFImage(url)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 200, height: 200)
                                                .clipShape(Circle())
                                                .padding(.trailing,10)
                                        } else {
                                            Image(systemName: "person.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 200, height: 200)
                                                .clipShape(Circle())
                                                .padding(.trailing,10)
                                        }
                                    }

                    fields
                    classesFields
                    Spacer()
                }
                
            }.onAppear(){
                
                 
                
                 self.newFirstName = vm.userDoc.FirstName
                 self.newLastName = vm.userDoc.LastName
                 self.newCollege = vm.userDoc.College
                 self.newMajor = vm.userDoc.Major
                if let urlString = vm.userDoc.profilePictureURL, let url = URL(string: urlString) {
                    self.profilePicture = vm.userDoc.profilePictureURL
                    }
                
                self.newClass1 = vm.userDoc.Classes.count > 0 ? vm.userDoc.Classes[0] : ""
                self.newClass2 = vm.userDoc.Classes.count > 1 ? vm.userDoc.Classes[1] : ""
                self.newClass3 = vm.userDoc.Classes.count > 2 ? vm.userDoc.Classes[2] : ""
                self.newClass4 = vm.userDoc.Classes.count > 3 ? vm.userDoc.Classes[3] : ""
                self.newClass5 = vm.userDoc.Classes.count > 4 ? vm.userDoc.Classes[4] : ""
                self.newClass6 = vm.userDoc.Classes.count > 5 ? vm.userDoc.Classes[5] : ""
                
            }
            .sheet(isPresented: $isPickerShowing, onDismiss: nil) {
                ImagePicker(selectedImage: $selectedImage, isPickerShowing: $isPickerShowing)
            }
        }
        
       
    }
    
    private var cancelButton: some View {
        HStack{
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Cancel")
                    .foregroundColor(.cyan)
                    .font(.system(size: 18))
            }
            Spacer()
            Button {
                let classes = [self.newClass1, self.newClass2, self.newClass3, self.newClass4, self.newClass5, self.newClass6].compactMap { $0 }
                let trimmedClasses = classes.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                let nonEmptyClasses = trimmedClasses.filter { !$0.isEmpty }

                
                if let error = vm.handleEdit(newCollege: self.newCollege, newClasses: nonEmptyClasses, newMajor: self.newMajor, newFirstName: self.newFirstName, newLastName: self.newLastName, newProfilePicture: self.selectedImage,didEditPhoto: self.didChangeImage) {
                    
                    vm.curError = error
                }
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Done")
                    .foregroundColor(.cyan)
                    .bold()
                    .font(.system(size: 18))
            }
        }.padding(.horizontal,20)
    }
    
    private var fields: some View {
        Group {
            field("First Name: ", text: $newFirstName)
            divider
            field("Last Name: ", text: $newLastName)
            divider
            field("University: ", text: $newCollege)
            divider
            field("Major: ", text: $newMajor)
            divider
        }
    }
    
    private var classesFields: some View {
        HStack {
            Text("Classes:")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.leading)
            Spacer()
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    CustomTextField(placeholder: "CIS115", text: $newClass1)
                    CustomTextField(placeholder: "ECON500", text: $newClass2)
                    CustomTextField(placeholder: "MRK367", text: $newClass3)
                }
                HStack(spacing: 10) {
                    CustomTextField(placeholder: "MATH222", text: $newClass4)
                    CustomTextField(placeholder: "ARCH435", text: $newClass5)
                    CustomTextField(placeholder: "BIO349", text: $newClass6)
                }
            }
        }.padding(.horizontal).background(Color.black.opacity(0.8))
    }
    
    private func field(_ label: String, text: Binding<String>) -> some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.leading)
            Spacer()
            TextField("Placeholder", text: text)
                .padding(.vertical, 12)
                .padding(.horizontal,3)
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white, lineWidth: 1))
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }.padding(.horizontal)
    }
    
    private var divider: some View {
        Divider()
            .background(Color.cyan)
            .padding([.leading, .trailing])
    }
}


struct EditProfileVIew_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
    }
}

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding(.vertical, 12)
            .padding(.horizontal,3)
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white, lineWidth: 1))
            .disableAutocorrection(true)
            .autocapitalization(.allCharacters)
    }
}
