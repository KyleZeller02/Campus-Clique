//
//  EditProfileVIew.swift
//  Campus Clique
//
//  Created by Kyle Zeller on 6/5/23.
//

import SwiftUI

struct EditProfileView: View {
    
    @State private var newCollege:String = ""
    @State private var newClass1:String = ""
    @State private var newClass2:String = ""
    @State private var newClass3:String = ""
    @State private var newClass4:String = ""
    @State private var newClass5:String = ""
    @State private var newClass6:String = ""
    @State private var newMajor:String = ""
    @State private var injectedClasses: [String] = []
    @EnvironmentObject var inappVM: inAppViewVM
    @Environment(\.presentationMode) var presentationMode
    private func removeClass(at index: Int) {
        withAnimation {
            injectedClasses.remove(at: index)
        }
    }
    
    var body: some View {
        ZStack{
            Color.Black
                .ignoresSafeArea()
            VStack{
                //College-------------------------------------------------------
                HStack(){
                    Text("College:")
                        .font(.headline)
                        .foregroundColor(Color.white)
                        .padding(.horizontal)
                    Spacer()
                    TextField("College", text: $newCollege)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.Purple, lineWidth: 1))
                }
                .padding(.vertical)
                .background(Color.Purple)
                .cornerRadius(10)
                .padding(.horizontal)
                
                //End College-------------------------------------------------------
                //Major-------------------------------------------------------
                HStack(){
                    Text("Major:")
                        .font(.headline)
                        .foregroundColor(Color.white)
                        .padding(.horizontal)
                    Spacer()
                    TextField("Major", text: $newMajor)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                    
                }
                .padding(.vertical)
                .background(Color.Purple)
                .cornerRadius(10)
                .padding(.horizontal)
                //End Major-------------------------------------------------------
                
                //Add Class Button-------------------------------------------------------
                Button(action: {
                    if self.injectedClasses.count < 6{
                        //check if there are any blank inputs, do not allow new item if flag is true
                        
                        let hasBlankOrWhitespace = injectedClasses.contains { element in
                            let trimmedElement = element.trimmingCharacters(in: .whitespacesAndNewlines)
                            return trimmedElement.isEmpty
                        }
                        //we can add the element
                        if !hasBlankOrWhitespace{
                            self.injectedClasses.append("")
                        }
                        
                    }
                }) {
                    Text("Add Class")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.Purple)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(injectedClasses.indices, id: \.self) { index in
                            HStack {
                                TextField("Class", text: Binding(
                                    get: {
                                        return injectedClasses[index]
                                    },
                                    set: { newValue in
                                        injectedClasses[index] = newValue
                                    }
                                ))
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .foregroundColor(.black)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.Purple, lineWidth: 1))
                                
                                // Delete class Button
                                Button(action: {
                                    if injectedClasses.count > 0{
                                        removeClass(at: index)
                                    }
                                }) {
                                    Image(systemName: "minus.circle")
                                        .foregroundColor(Color.Purple)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
                
                // Buttons-------------------------------------------------------
                HStack{
                    Button(action: {
                        
                        let injectedClasses = injectedClasses.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                          
                        inappVM.curError = inappVM.handleEdit(newCollege: self.newCollege, newClasses: injectedClasses, newMajor: self.newMajor) ?? ""
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Finalize Changes")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.Purple)
                            .cornerRadius(10)
                    }
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.Purple)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                
            }
            .padding(.top)
        }
        .onAppear(){
            self.injectedClasses.removeAll()
            let classCount = inappVM.userDoc.Classes.count
            self.newCollege = inappVM.userDoc.College
            self.newMajor = inappVM.userDoc.Major
            
            for index in 0..<min(classCount, 6) {
                
                let newClass = inappVM.userDoc.Classes[index]
                    self.injectedClasses.append(newClass)
                
            }
            
            
        }
    }
}

struct EditProfileVIew_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
    }
}
