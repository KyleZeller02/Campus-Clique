//
//  InAppViewModel.swift
//  Campus Clique
//
//  Created by Kyle Zeller on 6/4/23.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Firebase
import Kingfisher

/**
 The ViewModel class `inAppViewVM` is responsible for managing the data and logic related to the main application views and user interactions in the NightOut app.

 This class conforms to the `ObservableObject` protocol, enabling it to publish changes to its properties, allowing SwiftUI views to react and update accordingly.

 ## Properties

 The `inAppViewVM` class contains several `@Published` properties that represent the state of the app and the user's data:

 - `postsForClass`: An array of `ClassPost` objects representing posts related to the selected class.
 - `postsforUser`: An array of `ClassPost` objects representing posts made by the user.
 - `userDoc`: A `UserDocument` object holding information about the user's profile.
 - `curError`: A string that holds any error messages encountered during data retrieval or updates.
 - `isVotingInProgress`: A boolean flag indicating whether voting is in progress to prevent multiple simultaneous votes.
 - `selectedClass`: A string representing the currently selected class for the user.
 - `curReplies`: An array of `Reply` objects representing the replies for a specific post.
 - `lastDocumentSnapshot`: A Firestore `DocumentSnapshot` object used for pagination in fetching posts.
 - `isLastPage`: A boolean flag indicating whether the last page of posts has been reached.
 - `canRefresh`: A boolean flag used to control the refreshing behavior of posts.

 The class also contains instances of various Firebase-related classes to handle data operations:

 - `firebaseManager`: An instance of `FirestoreService` to interact with Firebase Firestore.
 - `db`: The Firestore database reference.

 ## Initialization

 The class initializes its properties, including fetching the user document and initializing posts for the user's class and replies. The `init` method also sorts the user's classes and sets the first class as the `selectedClass`.

 ## Methods

 The `inAppViewVM` class provides methods to handle various operations related to posts, replies, and user profile updates:

 - `fetchNext30PostsForClass`: Fetches the next 30 posts for the selected class from Firestore.
 - `refreshPosts`: Refreshes posts by resetting the pagination and fetching the first 30 posts for the selected class.
 - `fetchFirst30PostsForClass`: Fetches the first 30 posts for the selected class from Firestore.
 - `getPostsForUser`: Fetches posts made by the user and updates the `postsforUser` array.
 - `handleEdit`: Handles updating the user's profile fields like name, college, major, etc.
 - `updateFirstName`: Updates the user's first name in Firestore and related posts and replies.
 - `updateLastName`: Updates the user's last name in Firestore and related posts and replies.
 - `updateClasses`: Updates the user's enrolled classes in Firestore and handles removing posts and replies for classes that are no longer taken.
 - `updateMajor`: Updates the user's major field in Firestore.
 - `updateCollege`: Updates the user's college field in Firestore and handles removing posts, replies, and posts of user replies from the old college.
 - `updateProfilePicture`: Updates the user's profile picture in Firestore, Firebase Storage, and related posts and replies.
 - `updateNameOnPostAndReplies`: Updates the user's name on posts and replies made by the user.
 - `updatePhotoUrl`: Updates the user's profile picture URL on posts and replies made by the user.
 - `deleteReply`: Deletes a reply from Firestore and updates the local data after successful deletion.
 - `handleVoteOnPost`: Handles voting on a post by updating the post in Firestore and fetching the updated post.
 - `handleVoteOnReply`: Handles voting on a reply by updating the reply in Firestore and fetching the updated reply.
 - `fetchReplies`: Fetches replies for a specific post and updates the `curReplies` array.
 - `addReply`: Adds a new reply to a post in Firestore and updates the `curReplies` array.
 - `addNewPost`: Adds a new post to Firestore and updates the local data after successful creation.
 - `removeAllPostsFromUser`: Removes all posts and replies made by the user from Firestore.
 - `getDocument`: Fetches the user document from Firestore and initializes user-related properties.

 The `inAppViewVM` class acts as a central hub for managing the app's data and interactions, ensuring seamless integration with SwiftUI views and Firebase Firestore for a smooth user experience in the NightOut app.
 */

class inAppViewVM: ObservableObject {
    
    // A published property to hold the array of posts related to a class.
    // Views subscribed to this object will refresh when the postsForClass property changes.
    @Published var postsForClass: [ClassPost] = []
    
    // A published property to hold the array of posts for a user.
    // Views subscribed to this object will refresh when the postsforUser property changes.
    @Published var postsforUser: [ClassPost] = []
    
    // A published property to hold user information.
    // Views subscribed to this object will refresh when the userDoc property changes.
    @Published var userDoc: UserDocument = UserDocument(firstName: "", lastName: "", college: "",  major: "", classes: [], phoneNumber: "", profilePictureURL: nil)
    
    // A published property to hold the current error message.
    // Views subscribed to this object will refresh when the curError property changes.
    @Published var curError: String = ""
    
    // A published property to indicate whether voting is in progress or not.
    // Views subscribed to this object will refresh when the isVotingInProgress property changes.
    @Published var isVotingInProgress = false
    
    // A published property to hold the selected class.
    // Views subscribed to this object will refresh when the selectedClass property changes.
    @Published var selectedClass: String = ""
    
    // A published property to hold the current replies.
    // Views subscribed to this object will refresh when the curReplies property changes.
    @Published var curReplies: [Reply] = []
    
    // The firebaseManager is used to interact with Firestore service.
    let firebaseManager = FirestoreService()
    
    // The Firestore database reference.
    let db = Firestore.firestore()
    
    // Property to hold the last document snapshot for pagination purposes.
    var lastDocumentSnapshot: DocumentSnapshot?
    
    // Property to indicate whether the last page of data has been fetched or not.
    var isLastPage: Bool = false
    
    // A published property to indicate whether data can be refreshed or not.
    // Views subscribed to this object will refresh when the canRefresh property changes.
    @Published var canRefresh: Bool = true
   
    // The initializer where initial fetching of user document and posts for a class and user are performed.
    // Initializer for the inAppViewVM class.
    init() {
        // Start by getting the user's document.
        // This function is assumed to be an asynchronous operation that retrieves the user's document
        // and passes it to the completion handler.
        self.getDocument { [weak self] doc, error in
            // Error handling: If an error occurred while getting the document,
            // set the curError property to display an error message.
            if error != nil {
                self?.curError = "There was an issue getting your profile. Please logout and log back in."
            }
            // If the document was successfully fetched, execute the following code block.
            if let doc = doc {
                // Update the userDoc property with the fetched document.
                self?.userDoc = doc
                // Sort the user's classes in ascending order.
                self?.userDoc.classes.sort()
                // Set the selectedClass property to the first class in the sorted classes list,
                // or set it to an empty string if there are no classes.
                self?.selectedClass = self?.userDoc.classes.first ?? ""
                // Fetch the first 30 posts for the currently selected class.
                // This function is assumed to be an asynchronous operation that fetches the first 30 posts for a class.
                self?.fetchFirst30PostsForClass() { completed in
                    // If fetching the first 30 posts was successful, execute the following code block.
                    if completed {
                        // Fetch the posts for the user.
                        // This function is assumed to be an asynchronous operation that fetches the posts for a user.
                        self?.getPostsForUser { completed in
                            
                        }
                    }
                }
            }
        }
    }

    /// `getDocument` is a function that fetches the UserDocument from the Firestore database.
    /// It's a wrapper around the `firebaseManager.getDocument` method and returns the result via the completion handler.
    ///
    /// - Parameter completion: A closure that is invoked when the request to get the document completes.
    /// The closure takes two arguments:
    ///     - UserDocument: The document that is fetched, or nil if there was an error.
    ///     - Error: An error object indicating why the request failed, or nil if the request was successful.
    /// - Returns: Void
    func getDocument(completion: @escaping (UserDocument?, Error?) -> Void) {
        // Call `firebaseManager.getDocument` to get the document.
        // `firebaseManager.getDocument` is assumed to be an asynchronous operation that retrieves a document from Firestore.
        firebaseManager.getDocument { doc, error in
            // Pass the fetched document and any error that occurred to the completion handler.
            // This allows the function caller to handle the document and error as needed.
            completion(doc, error)
        }
    }
    
    /// `fetchNext30PostsForClass` is a function that retrieves the next batch of 30 posts related to a specific class
    /// from the Firestore database. The function takes a completion handler as a parameter that is invoked
    /// once the fetch operation completes.
    ///
    /// - Parameter completion: A closure that is invoked when the operation to fetch the posts completes.
    /// The closure takes one argument:
    ///     - Bool: A boolean flag indicating whether the operation was successful.
    /// - Returns: Void

    func fetchNext30PostsForClass(completion: @escaping (Bool) -> Void) {
        
        // Make sure that there is a selected class, the user's college is not empty and the user is authenticated.
        guard !self.selectedClass.isEmpty, !self.userDoc.college.isEmpty, Auth.auth().currentUser != nil else {
            // Handle the case where the user is not authenticated or some required data is missing.
            if Auth.auth().currentUser == nil{
                self.curError = "You are not currently Authenticated. Log out and log back in."
            }
            else{
                self.curError = "Something went wrong getting your credentials. Log out and log back in."
            }
            return
        }
        
        // Check if there are more posts to fetch. If not, exit the function.
        if isLastPage { return }
        
        // Fetch the next 30 posts related to the selected class from Firestore.
        firebaseManager.fetchNext30PostsForClass(fromClass: self.selectedClass, fromCollege: self.userDoc.college, after: lastDocumentSnapshot) { [weak self] (posts, lastSnapshot, error) in
            // Switch to main thread to update the UI.
            DispatchQueue.main.async {
                // Handle any error that occurred during the fetch operation.
                if let error = error {
                    self?.curError = "Something went wrong getting the posts for \(self?.selectedClass ?? "this class") : \(error)"
                    // Invoke the completion handler with false to indicate that the operation failed.
                    completion(false)
                    return
                }
                // Append the fetched posts to the existing posts. If this is the first fetch operation, assign the fetched posts to `postsForClass`.
                if self?.lastDocumentSnapshot == nil{
                    self?.postsForClass = posts ?? []
                }
                else{
                    self?.postsForClass += posts ?? []
                }
                
                // Update the last document snapshot for future fetch operations.
                self?.lastDocumentSnapshot = lastSnapshot
                
                // If the count of the fetched posts is less than 30, it means we have fetched all posts and there are no more posts to fetch.
                if posts?.count ?? 0 < 30 {
                    self?.isLastPage = true
                }
                
                // Invoke the completion handler with true to indicate that the operation was successful.
                completion(true)
            }
        }
    }

    /// `refreshPosts` is a function that refreshes the current list of class posts in the app by re-fetching the first 30 posts
    /// for the selected class and getting all posts for the user. This function is useful for keeping the posts in the app up-to-date.
    ///
    /// - Parameter completion: A closure that is invoked when the operation to refresh the posts completes. The closure takes one argument:
    ///     - Bool: A boolean flag indicating whether the operation was successful.
    /// - Returns: Void

    func refreshPosts(completion: @escaping (Bool) -> Void) {
        // Check if the posts can be refreshed.
        if canRefresh {
            // Set `canRefresh` to false to prevent multiple refresh operations at the same time.
            canRefresh = false
            // Reset the last document snapshot and the flag indicating if there are more posts to fetch.
            self.lastDocumentSnapshot = nil
            self.isLastPage = false

            // Fetch the first 30 posts for the selected class.
            fetchFirst30PostsForClass(completion: completion)

            // Allow refreshing the posts again after the current refresh operation is completed.
            canRefresh = true
        }
        
        // Fetch all posts for the user. The completion handler is ignored because there is no need to do anything after the operation.
        self.getPostsForUser(){_ in}
    }

    /// `fetchFirst30PostsForClass` is a function that fetches the first 30 class posts from the backend. This function is used to
    /// initially load the posts for the selected class when the app is opened or when the selected class changes.
    ///
    /// - Parameter completion: A closure that is invoked when the operation to fetch the posts completes. The closure takes one argument:
    ///     - Bool: A boolean flag indicating whether the operation was successful.
    /// - Returns: Void

    func fetchFirst30PostsForClass(completion: @escaping (Bool) -> Void) {
        // Guard statement to ensure we have a selected class, college, and authenticated user before making the request
        guard !self.selectedClass.isEmpty, !self.userDoc.college.isEmpty, Auth.auth().currentUser != nil else {
            // Provide appropriate error messages if we don't have a current user or if something went wrong with their credentials
            if Auth.auth().currentUser == nil {
                self.curError = "You are not currently Authenticated. Log out and log back in."
            } else {
                self.curError = "Something went wrong getting your credentials. Log out and log back in."
            }
            return
        }
        
        // Call the firebaseManager's function to fetch the first 30 posts for the selected class from the specified college
        firebaseManager.fetchFirst30PostsForClass(fromClass: self.selectedClass, fromCollege: self.userDoc.college) { [weak self] (posts, lastSnapshot, error) in
            // Dispatch to main thread since we're updating the UI
            DispatchQueue.main.async {
                // Check if there's any error while fetching the posts
                if let error = error {
                    self?.curError = "Something went wrong getting the posts for \(self?.selectedClass ?? "this class") : \(error)"
                    completion(false)
                    return
                }
                
                // If there's no error, set the fetched posts to `postsForClass`
                self?.postsForClass = posts ?? []
                
                // Keep track of the last fetched document snapshot for pagination purposes
                self?.lastDocumentSnapshot = lastSnapshot
                
                // Check if we've fetched all posts. If less than 30 posts are fetched, it indicates that we're on the last page
                if posts?.count ?? 0 < 30 {
                    self?.isLastPage = true
                }
                
                // Signal the completion of fetching
                completion(true)
            }
        }
    }
    
    /// `removeAllPostsFromUser` is a function that removes all posts made by the current user from the backend. This function is generally used
    /// when the user decides to delete all their posts from the platform.
    ///
    /// - Parameter completion: A closure that is invoked when the operation to delete the posts completes. The closure takes two arguments:
    ///     - Bool: A boolean flag indicating whether the operation was successful.
    ///     - Error: An error object that describes the error that occurred if the operation was unsuccessful. `nil` if the operation was successful.
    /// - Returns: Void

    func removeAllPostsFromUser(completion: @escaping (Bool, Error?) -> Void) {
        // Calling firebaseManager's function to delete all posts and replies of the user
        firebaseManager.deletePostsAndRepliesOfUser(phoneNumber: self.userDoc.phoneNumber) { (success, error) in
            if success {
                // Logging success message in the console if the deletion is successful
                print("Successfully deleted all posts and replies for the user.")
                // Invoke completion closure with success
                completion(true, nil)
            } else if let error = error {
                // Logging error message in the console if there is an error during the deletion process
                print("An error occurred while deleting posts and replies: \(error.localizedDescription)")
                // Invoke completion closure with error
                completion(false, error)
            }
        }
    }
    
    /// `deletePostAndReplies` is a function that deletes a specific post along with all its replies from the backend.
    /// The function also updates the local cache of posts to reflect the deletion operation.
    ///
    /// - Parameter post: A `ClassPost` object representing the post to be deleted.
    /// - Returns: Void

    func deletePostAndReplies(_ post: ClassPost) {
        // Call to firebaseManager's function to delete the post and its replies from the backend
        firebaseManager.deletePostAndItsReplies(post) { success in
            if success {
                // If the deletion operation is successful, then we update the local cache of posts.
                DispatchQueue.main.async {
                    // Find the post in the `postsForClass` array and remove it
                    if let index = self.postsForClass.firstIndex(where: { $0.id == post.id }) {
                        self.postsForClass.remove(at: index)
                    }
                    // Find the post in the `postsforUser` array and remove it
                    if let index = self.postsforUser.firstIndex(where: { $0.id == post.id }) {
                        self.postsforUser.remove(at: index)
                    }
                    // Notify the UI to refresh since the data has changed
                    self.objectWillChange.send()
                }
                // Log a success message to the console
                print("Post and replies successfully deleted!")
            } else {
                // If the operation is not successful, update the `curError` property to reflect the failure
                self.curError = "Your post could not be deleted at this time."
            }
        }
    }

    /// `fetchReplies` is a function that retrieves the replies for a specific post.
    /// The function calls the `firebaseManager`'s function to fetch the replies from the backend
    /// and then updates the `curReplies` array to reflect the fetched data.
    ///
    /// - Parameter post: A `ClassPost` object representing the post for which the replies are to be fetched.
    /// - Returns: Void

    func fetchReplies(forPost post: ClassPost) {
        // Call to firebaseManager's function to fetch replies for the post from the backend
        firebaseManager.getReplies(forPost: post) { replies in
            // Update the `curReplies` property with the fetched replies
            self.curReplies = replies
        }
    }
    
    /// `addReply` is a function that adds a new reply to a specific post in the backend. The function takes the reply body and the associated post as parameters.
    /// It also retrieves the necessary user information from the `userDoc` property to store the reply's author information.
    ///
    /// - Parameters:
    ///     - replyBody: The body text of the reply to be added.
    ///     - post: A `ClassPost` object representing the post to which the reply is being added.
    /// - Returns: Void

    func addReply(_ replyBody: String, to post: ClassPost) {
        // Check if the necessary user information is available in the `userDoc` property
        guard !self.userDoc.fullName.isEmpty,
              !self.userDoc.phoneNumber.isEmpty else {
            // If the user information is incomplete or not available, exit the function.
            return
        }
        
        // Check to make sure the post we are replying to exists
        // The post documents location in firebase
        let postDoc = db.collection("posts").document(post.id)
        
        postDoc.getDocument() { [weak self] (document, error) in
            if let error = error {
                print("Error fetching document in addReply()")
                return
            }
            
            // Guard clause ensures the document exists in firebase
            // If the document does not exist, we print an error and return
            guard let document = document, document.exists else {
                print("Error: Post does not exist")
                return
            }
            
            // If the document does exist, we continue
            // Call to `firebaseManager`'s function to add the reply to the backend
            self?.firebaseManager.addReply(
                replyBody,
                to: post,
                firstName: self?.userDoc.firstName ?? "",
                lastName: self?.userDoc.lastName ?? "",
                phoneNumber: self?.userDoc.phoneNumber ?? "",
                profilePictureURL: self?.userDoc.profilePictureURL ?? ""
            ) { result in
                // Handle the result of adding the reply
                switch result {
                case .success(let reply):
                    // If the reply is added successfully, update the local cache of replies (`curReplies`) with the new reply.
                    DispatchQueue.main.async {
                        self?.curReplies.append(reply)
                        // Print all the current replies in the console (for debugging purposes)
                        if let curReplies = self?.curReplies {
                            for curReply in curReplies {
                                print("Reply: \(curReply.replyBody)")
                            }
                        }
                        // Notify the UI that the data has changed.
                        self?.objectWillChange.send()
                    }
                case .failure(let error):
                    // If there was an error adding the reply, print the error message in the console.
                    print("Error adding reply: \(error)")
                }
            }
        }
    }

    
    /// `addNewPost` is a function that allows the user to add a new post to the backend. The function takes the post body as a parameter.
    /// Before adding the post, it checks if the required user information is available in the `userDoc` property.
    ///
    /// - Parameter postBody: The body text of the post to be added.
    /// - Returns: Void
    func addNewPost(_ postBody: String) {
        // Check if the necessary user information is available in the `userDoc` property
        guard !self.userDoc.college.isEmpty,
              !self.userDoc.phoneNumber.isEmpty,
              !self.userDoc.fullName.isEmpty else {
            // If the user information is incomplete or not available, print an error message and exit the function.
            print("Error: Missing User Info")
            return
        }
        
        // Store the currently selected class for the new post
        let selectedClass = self.selectedClass
        
        // Call to `firebaseManager`'s function to add the new post to the backend
        firebaseManager.addNewPost(
            firstName: self.userDoc.firstName,
            lastName: self.userDoc.lastName,
            postBody: postBody,
            forClass: selectedClass,
            college: self.userDoc.college,
            phoneNumber: self.userDoc.phoneNumber,
            profilePictureURL: self.userDoc.profilePictureURL ?? ""
        ) { post, error in
            // Handle the result of adding the post
            if let error = error {
                // If there was an error adding the post, print the error message in the console.
                print("Error adding new post: \(error)")
                // Set `curError` property to inform the user about the issue
                self.curError = "Something went wrong publishing your post. Try Again"
            } else if let post = post {
                // If the post is added successfully, update the local cache of posts (`postsForClass`) with the new post.
                DispatchQueue.main.async {
                    // Insert the new post at the beginning of the `postsForClass` array to show it at the top of the list.
                    self.postsForClass.insert(post, at: 0)
                }
                
                // Fetch all posts for the user. The completion handler is ignored because there is no need to do anything after the operation.
                self.getPostsForUser(){_ in}
            }
        }
    }
    
    /// `handleVoteOnPost` is a function that allows the user to vote on a specific post, either upvoting or downvoting it.
    /// The function takes the vote type and the post to be voted on as parameters.
    ///
    /// - Parameters:
    ///   - voteType: The type of vote, which can be `.upvote` or `.downvote`.
    ///   - post: The `ClassPost` object representing the post to be voted on.
    /// - Returns: Void

    func handleVoteOnPost(UpOrDown voteType: VoteType, onPost post: ClassPost) {
        // Check if the user is currently logged in
        guard let user = Auth.auth().currentUser else {
            // If the user is not logged in, exit the function.
            return
        }
        
        // The post's location:
        let postDoc = db.collection("posts").document(post.id)
        
        // Ensure that post exists
        postDoc.getDocument() { [weak self] (document, error) in
            if let error = error {
                print("Error in retrieving document for post we are voting on in handleVoteOnPost()")
                return
            }
            
            guard let document = document, document.exists else {
                print("Error: Post does not exist")
                return
            }

            // Set `isVotingInProgress` to true to prevent multiple votes being submitted simultaneously
            self?.isVotingInProgress = true
            
            // Call to `firebaseManager`'s function to perform the vote action on the post
            self?.firebaseManager.performAction(vote: voteType, post: post, user: user) { success, error in
                if success {
                    // If the vote action is successful, fetch the updated post from Firestore to update the local cache
                    self?.firebaseManager.fetchPost(byId: post.id) { updatedPost, error in
                        if let updatedPost = updatedPost {
                            // If the updated post is successfully fetched, update the local cache of posts
                            DispatchQueue.main.async {
                                // Call the function to update the post arrays with the updated post
                                self?.updatePostArrays(with: updatedPost)
                                // Set `isVotingInProgress` to false since the vote action is complete
                                self?.isVotingInProgress = false
                                // Notify the UI that the data has changed
                                self?.objectWillChange.send()
                            }
                        } else {
                            // If there was an error fetching the updated post, print the error message in the console.
                            print(error?.localizedDescription ?? "Error fetching updated post.")
                        }
                    }
                } else {
                    // If there was an error performing the vote action, print the error message in the console.
                    print(error?.localizedDescription ?? "Error updating vote.")
                }
            }
        }
    }

    
    /// `updatePostArrays` is a private function that updates the local cache of posts with the given `ClassPost` object.
    /// The function is called after a vote action is performed on a post to reflect the updated post data.
    ///
    /// - Parameter post: The `ClassPost` object representing the updated post.
    /// - Returns: Void

    private func updatePostArrays(with post: ClassPost) {
        // Check if the post exists in the `postsForClass` array and update it if found
        if let index = postsForClass.firstIndex(where: { $0.id == post.id }) {
            postsForClass[index] = post
        }
        
        // Check if the post exists in the `postsforUser` array and update it if found
        if let index = postsforUser.firstIndex(where: { $0.id == post.id }) {
            postsforUser[index] = post
        }
    }
    
    /// `handleVoteOnReply` is a function that allows the user to vote on a specific reply associated with a post.
    /// The function takes the vote type, the post, and the reply to be voted on as parameters.
    ///
    /// - Parameters:
    ///   - vote: The type of vote, which can be `.upvote` or `.downvote`.
    ///   - post: The `ClassPost` object representing the post to which the reply is associated.
    ///   - reply: The `Reply` object representing the reply to be voted on.
    /// - Returns: Void

    func handleVoteOnReply(_ vote: VoteType, onPost post: ClassPost, onReply reply: Reply) {
        // Check if the user is currently authenticated and obtain their phone number
        guard let user = Auth.auth().currentUser, let phoneNumber = user.phoneNumber else {
            // If the user is not authenticated, print an error message and exit the function.
            print("User is not authenticated.")
            return
        }
        
        // Check to make sure reply exists in Firebase
        let replyDoc = db.collection("replies").document(reply.id)
        
        // Check replyDoc existence
        replyDoc.getDocument() { [weak self] (document, error) in
            if let error = error {
                print("Error in retrieving document for reply in handleVoteOnReply(): \(error)")
                return
            }
            
            guard let document = document, document.exists else {
                print("Error: Reply does not exist")
                return
            }
            
            // Set `isVotingInProgress` to true to prevent multiple votes being submitted simultaneously
            self?.isVotingInProgress = true
            
            // Call to `firebaseManager`'s function to handle the vote action on the reply in Firestore
            self?.firebaseManager.handleVoteOnReplyFirestore(UpOrDown: vote, post: post, reply: reply) { error in
                if let error = error {
                    // If there was an error handling the vote action, print the error message in the console.
                    print("Error updating vote: \(error)")
                    return
                }
                
                // Fetch the updated reply from Firestore to update the local cache
                self?.firebaseManager.fetchReply(forPost: post, replyId: reply.id) { updatedReply, error in
                    if let updatedReply = updatedReply {
                        // If the updated reply is successfully fetched, update the local cache of replies.
                        DispatchQueue.main.async {
                            // Make sure to replace the `updateReplyArray(with:)` function with your own implementation.
                            // This function is used to update the local cache of replies with the updated reply.
                            self?.updateReplyArray(with: updatedReply)
                            
                            // Set `isVotingInProgress` to false since the vote action is complete
                            self?.isVotingInProgress = false
                            
                            // Notify the UI that the data has changed
                            self?.objectWillChange.send()
                        }
                    } else {
                        // If there was an error fetching the updated reply, print the error message in the console.
                        print(error?.localizedDescription ?? "Error fetching updated reply.")
                    }
                }
            }
        }
    }

    
    /// Private function to update the local cache of replies with an updated reply.
    /// The function replaces the old reply with the updated reply in the `curReplies` array.
    ///
    /// - Parameter updatedReply: The `Reply` object representing the updated reply.
    /// - Returns: Void
    private func updateReplyArray(with updatedReply: Reply) {
        // Find the index of the old reply in the `curReplies` array using the `firstIndex` method
        if let index = self.curReplies.firstIndex(where: { $0.id == updatedReply.id }) {
            // If the old reply is found in the array, update it with the updated reply
            self.curReplies[index] = updatedReply
        }
    }
    
    /// Function to fetch an updated version of a reply from Firestore.
    ///
    /// - Parameters:
    ///   - reply: The `Reply` object representing the reply for which to fetch the updated data.
    ///   - completion: A completion block called when the fetching is complete, providing either the updated `Reply` object or an error.
    /// - Returns: Void
    func fetchUpdatedReply(_ reply: Reply, completion: @escaping (Reply?, Error?) -> Void) {
        // Get a reference to the Firestore document for the specified reply ID
        let replyRef = db.collection("replies").document(reply.id)
        
        // Fetch the document from Firestore
        replyRef.getDocument { (document, error) in
            if let document = document, document.exists, let data = document.data() {
                // Check if the document exists and contains valid data
                // Try to create the updated reply object from the fetched data
                if let updatedReply = self.firebaseManager.createReplyFromData(data) {
                    // Reply creation succeeded, provide the updated reply to the completion block
                    completion(updatedReply, nil)
                } else {
                    // Reply creation failed, provide an error to the completion block
                    completion(nil, NSError(domain: "Reply data parsing error", code: 0))
                }
            } else if let error = error {
                // Error occurred while fetching the document, provide the error to the completion block
                completion(nil, error)
            } else {
                // Document not found, provide an error to the completion block
                completion(nil, NSError(domain: "Reply document not found", code: 0))
            }
        }
    }
    
    /// Function to delete a reply from a post in Firestore.
    ///
    /// - Parameters:
    ///   - reply: The `Reply` object representing the reply to be deleted.
    ///   - post: The `ClassPost` object representing the post from which the reply is to be deleted.
    /// - Returns: Void
    func deleteReply(_ reply: Reply, fromPost post: ClassPost) {
        // Call the `firebaseManager` function to delete the reply from Firestore
        firebaseManager.deleteReply(reply, fromPost: post) { [weak self] result in
            switch result {
            case .success:
                // If the reply is successfully deleted from Firestore, update the local data
                
                // Find the index of the reply in the `curReplies` array using the `firstIndex` method
                if let index = self?.curReplies.firstIndex(where: { $0.id == reply.id }) {
                    // If the reply is found, remove it from the `curReplies` array
                    self?.curReplies.remove(at: index)
                }
                
                // Update any other necessary data
                
                // Notify the UI that the data has changed
                self?.objectWillChange.send()
                
            case .failure(let error):
                // If there was an error while deleting the reply, print the error message in the console.
                print("Error deleting reply: \(error)")
            }
        }
    }
    
    /// Function to fetch posts for the current user from Firestore.
    ///
    /// - Parameter completion: A completion block called when fetching is complete, providing a boolean value indicating the success of the operation.
    /// - Returns: Void
    func getPostsForUser(completion: @escaping (Bool) -> Void) {
        // Check if the user's college information is available
        guard !self.userDoc.college.isEmpty else { return }
        
        // Call the `firebaseManager` function to get posts for the user based on college and phone number
        firebaseManager.getPostsForUser( user: self.userDoc.phoneNumber) { [weak self] posts, error in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Adding a 1-second delay before handling the response
                // If there is an error during fetching, handle the error
                if let error = error {
                    print("Error getting posts for user in UserProfileViewModel getPostsForUser(): \(error)")
                    self?.curError = "Something went wrong getting your posts. Close the app and try again."
                    completion(false) // Notify completion with failure
                    return
                }

                // If posts are successfully fetched, update the local `postsforUser` array
                self?.postsforUser = posts ?? []
                completion(true) // Notify completion with success
            }
        }
    }

    /// Function to handle updating fields for the user's profile.
    ///
    /// - Parameters:
    ///   - changedFields: A set of strings representing the fields that have been changed in the user's profile.
    ///   - updatedValues: A dictionary containing the updated values for the changed fields.
    /// - Returns: Void
    func handleEdit(changedFields: Set<String>, updatedValues: [String: Any]) {
        // Define a priority dictionary for fields to sort based on priority
        let fieldPriority: [String: Int] = ["classes": 1, "major": 1, "college": 1, "first_name": 2, "last_name": 2, "profile_picture": 2]
        
        // Sort the changedFields based on priority using the fieldPriority dictionary
        let sortedChangedFields = Array(changedFields).sorted(by: { fieldPriority[$0] ?? Int.max < fieldPriority[$1] ?? Int.max })
        
        // Create a DispatchGroup to handle the asynchronous updates
        let group = DispatchGroup()
        
        // Iterate through each field in the sortedChangedFields array and update the corresponding value
        for field in sortedChangedFields {
            if let value = updatedValues[field] {
                group.enter()
                // Call the `updateField` function to update the specific field for the user's profile
                updateField(forPhoneNumber: self.userDoc.phoneNumber, field: field, newValue: value) { err in
                    if let err = err {
                        // Handle error if updateField function returns an error
                        print("Error updating field \(field): \(err.localizedDescription)")
                    }
                    group.leave()
                }
            }
        }
        
        // Notify the group when all the updates are completed
        group.notify(queue: .main) {
            // Check if any fields have been changed
            if !sortedChangedFields.isEmpty {
                // Fetch the updated user document from Firestore
                self.firebaseManager.getDocument() { doc, err in
                    if let doc = doc {
                        DispatchQueue.main.async {
                            // Update the local `userDoc` with the new document data
                            self.userDoc = doc
                            
                            // Update post and replies with the new name if first_name or last_name has been changed
                            if sortedChangedFields.contains("first_name") || sortedChangedFields.contains("last_name") {
                                self.updateNameOnPostAndReplies()
                            }
                            
                            // Update the photo URL if profile_picture has been changed
                            if sortedChangedFields.contains("profile_picture") {
                                self.updatePhotoUrl()
                            }
                            
                            // Notify the UI that the data has changed
                            self.objectWillChange.send()
                        }
                    }
                }
            }
        }
    }
    /// Function to update the first name and last name on posts and replies after the user's profile name has been changed.
    ///
    /// - Returns: Void
    func updateNameOnPostAndReplies() {
        // Update first name and last name on posts for the user
        for post in postsforUser {
            if isAuthorPost(ofPost: post) {
                // Update the first name and last name on the post
                post.firstName = userDoc.firstName
                post.lastName = userDoc.lastName
                // Notify the UI that the data has changed
                objectWillChange.send()
            }
        }
        
        // Update first name and last name on posts for the class
        for post in postsForClass {
            if isAuthorPost(ofPost: post) {
                // Update the first name and last name on the post
                post.firstName = userDoc.firstName
                post.lastName = userDoc.lastName
                // Notify the UI that the data has changed
                objectWillChange.send()
            }
        }
        
        // Update first name and last name on replies
        for reply in curReplies {
            if isAuthorReply(ofReply: reply) {
                // Update the first name and last name on the reply
                reply.firstName = userDoc.firstName
                reply.lastName = userDoc.lastName
                // Notify the UI that the data has changed
                objectWillChange.send()
            }
        }
    }

    /// Function to update the profile picture URL on posts and replies after the user's profile picture has been changed.
    ///
    /// - Returns: Void
    func updatePhotoUrl() {
        // Update the profile picture URL on posts for the user
        for post in postsforUser {
            if isAuthorPost(ofPost: post) {
                // Update the profile picture URL on the post
                post.profilePicURL = userDoc.profilePictureURL
                // Notify the UI that the data has changed
                objectWillChange.send()
            }
        }
        
        // Update the profile picture URL on posts for the class
        for post in postsForClass {
            if isAuthorPost(ofPost: post) {
                // Update the profile picture URL on the post
                post.profilePicURL = userDoc.profilePictureURL
                // Notify the UI that the data has changed
                objectWillChange.send()
            }
        }
        
        // Update the profile picture URL on replies
        for reply in curReplies {
            if isAuthorReply(ofReply: reply) {
                // Update the profile picture URL on the reply
                reply.profilePicURL = userDoc.profilePictureURL
                // Notify the UI that the data has changed
                objectWillChange.send()
            }
        }
    }

    /// Function to update a specific field in the user's profile document in Firestore.
    /// - Parameters:
    ///   - phoneNumber: The phone number of the user whose profile is being updated.
    ///   - field: The field to be updated.
    ///   - newValue: The new value to be set for the specified field.
    ///   - completion: A completion handler that is called when the update is completed.
    ///                 It passes an error object if there was an error during the update.
    func updateField(forPhoneNumber phoneNumber: String, field: String, newValue: Any, completion: @escaping (Error?) -> Void) {
        // Switch statement to handle different fields and perform the corresponding update operation
        switch field {
        case "first_name":
            // Update the first name field
            updateFirstName(forPhoneNumber: phoneNumber, newFirstName: newValue as! String) { err in
                if let err = err {
                    completion(err) // Pass the error to the completion handler if there was an error
                } else {
                    completion(nil) // Call the completion handler with no error if the update was successful
                }
            }
        case "last_name":
            // Update the last name field
            updateLastName(forPhoneNumber: phoneNumber, newLastName: newValue as! String) { err in
                if let err = err {
                    completion(err) // Pass the error to the completion handler if there was an error
                } else {
                    completion(nil) // Call the completion handler with no error if the update was successful
                }
            }
        case "classes":
            // Update the classes field
            updateClasses(forPhoneNumber: phoneNumber, newClasses: newValue as! [String], oldClasses: self.userDoc.classes) { err in
                if let err = err {
                    completion(err) // Pass the error to the completion handler if there was an error
                } else {
                    completion(nil) // Call the completion handler with no error if the update was successful
                }
            }
        case "major":
            // Update the major field
            updateMajor(forPhoneNumber: phoneNumber, newMajor: newValue as! String) { err in
                if let err = err {
                    completion(err) // Pass the error to the completion handler if there was an error
                } else {
                    completion(nil) // Call the completion handler with no error if the update was successful
                }
            }
        case "college":
            // Update the college field
            updateCollege(forPhoneNumber: phoneNumber, newCollege: newValue as! String) { err in
                if let err = err {
                    completion(err) // Pass the error to the completion handler if there was an error
                } else {
                    completion(nil) // Call the completion handler with no error if the update was successful
                }
            }
        case "profile_picture":
            // Update the profile picture field
            updateProfilePicture(forPhoneNumber: phoneNumber, newProfilePicture: newValue as! UIImage) { err in
                if let err = err {
                    completion(err) // Pass the error to the completion handler if there was an error
                } else {
                    // Remove the cached image after a successful update
                    KingfisherManager.shared.cache.removeImage(forKey: phoneNumber)
                    completion(nil) // Call the completion handler with no error if the update was successful
                }
            }
        default:
            // Handle unsupported field
            print("Unsupported field: \(field)")
            let unsupportedError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Unsupported field: \(field)"])
            completion(unsupportedError) // Pass the unsupported error to the completion handler
        }
    }

    /// Function to update the first name of the user in their Firestore document.
    /// - Parameters:
    ///   - phoneNumber: The phone number of the user whose first name is being updated.
    ///   - newFirstName: The new first name to be set.
    ///   - completion: A completion handler that is called when the update is completed.
    ///                 It passes an error object if there was an error during the update.
    private func updateFirstName(forPhoneNumber phoneNumber: String, newFirstName: String, completion: @escaping (Error?) -> Void) {
        // Update the user document with the new first name
        let userDocLocation = db.collection("Users").document(phoneNumber)
        userDocLocation.updateData(["first_name" : newFirstName]) { error in
            if let error = error {
                print("Error updating document in updateFirstName(): \(error)")
                completion(error) // Pass the error to the completion handler if there was an error
            } else {
                // Update the first name on all post and reply documents made by the user
                self.firebaseManager.updateFirstNameOnPostsAndReplies(wherePhoneNumber: self.userDoc.phoneNumber, firstName: newFirstName) { error in
                    if let error = error {
                        print("Error in updateFirstNameOnPostsAndReplies(): \(error.localizedDescription) ")
                        completion(error) // Pass the error to the completion handler if there was an error
                    } else {
                        completion(nil) // Call the completion handler with no error if the update was successful
                    }
                }
            }
        }
    }
    
    /// Function to update the last name of the user in their Firestore document.
    /// - Parameters:
    ///   - phoneNumber: The phone number of the user whose last name is being updated.
    ///   - newLastName: The new last name to be set.
    ///   - completion: A completion handler that is called when the update is completed.
    ///                 It passes an error object if there was an error during the update.
    private func updateLastName(forPhoneNumber phoneNumber: String, newLastName: String, completion: @escaping (Error?) -> Void) {
        // Update the user document with the new last name
        let userDocLocation = db.collection("Users").document(phoneNumber)
        userDocLocation.updateData(["last_name" : newLastName]) { error in
            if let error = error {
                print("Error updating document in updateLastName(): \(error)")
                completion(error) // Pass the error to the completion handler if there was an error
            } else {
                // Update the last name on all post and reply documents made by the user
                self.firebaseManager.updateLastNameOnPostsAndReplies(wherePhoneNumber: self.userDoc.phoneNumber, lastName: newLastName) { error in
                    if let error = error {
                        print("Error in updateLastNameOnPostsAndReplies(): \(error.localizedDescription) ")
                        completion(error) // Pass the error to the completion handler if there was an error
                    } else {
                        completion(nil) // Call the completion handler with no error if the update was successful
                    }
                }
            }
        }
    }
   
    /// Function to update the classes of the user in their Firestore document.
    /// - Parameters:
    ///   - phoneNumber: The phone number of the user whose classes are being updated.
    ///   - newClasses: The new classes to be set.
    ///   - oldClasses: The current classes of the user before the update.
    ///   - completion: A completion handler that is called when the update is completed.
    ///                 It passes an error object if there was an error during the update.
    private func updateClasses(forPhoneNumber phoneNumber: String, newClasses: [String], oldClasses: [String], completion: @escaping (Error?) -> Void) {
        // Convert the classes arrays into sets for easier comparison
        let newClassesSet = Set<String>(newClasses)
        let oldClassesSet = Set<String>(oldClasses)
        
        // If the selected class is no longer in the new classes, update it to the first new class and fetch posts for that class
        if oldClasses.contains(selectedClass) && !newClasses.contains(selectedClass) {
            if let firstNewClass = newClassesSet.first {
                selectedClass = firstNewClass
                self.fetchFirst30PostsForClass { _ in }
            }
        }
        
        // Update the user document with the new classes
        let userDocLocation = db.collection("Users").document(phoneNumber)
        userDocLocation.updateData(["classes": Array(newClassesSet)]) { error in
            if let error = error {
                print("Error updating classes in updateClasses(): \(error)")
                completion(error) // Pass the error to the completion handler if there was an error
            } else {
                // Determine the classes to be removed (classes present in oldClasses but not in newClasses)
                let classesToRemove = Array(oldClassesSet.subtracting(newClassesSet))
                if classesToRemove.count > 0 {
                    // Remove all posts, their replies, as well as replies made by the user on other posts,
                    // in classes they are no longer taking
                    self.firebaseManager.deleteUsersPostAndRepliesAndRepliesOnEachPostFromClass(fromClasses: classesToRemove, forPhoneNumber: self.userDoc.phoneNumber, college: self.userDoc.college) { (res, err) in
                        if let err = err {
                            print("Error in deleteUsersPostAndRepliesAndRepliesOnEachPostFromClass(): \(err.localizedDescription)")
                            completion(err) // Pass the error to the completion handler if there was an error
                        } else {
                            completion(nil) // Call the completion handler with no error if the update was successful
                        }
                    }
                } else {
                    completion(nil) // Call the completion handler with no error if no classes need to be removed
                }
            }
        }
    }
    
    /// Function to update the major of the user in their Firestore document.
    /// - Parameters:
    ///   - phoneNumber: The phone number of the user whose major is being updated.
    ///   - newMajor: The new major to be set.
    ///   - completion: A completion handler that is called when the update is completed.
    ///                 It passes an error object if there was an error during the update.
    private func updateMajor(forPhoneNumber phoneNumber: String, newMajor: String, completion: @escaping (Error?) -> Void) {
        // Update the user document with the new major
        let userDocLocation = db.collection("Users").document(phoneNumber)
        userDocLocation.updateData(["major": newMajor]) { error in
            if let error = error {
                print("Error updating major in updateMajor(): \(error)")
                completion(error) // Pass the error to the completion handler if there was an error
            } else {
                completion(nil) // Call the completion handler with no error if the update was successful
            }
        }
        // There is currently nothing that relies on the major field, so it can be left empty
    }

    /// Function to update the college of the user in their Firestore document.
    /// - Parameters:
    ///   - phoneNumber: The phone number of the user whose college is being updated.
    ///   - newCollege: The new college to be set.
    ///   - completion: A completion handler that is called when the update is completed.
    ///                 It passes an error object if there was an error during the update.
    private func updateCollege(forPhoneNumber phoneNumber: String, newCollege: String, completion: @escaping (Error?) -> Void) {
        // Update the user document with the new college
        let userDocLocation = db.collection("Users").document(phoneNumber)
        userDocLocation.updateData(["college": newCollege]) { error in
            if let error = error {
                print("Error updating college in updateCollege(): \(error)")
                completion(error) // Pass the error to the completion handler if there was an error
                return
            }

            // Remove all posts, their replies, and replies made by that user on other posts, in the old college
            self.firebaseManager.removePostsRepliesAndPostsOfUserRepliesFromCollege(wherePhoneNumber: self.userDoc.phoneNumber, whereCollege: self.userDoc.college) { error in
                if let error = error {
                    print("Error in removePostsRepliesAndPostsOfUserRepliesFromCollege(): \(error)")
                    completion(error) // Pass the error to the completion handler if there was an error
                } else {
                    completion(nil) // Call the completion handler with no error if the update was successful
                }
            }
        }
    }

    /// Function to update the profile picture of the user in Firestore and related posts and replies.
    /// - Parameters:
    ///   - phoneNumber: The phone number of the user whose profile picture is being updated.
    ///   - newProfilePicture: The new profile picture to be set.
    ///   - completion: A completion handler that is called when the update is completed.
    ///                 It passes an error object if there was an error during the update.
    func updateProfilePicture(forPhoneNumber phoneNumber: String, newProfilePicture: UIImage, completion: @escaping (Error?) -> Void) {
        // Upload the new profile picture to Firebase Storage
        firebaseManager.uploadProfileImage(newProfilePicture) { res in
            switch res {
            case .success(let newProfilePicURL):
                // If the upload is successful, delete the old profile picture from Firestore
                self.firebaseManager.deleteOldProfilePictureFromFirestore(forPhoneNumber: phoneNumber) { (isDeleted, error) in
                    if let error = error {
                        print("Error deleting old profile picture: \(error)")
                        completion(error) // Pass the error to the completion handler if there was an error
                    } else {
                        print("Old profile picture deleted successfully.")
                        // Update the user document with the new profile picture URL
                        self.firebaseManager.updateProfilePictureURL(forPhoneNumber: phoneNumber, newProfilePicURL: newProfilePicURL) { error in
                            if let error = error {
                                print("Error updating user document: \(error)")
                                completion(error) // Pass the error to the completion handler if there was an error
                            } else {
                                // Update profile picture URL on user's posts and replies
                                self.firebaseManager.updateProfilePicOnPostsAndReplies(wherePhoneNumber: phoneNumber, profilePicURL: newProfilePicURL) { error in
                                    if let error = error {
                                        print("Error updating posts and replies: \(error)")
                                        completion(error) // Pass the error to the completion handler if there was an error
                                    } else {
                                        print("Posts and replies updated successfully.")
                                        completion(nil) // Call the completion handler with no error if the update was successful
                                    }
                                }
                            }
                        }
                    }
                }
            case .failure(let error):
                print("Error uploading profile image: \(error)")
                completion(error) // Pass the error to the completion handler if there was an error during image upload
            }
        }
    }
}
