//
//  Edit Profile.swift
//  NightOut
//
//  Created by Kyle Zeller on 5/12/23.
//

import SwiftUI
import Firebase

struct ProfileSettings: View {
    
    var body: some View {
        ZStack{
            Color.Black.ignoresSafeArea()
            
            VStack{
                VStack{
                    Text("Preferences")
                        .padding()
                        .background(Color.Purple)
                        .foregroundColor(.white)
                        .cornerRadius(5.0)
                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                        .font(.headline)
                }
                Spacer()
                //Logout and Delete account Buttons
                HStack{
                    //LogOut Button----------------------------------------------------------------------
                    Button(action: {
                        //logout method
                        AccountActions.LogOut()
                    }) {
                        Text("Log Out")
                            .padding()
                            .background(Color.Purple)
                            .foregroundColor(.white)
                            .cornerRadius(5.0)
                            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                            .font(.headline)
                    }
                    //End LogOut Button----------------------------------------------------------------------
                    //Delete Account Button------------------------------------------------------------------
                    Button(action: {
                        //Delete account method
                        AccountActions.deleteAccount()
                    }) {
                        Text("Delete My Account")
                            .padding()
                            .background(Color.Purple)
                            .foregroundColor(.white)
                            .cornerRadius(5.0)
                            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                            .font(.headline)
                    }
                    //Delete Account Button------------------------------------------------------------------
                }
               
               
            }
        }
    }
}

struct AccountActions{
     static func LogOut(){
        do {
            try Auth.auth().signOut()
            // User has been successfully logged out
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
        
    }
    
    
    static func deleteAccount(){
        //first signout
        LogOut()
        //delete account
        let user = Auth.auth().currentUser
       user?.delete { error in
           if let error = error {
               print("Error deleting account: \(error.localizedDescription)")
           } else {
               // Account has been successfully deleted
           }
       }
    }
}

struct Edit_Profile_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettings()
    }
}
