//
//  UserProfileView.swift
//  NightOut
//
//  Created by Kyle Zeller on 12/20/22.
//
// need to finish the edit button and the edit screen

import SwiftUI
import Firebase

struct UserProfileView: View {
    
    @StateObject var viewRouter: ViewRouter
    @StateObject var profileVM: UserProfileViewModel = UserProfileViewModel()
    @State var showingProfileEdit = false
    @AppStorage("Email") var SavedEmail: String?
    @State private var showEditView = false
    @State var newFirstName: String = ""
    @State var newLastName: String = ""
    @State var newCollege: String = ""
    @State var newBirthday: String = ""
    @State var newMajors: String = ""
    @State var newClass1: String = ""
    @State var newClass2: String = ""
    @State var newClass3: String = ""
    @State var newClass4: String = ""
    @State var newClass5: String = ""
    @State var newClass6: String = ""
    @State private var showingAlert: Bool = false
    
    
    
    var body: some View {
        Color.Gray
            .ignoresSafeArea()
            .overlay(
                ZStack{
                VStack(alignment: .leading){
                    

                    HStack(spacing: 50){
                        Text("\(profileVM.userDocument.FirstName) \(profileVM.userDocument.LastName)")
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                            .font(.system(size:30))
                            .padding(.bottom)
                        
                        Button {
                            self.showEditView = true
                            
                            
                        } label: {
                            Text("Edit Profile")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 150, height: 50)
                                .background(.indigo)
                                .cornerRadius(15.0)
                        }
                        .fullScreenCover(isPresented: $showEditView) {
                            ZStack(alignment: .leading){
                                VStack(){
                                    HStack{
                                        Text("First Name:")
                                            .padding()
                                            .background(Color.indigo)
                                            .foregroundColor(.white)

                                            .cornerRadius(5.0)
                                            .padding(.bottom, 20)
                                            .padding(.leading,10)
                                            .font(.headline)
                                        
                                        TextField("First Name", text: $newFirstName)
                                            .padding()
                                            .background(Color.Gray)
                                            .cornerRadius(5.0)
                                            .padding(.bottom, 20)
                                            .padding(.trailing,10)
                                            .minimumScaleFactor(0.7)
                                    }
                                    HStack(){
                                        Text("Last Name:")
                                            .padding()
                                            .background(Color.indigo)
                                            .foregroundColor(.white)
                                            .cornerRadius(5.0)
                                            .padding(.bottom, 20)
                                            .padding(.leading,10)
                                            .font(.headline)
                                        
                                        TextField("Last Name", text: $newLastName)
                                            .padding()
                                            .background(Color.Gray)
                                            .cornerRadius(5.0)
                                            .padding(.bottom, 20)
                                            .padding(.trailing,10)
                                            .minimumScaleFactor(0.7)
                                    }
                                    HStack(){
                                        Text("College:")
                                            .padding()
                                            .background(Color.indigo)
                                            .foregroundColor(.white)
                                            .cornerRadius(5.0)
                                            .padding(.bottom, 20)
                                            .padding(.leading,10)
                                            .font(.headline)
                                        
                                        TextField("College", text: $newCollege)
                                            .padding()
                                            .background(Color.Gray)
                                            .cornerRadius(5.0)
                                            .padding(.bottom, 20)
                                            .padding(.trailing,10)
                                            .minimumScaleFactor(0.7)
                                    }
                                    HStack(){
                                        Text("Birthday:")
                                            .padding()
                                            .background(Color.indigo)
                                            .foregroundColor(.white)
                                            .cornerRadius(5.0)
                                            .padding(.bottom, 20)
                                            .padding(.leading,10)
                                            .font(.headline)
                                        
                                        TextField("Birthday", text: $newBirthday)
                                            .padding()
                                            .background(Color.Gray)
                                            .cornerRadius(5.0)
                                            .padding(.bottom, 20)
                                            .padding(.trailing,10)
                                            .minimumScaleFactor(0.7)
                                    }
                                    HStack(){
                                        Text("Major(s)")
                                            .padding()
                                            .background(Color.indigo)
                                            .foregroundColor(.white)
                                            .cornerRadius(5.0)
                                            .padding(.bottom, 20)
                                            .padding(.leading,10)
                                            .font(.headline)
                                        
                                        TextField("Major", text: $newMajors)
                                            .padding()
                                            .background(Color.Gray)
                                            .cornerRadius(5.0)
                                            .padding(.bottom, 20)
                                            .padding(.trailing,10)
                                            .minimumScaleFactor(0.7)
                                        
                                    }
                                    HStack(){
                                        Text("Classes:")
                                            .padding()
                                            .background(Color.indigo)
                                            .foregroundColor(.white)
                                            .cornerRadius(5.0)
                                            .padding(.bottom, 20)
                                            .padding(.leading,10)
                                            .font(.headline)
                                        
                                        VStack(spacing: 0){
                                            VStack(spacing: 0){
                                                HStack(spacing: 0){
                                                    TextField("Class", text: $newClass1)
                                                        .padding()
                                                        .background(Color.Gray)
                                                        .cornerRadius(5.0)
                                                        .padding(.bottom, 20)
                                                        .padding(.trailing,10)
                                                        .minimumScaleFactor(0.7)
                                                    TextField("Class", text: $newClass2)
                                                        .padding()
                                                        .background(Color.Gray)
                                                        .cornerRadius(5.0)
                                                        .padding(.bottom, 20)
                                                        .padding(.trailing,10)
                                                        .minimumScaleFactor(0.7)
                                                    TextField("Class", text: $newClass3)
                                                        .padding()
                                                        .background(Color.Gray)
                                                        .cornerRadius(5.0)
                                                        .padding(.bottom, 20)
                                                        .padding(.trailing,10)
                                                        .minimumScaleFactor(0.7)
                                                }
                                            }
                                            VStack(spacing: 0){
                                                HStack(spacing: 0){
                                                    TextField("Class", text: $newClass4)
                                                        .padding()
                                                        .background(Color.Gray)
                                                        .cornerRadius(5.0)
                                                        .padding(.bottom, 20)
                                                        .padding(.trailing,10)
                                                        .minimumScaleFactor(0.7)
                                                    TextField("Class", text: $newClass5)
                                                        .padding()
                                                        .background(Color.Gray)
                                                        .cornerRadius(5.0)
                                                        .padding(.bottom, 20)
                                                        .padding(.trailing,10)
                                                        .minimumScaleFactor(0.7)
                                                    TextField("Class", text: $newClass6)
                                                        .padding()
                                                        .background(Color.Gray)
                                                        .cornerRadius(5.0)
                                                        .padding(.bottom, 20)
                                                        .padding(.trailing,10)
                                                        .minimumScaleFactor(0.7)
                                                }
                                            }
                                            
                                        }
                                        
                                        
                                        
                                        
                                        
                                        
                                    }
                                    Button {
                                        if newFirstName.isEmpty || newLastName.isEmpty || newCollege.isEmpty || newMajors.isEmpty || newClass1.isEmpty ||
                                            newBirthday.isEmpty{
                                            
                                            self.showingAlert = true
                                        }
                                        else{
                                            var ClassArray:[String] = []
                                            if newClass1 != ""{
                                                ClassArray.append(newClass1)
                                            }
                                            if newClass2 != ""{
                                                ClassArray.append(newClass2)
                                            }
                                            if newClass3 != ""{
                                                ClassArray.append(newClass3)
                                            }
                                            if newClass4 != ""{
                                                ClassArray.append(newClass4)
                                            }
                                            if newClass5 != ""{
                                                ClassArray.append(newClass5)
                                            }
                                            if newClass6 != ""{
                                                ClassArray.append(newClass6)
                                            }
                                            profileVM.handleEdit(firstName: newFirstName, lastName: newLastName, College: newCollege, Birthday: newBirthday, Major: newMajors, Classes: ClassArray)
                                            self.showEditView = false
                                        }
                                        
                                    } label: {
                                        Text("Finalize Changes")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(width: 220, height: 60)
                                            .background(.indigo)
                                            .cornerRadius(15.0)
                                    }
                                    .alert(isPresented: $showingAlert) {
                                        Alert(title: Text("Please Enter Values For All Fields"), dismissButton: .default(Text("Got it!")))
                                        
                                    }
                                    Button {
                                        self.showEditView = false
                                    } label: {
                                        Text("Cancel")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(width: 220, height: 60)
                                            .background(.indigo)
                                            .cornerRadius(15.0)
                                    }


                                    
                                }
                               
                            }
                            .onAppear(){
                                DispatchQueue.main.async {
                                    let classCount = profileVM.userDocument.Classes?.count ?? 0
                                    self.newFirstName = profileVM.userDocument.FirstName
                                    self.newLastName = profileVM.userDocument.LastName
                                    self.newCollege = profileVM.userDocument.College
                                    self.newBirthday = profileVM.userDocument.Birthday
                                    self.newMajors = profileVM.userDocument.Major.joined(separator: ",")
                                    
                                    if classCount > 0{
                                        self.newClass1 = profileVM.userDocument.Classes?[0] ?? ""
                                    }
                                    if classCount > 1{
                                        self.newClass2 = profileVM.userDocument.Classes?[1] ?? ""
                                    }
                                    if classCount > 2{
                                        self.newClass3 = profileVM.userDocument.Classes?[2] ?? ""
                                    }
                                    if classCount > 3{
                                        self.newClass4 = profileVM.userDocument.Classes?[3] ?? ""
                                    }
                                    if classCount > 4{
                                        self.newClass5 = (profileVM.userDocument.Classes?[4]) ?? ""
                                    }
                                    if classCount > 5{
                                        self.newClass6 = profileVM.userDocument.Classes?[5] ?? ""
                                    }
                                    
                                   
                                    
                                    
                                    
                                 
                                }
                            
                            }
                        }


                    }
                    
                        
                        
                    Text("Enrolled At")
                        .foregroundColor(.black)
                        .font(.system(size:20))
                        .multilineTextAlignment(.leading)
                    
                    Text("\(profileVM.userDocument.College)")
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .font(.system(size:15))
                        .padding(.bottom)
                        
                    if(profileVM.userDocument.Major.count > 1){
                        Text("My Majors:")
                            .foregroundColor(.black)
                            .font(.system(size:20))
                            .multilineTextAlignment(.leading)
                        ForEach(profileVM.userDocument.Major, id: \.self) {majors in
                            Text("\(majors)")
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                                .font(.system(size:8))
                                .padding(.bottom)
                                
                        }
                    }
                    else{
                        Text("My Major:")
                            .foregroundColor(.black)
                            .font(.system(size:20))
                            .multilineTextAlignment(.leading)
                        ForEach(profileVM.userDocument.Major, id: \.self) {majors in
                            Text("\(majors)")
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                                .font(.system(size:15))
                                
                                .padding(.bottom)
                                
                        }
                    }
                    
                    Text("My Classes:")
                        .foregroundColor(.black)
                        .font(.system(size:20))
                        .multilineTextAlignment(.leading)
                        
                    ForEach(profileVM.userDocument.Classes ?? [], id: \.self) {enrolledClass in
                        Text(" \(enrolledClass)")
                            .foregroundColor(.black)
                            
                            .font(.system(size:15))
                            .multilineTextAlignment(.leading)
                            
                    }
                     

                }
                    .frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity, alignment: .topLeading)
                    .padding(.leading)
                    
                    
                }
                    
            )
        
    }
    
        
        
        
    
}


struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(viewRouter: ViewRouter())
    }
}
