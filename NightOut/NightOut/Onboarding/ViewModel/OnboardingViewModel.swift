import Foundation
import Firebase

enum OnboardingError: Error, LocalizedError {
    case emptyField
    
    var errorDescription: String? {
        switch self {
        case .emptyField:
            return "Email or password is empty"
        }
    }
}

class UserInfo {
    var firstName: String
    var lastName: String
    var college: String
    var classes: [String]
    var major: String
    
    var phoneNumber: String
    
    var profilePicURL: String

    init(firstName: String = "",
         lastName: String = "",
         college: String = "",
         classes: [String] = [],
         major: String = "",
        
         phoneNumber: String = "",
         profilePicURL: String = ""
         
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.college = college
        self.classes = classes
        self.major = major
       
        self.phoneNumber = phoneNumber
        self.profilePicURL = profilePicURL
        
        
    
    }
}

class OnboardingViewModel: ObservableObject {
    @Published var userInformation = UserInfo()
    
    @Published var showlogin: Bool = true
        @Published var showOnboardingTab: Bool = false
    
    let db = Firestore.firestore()
    init(){
        let user = Auth.auth().currentUser
        if let user = user{
            self.showOnboardingTab = false
            self.showlogin = false
        }
        
    }
    
    
    
    func sendCode(phoneNumber: String, completion: @escaping (Bool) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print("\(error.localizedDescription)")
                completion(false)
                return
            }
            if let verificationID = verificationID {
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                UserDefaults.standard.set(phoneNumber, forKey: "phoneNumber") // Store the phone number
                completion(true)
            }
        }
    }
    
    
    func updateFirstLastCollege(first:String, last: String, College: String){
      
        self.userInformation.firstName = first
        self.userInformation.lastName = last
        self.userInformation.college = College
    }
    
    func updateClassesMajor(Classes: [String], Major: String){
        self.userInformation.classes = Classes
        self.userInformation.major = Major
       
        
    }
    func updatePhoneNumber(number:String){
        self.userInformation.phoneNumber = number
    }
    
    func updatePicture(image: UIImage, completion: @escaping (Result<String, Error>) -> ()) {
        OnboardingDatabaseManager.uploadProfileImage(image) { result in
            switch result {
            case .success(let urlString):
                print("Uploaded successfully: \(urlString)")
                self.userInformation.profilePicURL = urlString
                self.sendAll()
                completion(.success(urlString))
            case .failure(let error):
                print("Error uploading: \(error)")
                completion(.failure(error))
            }
        }
    }
    


    
    func sendAll(){
        guard let user = Auth.auth().currentUser else {
            print("No signed in user")
            return
        }
       
        let userRef = db.collection("Users").document(self.userInformation.phoneNumber)
        let userInfoDict: [String: Any] = [
            "first_name": self.userInformation.firstName,
            "last_name": self.userInformation.lastName,
            "college": self.userInformation.college,
            "classes": self.userInformation.classes,
            "profile_picture_url": self.userInformation.profilePicURL,
            "major": self.userInformation.major,
            "phone_number" : self.userInformation.phoneNumber
        ]

        userRef.setData(userInfoDict) { error in
            if let error = error {
                print("Error creating document: \(error)")
            } else {
                print("Document successfully created!")
            }
        }
        self.showOnboardingTab = false
    }


    
}
