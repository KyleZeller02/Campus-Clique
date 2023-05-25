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

struct UserInfo {
    var firstName: String
    var lastName: String
    var college: String
    var classes: [String]
    var major: String
    var birthday: String
    var email: String

    init(firstName: String = "",
         lastName: String = "",
         college: String = "",
         classes: [String] = [],
         major: String = "",
         birthday: String = "",
         email: String = "") {
        self.firstName = firstName
        self.lastName = lastName
        self.college = college
        self.classes = classes
        self.major = major
        self.birthday = birthday
        self.email = email
    }
}

class OnboardingViewModel: ObservableObject {
    @Published var userInformation = UserInfo()
    
    func signUp(withEmail email: String, withPassword pass: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard !email.isEmpty, !pass.isEmpty else {
            completion(.failure(OnboardingError.emptyField))
            return
        }
        Auth.auth().createUser(withEmail: email, password: pass) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else {
               
                OnboardingDatabaseManager.addDocumentWithEmail(email: email)
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
            }
        }
    }

    func getFirstLastCollege(firstName first:String, lastName last:String, College college:String){
        userInformation.firstName = first
        userInformation.lastName = last
        userInformation.college = college
    }
    func getMajorClasses(Classes c: [String], Major m: String){
        userInformation.classes = c
        userInformation.major = m
    }
    
    func getBirthday(Birthday b:String){
        userInformation.birthday = b
    }
    
    func sendAll() {
       
        let db = Firestore.firestore()
        let email = userInformation.email
        let path = db.collection("Users").document(email)

        // Prepare the data
        var data: [String: Any] = [:]
        data["FirstName"] = userInformation.firstName
        data["LastName"] = userInformation.lastName
        data["College"] = userInformation.college
        data["Classes"] = userInformation.classes
        data["Major"] = userInformation.major
        data["Birthday"] = userInformation.birthday
        data["Email"] = userInformation.email

        // Add the document
        path.setData(data) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
            }
        }
    }
}
