//
//  UserProfileViewMode.swift
//  NightOut
//
//  Created by Kyle Zeller on 1/10/23.
//

import SwiftUI
import Firebase

class UserProfileViewModel: ObservableObject{
    @Published var userDocument: UserDocument = UserDocument(FirstName: "Default", LastName: "", College: "", Birthday: "", Major: [], Classes: [], Email: "")
    
    @AppStorage("Email") var SavedEmail: String?
    let db = Firestore.firestore()
    
    func getDocument(completion:@escaping((UserDocument) -> ())){
        let g = DispatchGroup()

        var tempDoc: UserDocument = UserDocument(FirstName: "", LastName: "", College: "", Birthday: "", Major: [], Classes: [], Email: "")

        let doc = db.collection("Users").document(SavedEmail ?? "")
        g.enter()
        doc.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let firstName = data?["FirstName"] as? String ?? ""
                let lastName = data?["LastName"] as? String ?? ""
                let college = data?["College"] as? String ?? ""
                let birthday = data?["Birthday"] as? String ?? ""
                let major = data?["Major"] as? [String] ?? []
                let classes = data?["Classes"] as? [String] ?? []
                let email = data?["Email"] as? String ?? ""
                let retrievedDoc = UserDocument(FirstName: firstName, LastName: lastName, College: college, Birthday: birthday, Major: major, Classes: classes, Email: email)
                tempDoc = retrievedDoc
                g.leave()
            } else {
                print("Document does not exist")
                g.leave()
            }
        }



        g.notify(queue:.main) {
            completion(tempDoc)
            self.objectWillChange.send()
        }
       
       
        
        
      // userDocument = UserDocument( FirstName: "Kyle", LastName: "Zeller", College: "Kansas State University", Birthday: "02/01/2002", Major: ["Computer Science"], Classes: ["CIS450", "CIS501", "CIS575","CIS415"], Email: "zellerkyl@gmail.com")
         
    }
    
    func handleEdit(firstName: String, lastName: String, College: String, Birthday: String, Major:String, Classes: [String]){
        //get reference to location in firebase
        
        let userDocLocation = db.collection("Users").document(userDocument.Email)
        //update values in firebase
        if firstName != userDocument.FirstName{
            userDocLocation.setData(["FirstName" : firstName],merge: true)
        }
        if lastName != userDocument.LastName{
            userDocLocation.setData(["LastName" : lastName] ,merge: true)
        }
        if College != userDocument.College{
            userDocLocation.setData(["College" : College],merge: true )
        }
        let majorArr = parseMajor(major: Major)
        if !majorArr.elementsEqual(userDocument.Major){
            userDocLocation.setData(["Major" : majorArr],merge: true)
        }
        
        if !Classes.elementsEqual(userDocument.Classes ?? []){
            userDocLocation.setData(["Classes" : Classes],merge: true)
        }
        if Birthday != userDocument.Birthday{
            userDocLocation.setData(["Birthday" : Birthday],merge: true)
        }
        
        
        //update local userdocument
        self.userDocument = UserDocument(FirstName: firstName, LastName: lastName, College: College, Birthday: Birthday, Major: majorArr, Classes: Classes, Email: userDocument.Email)
        
        objectWillChange.send()
        
    }
    
    init(){
        DispatchQueue.main.async {
            self.getDocument(){ retrieved in
                self.userDocument = retrieved
                self.userDocument.objectWillChange.send()
                  
            }
            self.userDocument.Classes?.sort()
        }
       
        
        
    }
    private func parseMajor(major: String) -> [String]{
        return major.components(separatedBy: ",")
    }
    
}
