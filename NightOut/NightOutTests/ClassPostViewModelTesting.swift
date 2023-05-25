import XCTest
import FirebaseFirestore
import Firebase
@testable import Campus_Clique

class ClassPostsViewModelTests: XCTestCase {

    var viewModel: ClassPostsViewModel!
    var firestore: Firestore!

    override func setUp() {
        super.setUp()
        // Set up the Firebase app and Firestore instance
       
        firestore = Firestore.firestore()
        // Initialize the ViewModel
        viewModel = ClassPostsViewModel()
        
    }

    override func tearDown() {
        super.tearDown()
        // Clean up any test data in Firestore if necessary
        // ...
    }

   

}
