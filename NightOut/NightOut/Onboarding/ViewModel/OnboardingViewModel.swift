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
    
    var email: String
    
    var profilePicURL: String

    init(firstName: String = "",
         lastName: String = "",
         college: String = "",
         classes: [String] = [],
         major: String = "",
        
         email: String = "",
         profilePicURL: String = ""
         
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.college = college
        self.classes = classes
        self.major = major
       
        self.email = email
        self.profilePicURL = profilePicURL
    
    }
}

class OnboardingViewModel: ObservableObject {
    @Published var userInformation = UserInfo()
    let db = Firestore.firestore()
    
    
    func signUp(withEmail email: String, withPassword pass: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard !email.isEmpty, !pass.isEmpty else {
            completion(.failure(OnboardingError.emptyField))
            return
        }
        Auth.auth().createUser(withEmail: email, password: pass) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else {
                self.updateEmail(email: email)
                print(self.userInformation.email)
                completion(.success(true))
            }
        }
        
    }
    
    func logIn(withEmail email: String, withPassword pass: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard !email.isEmpty, !pass.isEmpty else {
            completion(.failure(OnboardingError.emptyField))
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: pass) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
                //set default values in the document in firebase
                
                
               
            }
        }
        
    }
    func updateFirstLastCollege(first:String, last: String, College: String){
        print(self.userInformation.email)
        self.userInformation.firstName = first
        self.userInformation.lastName = last
        self.userInformation.college = College
    }
    
    func updateClassesMajor(Classes: [String], Major: String, email: String){
        self.userInformation.classes = Classes
        self.userInformation.major = Major
        self.userInformation.email = email
        
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
    func updateEmail(email:String){
        self.userInformation.email = email
    }


    
    func sendAll(){
        guard let user = Auth.auth().currentUser else {
            print("No signed in user")
            return
        }
       
        let userRef = db.collection("Users").document(self.userInformation.email)
        let userInfoDict: [String: Any] = [
            "first_name": self.userInformation.firstName,
            "last_name": self.userInformation.lastName,
            "college": self.userInformation.college,
            "classes": self.userInformation.classes,
            "profile_picture_url": self.userInformation.profilePicURL,
            "major": self.userInformation.major,
            "email" : self.userInformation.email
        ]

        userRef.setData(userInfoDict) { error in
            if let error = error {
                print("Error creating document: \(error)")
            } else {
                print("Document successfully created!")
            }
        }
    }


    
}
