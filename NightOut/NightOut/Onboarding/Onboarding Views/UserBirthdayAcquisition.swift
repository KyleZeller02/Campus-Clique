//
//  UserBirthdayAcquisition.swift
//  NightOut
//
//  Created by Kyle Zeller on 8/21/22.
//

import SwiftUI

struct UserBirthdayAcquisition: View {
    @State var Birthday: String = ""
    @State private var ProfileViewIsActive:Bool = false
    @StateObject var viewRouter: ViewRouter
    @State private var showingAlert:Bool = false
    var body: some View {
        ZStack{
            Color.Gray
                .ignoresSafeArea()
            VStack{
                Spacer()
                Text("When Is Your Birthday?")
                    .font(.system(size: 40))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.Purple)
                    .multilineTextAlignment(.center)
                Text("""
                     Enter in the format of "MM/DD/YYYY"
                     """)
                .multilineTextAlignment(.center)
                .padding(.top)
                
                
                TextField("Birthday", text: $Birthday)
                    .autocapitalization(UITextAutocapitalizationType.words)
                    .padding()
                    .background(Color.Gray)
                    .cornerRadius(5.0)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(.top)
                
               
                Spacer()
                
                Button(action:
                        { if Birthday != "" {
                            let email = Settings.Email
                            OnboardingDatabaseManager.addBirthdayToDocument(birthday: Birthday, email: email)
                            viewRouter.CurrentViewState = .ClassPosts
                            
                        }
                    else{
                        self.showingAlert = true
                    }
                }
                ) {
                    MakeProfile()
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Please Answer Prompts"), dismissButton: .default(Text("Got it!")))
                    
                    
                    
                }
                
                Spacer()
            }
        }
        
       
       
    }
}

struct UserBirthdayAcquisition_Previews: PreviewProvider {
    static var previews: some View {
        UserBirthdayAcquisition(viewRouter: ViewRouter())
    }
}
struct MakeProfile: View {
    var body: some View {
        Text("Next")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(.indigo)
            .cornerRadius(15.0)
    }
}
