import Foundation
import Firebase

/// `OnboardingViewModel` is a class responsible for handling the operations related to user onboarding.
/// It performs tasks such as verifying the phone number, updating user information,
/// uploading user's profile picture, and saving user data to Firestore.
class OnboardingViewModel: ObservableObject {
    
    // MARK: - Properties

    /// A published instance of `UserDocument`, represents the current user's information.
    @Published var userInformation = UserDocument(firstName: "", lastName: "", college: "", major: "", classes: [], phoneNumber: "", profilePictureURL: nil)
    

    
    
    /// Firestore Database instance to interact with Firebase's Firestore database.
    let db = Firestore.firestore()
    
   


   
    
    // MARK: - Methods

    /// Sends a verification code to the provided phone number using Firebase's PhoneAuthProvider.
    /// On success, it saves the verification ID and phone number in UserDefaults.
    func sendCode(phoneNumber: String, completion: @escaping (Bool) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
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
    
    /// Updates the user's first name, last name, and college.
    func updateFirstLastCollege(first:String, last: String, College: String) {
        self.userInformation.firstName = first
        self.userInformation.lastName = last
        self.userInformation.college = College
    }
    
    /// Updates the user's classes and major.
    func updateClassesMajor(Classes: [String], Major: String) {
        self.userInformation.classes = Classes
        self.userInformation.major = Major
    }
    
    /// Updates the user's phone number.
    func updatePhoneNumber(number:String) {
        self.userInformation.phoneNumber = number
    }
    
    /// Updates the user's profile picture by uploading it to Firebase,
    /// then updates the profile picture URL in the user information and sends all the user information to Firestore.
    func updatePicture(image: UIImage, completion: @escaping (Result<String, Error>) -> ()) {
        OnboardingDatabaseManager.uploadProfileImage(image) { result in
            switch result {
            case .success(let urlString):
                self.userInformation.profilePictureURL = urlString
                self.sendAll()
                completion(.success(urlString))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Sends all the user information to Firestore.
    /// If the user is authenticated, it creates a new document with the user's phone number as the document ID,
    /// and stores the user's information as a dictionary in the document.
    func sendAll() {
        guard let _ = Auth.auth().currentUser else {
            print("No signed in user")
            return
        }
        
        guard let phoneNumber = Auth.auth().currentUser?.phoneNumber else{return}
        let userRef = db.collection("Users").document(phoneNumber)
        let userInfoDict: [String: Any] = [
            "first_name": self.userInformation.firstName,
            "last_name": self.userInformation.lastName,
            "college": self.userInformation.college,
            "classes": self.userInformation.classes,
            "profile_picture_url": self.userInformation.profilePictureURL ?? "",
            "major": self.userInformation.major,
            "phone_number" : phoneNumber
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
