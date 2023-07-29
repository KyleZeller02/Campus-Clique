import SwiftUI
import Firebase

struct AccountActions{
   
    static func LogOut(){
        do {
            try Auth.auth().signOut()



            // User has been successfully logged out
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }

    }

    static func deleteAccount(usersPhoneNumber:String){
        let db = Firestore.firestore()
        print(usersPhoneNumber)
        let userDoc = db.collection("Users").document(usersPhoneNumber)
        userDoc.delete { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
        

        //first signout
        LogOut()
        let user = Auth.auth().currentUser
            
            if let phoneNumber = UserDefaults.standard.string(forKey: "phoneNumber"),
               let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") {
                
                let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: phoneNumber)
                
                user?.reauthenticate(with: credential, completion: { (result, error) in
                    if let error = error {
                        print("Error reauthenticating user: \(error.localizedDescription)")
                        
                        return
                    }
                    
                    user?.delete { error in
                        if let error = error {
                            print("Error deleting account: \(error.localizedDescription)")
                           
                        } else {
                            // Account has been successfully deleted
                            print("Account successfully deleted.")
                           
                        }
                    }
                })
            } else {
                print("No verification ID or phone number found.")
                
            }
    }
}
