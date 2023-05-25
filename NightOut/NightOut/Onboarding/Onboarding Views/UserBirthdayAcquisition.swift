//
//  UserBirthdayAcquisition.swift
//  NightOut
//
//  Created by Kyle Zeller on 8/21/22.
//

import SwiftUI
import Firebase

struct UserBirthdayAcquisition: View {
   
    @State var Birthday: String = ""
    @State private var ProfileViewIsActive:Bool = false
    @StateObject var viewRouter: ViewRouter
    @State private var showingAlert:Bool = false
    
    var body: some View {
        ZStack{
            Color.Gray
                .ignoresSafeArea()
            VStack(alignment: .leading){
                
                Text("Date of Birth")
                    .font(.system(size: 40))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.Purple)
                    .multilineTextAlignment(.center)
                
               
                
                TextField("02/01/2002", text: $Birthday)
                    
                    .padding()
                    .background(Color.Gray)
                    .cornerRadius(5.0)
                   
                    .padding(.top)
                
               
              
                
                Button(action:
                        { if Birthday != "" {
                            let user = Auth.auth().currentUser
                            if let user = user{
                                let email = user.email
                                Birthday = Birthday.trimmingCharacters(in: .whitespacesAndNewlines)
                                
                                OnboardingDatabaseManager.addBirthdayToDocument(birthday: Birthday, email: email ?? "")
                                viewRouter.CurrentViewState = .InAppViews
                            }
                            
                            
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
            } .padding(.leading, 20)
                .padding(.trailing, 20)
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
        Text("Make Account")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(.indigo)
            .cornerRadius(15.0)
    }
}
