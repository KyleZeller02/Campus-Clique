//
//  FireStoreManager.swift
//  Campus Clique
//
//  Created by Kyle Zeller on 5/30/23.
//

import Foundation
import FirebaseFirestore
import Firebase
import FirebaseAuth
import FirebaseStorage
import UIKit



/// this class represents a firebase manager. All queries and access to firebase should go through here. Except there are some methods for updaing profile that are in the view model
class FirestoreService: FirebaseManagerProtocol{
     
    

    let db = Firestore.firestore()

    /// Uploads a profile image to Firestore.
    ///
    /// - Parameters:
    ///   - image: The `UIImage` instance representing the profile picture to be uploaded.
    ///   - completion: Asynchronous callback with the URL of the uploaded image and an error if the operation fails.
    ///                 - `Result<String, Error>`: A result object containing either the URL of the uploaded image if the operation is successful, or an `Error` explaining the reason for the failure.
    func uploadProfileImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> ()) {
        
        // Adjusts the image's orientation to be up facing
        let fixedImage = image.fixedOrientation()
        
        // Attempts to convert the image to jpeg data, handling potential failure
        guard let imageData = fixedImage.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Couldn't convert image to data"])))
            return
        }

        // Generate a unique string using UUID to serve as image name
        let imageName = UUID().uuidString
        // Create a reference to where the image will be stored on Firebase
        let imageReference = Storage.storage().reference().child("profileImages/\(imageName)")
        
        // Create metadata for the image to be uploaded
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Begin the process to upload the image data to Firebase
        imageReference.putData(imageData, metadata: metadata) { _, error in
            // Handle any errors that may occur during the upload process
            if let error = error {
                return completion(.failure(error))
            }
            
            // After the image data has been successfully uploaded, attempt to retrieve the download URL
            imageReference.downloadURL { url, error in
                // Handle any errors that may occur when retrieving the download URL
                if let error = error {
                    return completion(.failure(error))
                }
                
                // Ensure a URL was successfully retrieved
                guard let url = url else {
                    return completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Couldn't retrieve URL"])))
                }
                
                // Return the URL as a string without updating the Firestore
                completion(.success(url.absoluteString))
            }
        }
    }

    
    

    /// Deletes the old profile picture of a user from Firestore.
    ///
    /// - Parameters:
    ///   - phoneNumber: The phone number of the user whose old profile picture needs to be deleted.
    ///   - completion: Asynchronous callback with a boolean indicating whether the operation was successful and an error if the operation fails.
    ///                 - `Bool`: `true` if the operation was successful; `false` otherwise.
    ///                 - `Error?`: An error object explaining the reason for the operation failure; `nil` if the operation is successful.
    func deleteOldProfilePictureFromFirestore(forPhoneNumber phoneNumber: String, completion: @escaping (Bool, Error?) -> Void) {
        // Get reference to user's document in Firestore. The user's phone number is being used as the unique document identifier.
        let userDocRef = db.collection("Users").document(phoneNumber)

        // Use the reference to fetch the document of the current user.
        userDocRef.getDocument { (document, error) in
            if let error = error {
                // An error occurred while fetching the user's document, this is handled by passing the error to the completion handler.
                completion(false, error)
            } else {
                // The user's document was successfully fetched, now we need to fetch the profile picture URL stored in the document.
                if let document = document,
                   let profilePictureURLString = document.data()?["profile_picture_url"] as? String,
                   let profilePictureURL = URL(string: profilePictureURLString) {
                    
                    // The URL of the profile picture was successfully retrieved. A reference to the file in Cloud Storage is created.
                    let storageRef = Storage.storage().reference(forURL: profilePictureURL.absoluteString)

                    // Using the reference to the file, we initiate the process of deleting the file.
                    storageRef.delete { error in
                        if let error = error {
                            // An error occurred while deleting the file, this is handled by passing the error to the completion handler.
                            completion(false, error)
                        } else {
                            // The file was deleted successfully, so the completion handler is called with a success status.
                            completion(true, nil)
                        }
                    }
                } else {
                    // The profile picture URL was not found in the user's document, so the completion handler is called with an error status.
                    completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Profile picture URL not found"]))
                }
            }
        }
    }



    /// Updates the profile picture on all posts and replies of a user in Firestore.
    ///
    /// - Parameters:
    ///   - phoneNumber: The phone number of the user whose profile picture needs to be updated.
    ///   - profilePicURL: The new profile picture URL.
    ///   - completion: Asynchronous callback with an error if the operation fails.
    ///                 - `Error?`: An error object explaining the reason for the operation failure; `nil` if the operation is successful.
    func updateProfilePicOnPostsAndReplies(forPhoneNumber phoneNumber: String, withUrl urlString: String, completion: @escaping (Bool, Error?) -> Void) {

        // This nested function handles updating the 'profile_picture_url' field in documents from a given collection
        // where the 'phone_number' field matches the user's phone number.
        // This function is a local utility within the outer function to avoid code repetition.
        func updateProfilePicUrlInCollection(_ collection: String) {
            // A reference to the user's documents where 'phone_number' field matches the user's phone number is created.
            let userDocsRef = db.collection(collection).whereField("phone_number", isEqualTo: phoneNumber)

            // Fetch the documents using the reference.
            userDocsRef.getDocuments { (querySnapshot, err) in
                // Handle potential error.
                if let err = err {
                    completion(false, err)
                } else if let querySnapshot = querySnapshot {
                    // Initialize a batch to perform multiple write operations.
                    let batch = self.db.batch()

                    // Iterate over each document from the fetched snapshot.
                    querySnapshot.documents.forEach { document in
                        // Get a reference to the document.
                        let docRef = self.db.collection(collection).document(document.documentID)
                        // Add an operation to the batch to update the 'profile_picture_url' field of the document.
                        batch.updateData(["profile_picture_url": urlString], forDocument: docRef)
                    }

                    // Commit the batch, i.e., perform all added operations.
                    batch.commit { (batchError) in
                        // Handle potential error in performing the batch operation.
                        if let batchError = batchError {
                            completion(false, batchError)
                        } else {
                            // If successful, call the completion handler with success status.
                            completion(true, nil)
                        }
                    }
                }
            }
        }
        // Use the utility function to update 'profile_picture_url' in the 'posts' collection.
        updateProfilePicUrlInCollection("posts")
        // Use the utility function to update 'profile_picture_url' in the 'replies' collection.
        updateProfilePicUrlInCollection("replies")
    }





    
    
    /// Fetches a specific `ClassPost` instance by ID from Firebase Firestore.
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the `ClassPost` to fetch.
    ///   - completion: Asynchronous callback with the fetched `ClassPost` instance or an error if the fetch operation fails.
    ///                 - `ClassPost?`: The fetched `ClassPost` instance if the fetch operation is successful; `nil` otherwise.
    ///                 - `Error?`: An error object explaining the reason for the fetch operation failure; `nil` if the operation is successful.
    func fetchPost(byId id: String, completion: @escaping (ClassPost?, Error?) -> Void) {
        // Fetch the document from the 'posts' collection in the database using the provided id
        db.collection("posts").document(id).getDocument { document, error in
            // Check if there was an error while fetching the document
            if let error = error {
                // If there's an error, complete the function and return the error
                completion(nil, error)
            // Check if the document exists and has been successfully fetched
            } else if let document = document, document.exists {
                // Attempt to retrieve the data from the document
                if let data = document.data(){
                    // Try to create a ClassPost object from the data
                    if let post = self.createClassPost(from: data) {
                        // If successful, complete the function and return the post
                        completion(post, nil)
                    }
                }
                // If creating the ClassPost failed
                else {
                    // Create a new error and complete the function, returning this error
                    let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not create post from data"])
                    completion(nil, error)
                }
            // If the document does not exist
            } else {
                // Create a new error indicating that the document does not exist and complete the function, returning this error
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No such document"])
                completion(nil, error)
            }
        }
    }

    
    
    // Fetches the next 30 `ClassPost` instances for a specific class from Firebase Firestore, starting from the last fetched post.
    ///
    /// - Parameters:
    ///   - selectedClass: The name of the class for which to fetch posts.
    ///   - college: The name of the college for which to fetch posts.
    ///   - lastSnapshot: The last document snapshot from the previous fetch operation. This is used as the starting point for the fetch operation.
    ///   - completion: Asynchronous callback with the fetched `ClassPost` instances, the last document snapshot, or an error if the fetch operation fails.
    ///                 - `[ClassPost]?`: An array of the fetched `ClassPost` instances if the fetch operation is successful; `nil` otherwise.
    ///                 - `DocumentSnapshot?`: The last document snapshot fetched. This can be used as the starting point for the next fetch operation.
    ///                 - `Error?`: An error object explaining the reason for the fetch operation failure; `nil` if the operation is successful.
    func fetchNext30PostsForClass(fromClass selectedClass: String, fromCollege college: String, after lastSnapshot: DocumentSnapshot?, completion: @escaping ([ClassPost]?, DocumentSnapshot?, Error?) -> Void) {
        // Define the Firestore query to fetch posts from a specific class and college, ordered by time stamp and limited to 30
        var query = db.collection("posts")
            .whereField("college", isEqualTo: college)
            .whereField("for_class", isEqualTo: selectedClass)
            .order(by: "time_stamp", descending: true)
            .limit(to: 30)
        
        // If lastSnapshot is provided, start the query after this snapshot
        if let lastSnapshot = lastSnapshot {
            query = query.start(afterDocument: lastSnapshot)
        }
        
        // Execute the query
        query.getDocuments { querySnapshot, error in
            // Check if there was an error while fetching the documents
            if let error = error {
                // If there's an error, complete the function and return the error
                completion(nil, nil, error)
                return
            }
            
            // If the query is successful, check if documents are returned
            guard let documents = querySnapshot?.documents else {
                // If no documents are returned, complete the function and return nil
                completion(nil, nil, nil)
                return
            }
            
            // Initialize an empty array of ClassPost
            var posts: [ClassPost] = []
            // Iterate over the returned documents
            for document in documents {
                // Fetch the data from the document
                let data = document.data()
                // Try to create a ClassPost object from the data
                if let post = self.createClassPost(from: data) {
                    // If successful, append the post to the posts array
                    posts.append(post)
                }
            }
            // Get the last document from the documents list
            let lastDocument = documents.last
            // Complete the function and return the posts array, the last document, and nil error
            completion(posts, lastDocument, nil)
        }
    }


    
    /// Creates a new `ClassPost` instance from the provided data dictionary.
    ///
    /// - Parameters:
    ///   - data: A dictionary containing key-value pairs corresponding to the properties of `ClassPost`. The keys should be string representations of the property names.
    /// - Returns: The created `ClassPost` instance if the creation operation is successful; `nil` otherwise.
    func createClassPost(from data: [String: Any]) -> ClassPost? {
        // Try to retrieve all necessary fields from the data dictionary, return nil if any field is missing or of incorrect type
        guard let firstname = data["first_name"] as? String,
              let lastname = data["last_name"] as? String,
              let postBody = data["post_body"] as? String,
              let forClass = data["for_class"] as? String,
              let date = data["time_stamp"] as? Double,
              let votes = data["votes"] as? Int64,
              let id = data["id"] as? String,
              let phoneNumber = data["phone_number"] as? String,
              let college = data["college"] as? String,
              let usersLikedData = data["users_liked"] as? [String],
              let usersDislikedData = data["users_disliked"] as? [String]
        else {
            // If any necessary data is missing, the function completes and returns nil
            return nil
        }

        // Convert usersLikedData and usersDislikedData arrays into Sets
        let usersLiked = Set<String>(usersLikedData)
        let usersDisliked = Set<String>(usersDislikedData)
        
        // Try to retrieve the profile picture URL, but it's optional so we don't fail if it's not there
        let profilePictureURL = data["profile_picture_url"] as? String

        // Create a ClassPost instance using the fetched data and return it
        return ClassPost(postBody: postBody, firstName: firstname, lastName: lastname, forClass: forClass, datePosted: date, votes: votes, id: id, usersLiked: usersLiked, usersDisliked: usersDisliked, phoneNumber: phoneNumber, college: college, picURL: profilePictureURL)
    }


    
    // Adds a new post to the Firestore.
    ///
    /// - Parameters:
    ///   - firstName: The first name of the user creating the post.
    ///   - lastName: The last name of the user creating the post.
    ///   - postBody: The body of the post.
    ///   - forClass: The class for which the post is being created.
    ///   - college: The college in which the post is being created.
    ///   - phoneNumber: The phone number of the user creating the post.
    ///   - profilePictureURL: The URL of the profile picture of the user creating the post.
    ///   - completion: Asynchronous callback with the created `ClassPost` instance and an error if the operation fails.
    ///                 - `ClassPost?`: The created `ClassPost` instance if the operation is successful; `nil` otherwise.
    ///                 - `Error?`: An error object explaining the reason for the operation failure; `nil` if the operation is successful.
    func addNewPost(firstName: String, lastName:String, postBody: String, forClass: String, college: String, phoneNumber: String, profilePictureURL:String, completion: @escaping (ClassPost?, Error?) -> Void) {
        // Create a reference to a new document within the 'posts' collection
        let postPath = db.collection("posts").document()
        // Retrieve the automatically generated ID of the new document
        let postId = postPath.documentID
        // Get the current time as the post's timestamp
        let datePosted = Date().timeIntervalSince1970
        
        // Create a dictionary to represent the new post's data
        let postData: [String: Any] = [
            "first_name": firstName,
            "last_name": lastName,
            "post_body": postBody,
            "for_class": forClass,
            "time_stamp": datePosted,
            "votes": Int64(0),
            "id": postId,
            "phone_number": phoneNumber,
            "college": college,
            "users_liked": [String](),
            "users_disliked" : [String](),
            "profile_picture_url": profilePictureURL
        ]

        // Set the new document's data to the post data
        postPath.setData(postData) { [weak self] error in
            // Check if there was an error while adding the new post
            if let error = error {
                print("Error adding new post: \(error)")
                // If there's an error, complete the function and return the error
                completion(nil, error)
            } else {
                // If the post was successfully added, create a ClassPost from the data and complete the function
                let post = self?.createClassPost(from: postData)
                completion(post, nil)
            }
        }
    }

    
    
    /// Fetches the first 30 `ClassPost` instances for a specific class from Firebase Firestore.
    ///
    /// - Parameters:
    ///   - className: The name of the class for which to fetch posts.
    ///   - college: The name of the college for which to fetch posts.
    ///   - completion: Asynchronous callback with the fetched `ClassPost` instances, the last document snapshot, or an error if the fetch operation fails.
    ///                 - `[ClassPost]?`: An array of the fetched `ClassPost` instances if the fetch operation is successful; `nil` otherwise.
    ///                 - `DocumentSnapshot?`: The last document snapshot fetched. This can be used as the starting point for the next fetch operation.
    ///                 - `Error?`: An error object explaining the reason for the fetch operation failure; `nil` if the operation is successful.
    func fetchFirst30PostsForClass(fromClass className: String, fromCollege college: String, completion: @escaping ([ClassPost]?, DocumentSnapshot?, Error?) -> Void) {
        
        // Guard clause to ensure none of the parameters are empty strings
        guard !className.isEmpty, !college.isEmpty else {
            completion(nil, nil, NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey : "Class name or college cannot be empty"]))
            return
        }
        
        // Query the database for posts corresponding to the given class in the given college
        db.collection("posts")
            .whereField("for_class", isEqualTo: className) // Filter by class name
            .whereField("college", isEqualTo: college) // Filter by college
            .order(by: "time_stamp", descending: true) // Order the results by timestamp in descending order
            .limit(to: 30) // Limit the query to the first 30 posts
            .getDocuments() { (querySnapshot, error) in
                
                // Handle any errors that might occur during the query
                if let error = error {
                    print("Error getting posts: \(error)")
                    completion(nil, nil, error)
                } else {
                    // If the query is successful, initialize an array to hold the posts
                    var posts = [ClassPost]()
                    
                    // Iterate through the documents returned by the query
                    for document in querySnapshot!.documents {
                        // Attempt to create a ClassPost object from each document
                        if let post = self.createClassPost(from: document.data()) {
                            // If successful, append the post to the posts array
                            posts.append(post)
                        }
                    }
                    
                    // Get the last document snapshot from the query results
                    let lastSnapshot = querySnapshot?.documents.last
                    
                    // Call the completion handler with the posts array, the last document snapshot, and nil for the error
                    completion(posts, lastSnapshot, nil)
                }
            }
    }




    /// Adds a reply to a given post in the Firestore.
    ///
    /// - Parameters:
    ///   - replyBody: The body of the reply.
    ///   - post: The post to which the reply is being added.
    ///   - firstName: The first name of the user replying.
    ///   - lastName: The last name of the user replying.
    ///   - phoneNumber: The phone number of the user replying.
    ///   - profilePictureURL: The URL of the profile picture of the user replying.
    ///   - completion: Asynchronous callback with the created `Reply` instance and an error if the operation fails.
    ///                 - `Result<Reply, Error>`: A result object containing either the created `Reply` instance if the operation is successful, or an `Error` explaining the reason for the failure.
    func addReply(_ replyBody: String, to post: ClassPost, firstName: String, lastName: String, phoneNumber: String, profilePictureURL: String, completion: @escaping (Result<Reply, Error>) -> Void) {
        // Guard clauses checking that none of the parameters are empty strings
        guard !replyBody.isEmpty else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Reply body is empty"])))
            return
        }
        guard !firstName.isEmpty else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "First name is empty"])))
            return
        }
        guard !lastName.isEmpty else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Last name is empty"])))
            return
        }
        guard !phoneNumber.isEmpty else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Phone number is empty"])))
            return
        }
        guard !profilePictureURL.isEmpty else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Profile picture URL is empty"])))
            return
        }

        // Use the top-level replies collection instead of a subcollection
        let replyPath = db.collection("replies").document()
        let replyId = replyPath.documentID

        // Capture the current date and time as a timestamp
        let datePosted = Date().timeIntervalSince1970

        // Organize the reply data
        let replyData: [String: Any] = [
            "first_name": firstName,
            "last_name" : lastName,
            "reply_body": replyBody,
            "time_stamp": datePosted,
            "id": replyId,
            "phone_number": phoneNumber,
            "votes": Int64(0),
            "users_liked": [String](),
            "users_disliked": [String](),
            "for_post_id": post.id, // Add the ID of the post this reply is for
            "profile_picture_url" : profilePictureURL,
            "for_class": post.forClass,
            "for_college": post.forCollege,
        ]

        // Set the reply data in the Firestore database
        replyPath.setData(replyData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                // Create a new Reply object using the createReplyFromData function and call the completion handler with it
                if let reply = self.createReplyFromData(replyData) {
                //completion with the reply object
                    completion(.success(reply))
                } else {
                    //completion with an error
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not create reply from data"])))
                }
            }
        }
    }

    
    /// Deletes a specific `ClassPost` instance and all its associated replies from Firebase Firestore.
    ///
    /// - Parameters:
    ///   - post: The `ClassPost` instance to delete.
    ///   - completion: Asynchronous callback with the status of the delete operation.
    ///                 - `Bool`: `true` if the delete operation is successful; `false` otherwise.
    func deletePostAndItsReplies(_ post: ClassPost, completion: @escaping (Bool) -> Void) {
        // Get a reference to the post to delete
        let postRef = db.collection("posts").document(post.id)
        
        // Get a reference to the collection of replies where the 'for_post_id' field is equal to the id of the post to delete
        let repliesRef = db.collection("replies")
            .whereField("for_post_id", isEqualTo: post.id)

        // Fetch the documents (replies) that match the query
        repliesRef.getDocuments { (querySnapshot, error) in
            // Check if there was an error fetching the documents
            if let error = error {
                print("Error getting replies: \(error.localizedDescription)")
                // Call the completion handler with false to indicate failure
                completion(false)
                return
            }

            // If there was no error, unwrap the fetched documents
            guard let documents = querySnapshot?.documents else {
                // If the documents cannot be unwrapped, call the completion handler with false to indicate failure
                completion(false)
                return
            }

            // Create a new batch for multiple write operations
            let batch = self.db.batch()

            // Iterate over the fetched documents (replies)
            for document in documents {
                // Add each document to the batch to be deleted
                batch.deleteDocument(document.reference)
            }

            // Add the post to the batch to be deleted
            batch.deleteDocument(postRef)

            // Commit the batch of write operations to the database
            batch.commit { (error) in
                // Check if there was an error committing the batch
                if let error = error {
                    print("Error removing documents: \(error)")
                    // Call the completion handler with false to indicate failure
                    completion(false)
                } else {
                    // If there was no error, call the completion handler with true to indicate success
                    completion(true)
                }
            }
        }
    }


    /// Commits a batch write operation to Firebase Firestore.
    ///
    /// - Parameters:
    ///   - batch: The `WriteBatch` instance containing the set of write operations to apply.
    ///   - completion: Asynchronous callback with the status of the commit operation.
    ///                 - `Bool`: `true` if the commit operation is successful; `false` otherwise.
    internal func commitBatch(_ batch: WriteBatch, completion: @escaping (Bool) -> Void) {
        // Try to commit the batch of operations to the database
        batch.commit { (error) in
            // If there was an error committing the batch
            if let error = error {
                // Print the error message
                print("Error executing batch: \(error)")
                // Call the completion handler with false to indicate that the operation failed
                completion(false)
            } else {
                // If there was no error, call the completion handler with true to indicate that the operation was successful
                completion(true)
            }
        }
    }

    
    /// Deletes a specific `Reply` from a `ClassPost`.
    ///
    /// - Parameters:
    ///   - reply: The `Reply` instance to delete.
    ///   - post: The `ClassPost` instance from which to delete the reply.
    ///   - completion: Asynchronous callback with the result of the delete operation.
    ///                 - `Result<Void, Error>`: A result object that can be either:
    ///                     - `.success(())` if the delete operation is successful.
    ///                     - `.failure(Error)` if the operation fails, containing an error explaining the reason for the failure.
    func deleteReply(_ reply: Reply, fromPost post: ClassPost, completion: @escaping (Result<Void, Error>) -> Void) {
        // Get the path to the document representing the reply in the 'replies' collection
        let replyPath = db.collection("replies").document(reply.id)

        // Attempt to delete the document at the specified path
        replyPath.delete { error in
            // If there was an error deleting the document
            if let error = error {
                // Call the completion handler with a failure result containing the error
                completion(.failure(error))
            } else {
                // If there was no error, call the completion handler with a success result containing Void
                completion(.success(()))
            }
        }
    }


   
    /// Performs a vote action (upvote or downvote) on a `ClassPost` for a specific `User`.
    ///
    /// - Parameters:
    ///   - vote: The type of vote (`VoteType`) to perform.
    ///   - post: The `ClassPost` on which to perform the vote.
    ///   - user: The `User` performing the vote.
    ///   - completion: Asynchronous callback with the status of the vote operation and an error if the operation fails.
    ///                 - `Bool`: `true` if the vote operation is successful; `false` otherwise.
    ///                 - `Error?`: An error object explaining the reason for the vote operation failure; `nil` if the operation is successful.
    
    func performAction(vote: VoteType, post: ClassPost, user: User, completion: @escaping (Bool, Error?) -> Void) {
        // Guard clause that checks if the user is authenticated (i.e., has a phone number)
        guard let phoneNumber = user.phoneNumber else {
            // If the user is not authenticated, call the completion handler with false and an error
            completion(false, NSError(domain: "No authenticated user", code: 401))
            return
        }
        
        // Get a reference to the document representing the post in the 'posts' collection
        let ref = db.collection("posts").document(post.id)
        
        // Depending on the type of vote (up or down), calculate the new vote count and the lists of users who liked and disliked the post
        let (votes, likedData, dislikedData) = vote == .up
            ? updateForUpVote(post: post, phoneNumber: phoneNumber)
            : updateForDownVote(post: post, phoneNumber: phoneNumber)
        
        // Update the post document in the database with the new vote count and the lists of users who liked and disliked the post
        ref.updateData(["votes": FieldValue.increment(votes), "users_liked": likedData, "users_disliked": dislikedData]) { error in
            // If there was an error updating the post
            if let error = error {
                // Call the completion handler with false and the error
                completion(false, error)
            } else {
                // If there was no error, call the completion handler with true and no error
                completion(true, nil)
            }
        }
    }

    
    
    /// Updates the `ClassPost` instance for an upvote action.
    ///
    /// - Parameters:
    ///   - post: The `ClassPost` instance to update.
    ///   - phoneNumber: The phone number of the user performing the upvote.
    /// - Returns: A tuple containing the updated vote count, the liked status, and the disliked status.
    ///            - `votes: Int64`: The updated vote count.
    ///            - `liked: Any`: The updated liked status.
    ///            - `disliked: Any`: The updated disliked status.
    func updateForUpVote(post: ClassPost, phoneNumber: String) -> (votes: Int64, liked: Any, disliked: Any) {
        // If the user already liked this post
        if post.usersLiked.contains(phoneNumber) {
            // Revoke the upvote, by decrementing the vote count by 1 and removing the user's phone number from the list of users who liked the post
            return (-1, FieldValue.arrayRemove([phoneNumber]), FieldValue.arrayRemove([phoneNumber]))
        } else if post.usersDisliked.contains(phoneNumber) {
            // If the user had previously disliked the post, revoke the downvote and cast an upvote by incrementing the vote count by 2, adding the user's phone number to the list of users who liked the post, and removing the user's phone number from the list of users who disliked the post
            return (2, FieldValue.arrayUnion([phoneNumber]), FieldValue.arrayRemove([phoneNumber]))
        } else {
            // If the user had neither liked nor disliked the post, cast an upvote by incrementing the vote count by 1 and adding the user's phone number to the list of users who liked the post
            return (1, FieldValue.arrayUnion([phoneNumber]), FieldValue.arrayRemove([phoneNumber]))
        }
    }

    
    
    // Updates the `ClassPost` instance for a downvote action.
    ///
    /// - Parameters:
    ///   - post: The `ClassPost` instance to update.
    ///   - phoneNumber: The phone number of the user performing the downvote.
    /// - Returns: A tuple containing the updated vote count, the liked status, and the disliked status.
    ///            - `votes: Int64`: The updated vote count.
    ///            - `liked: Any`: The updated liked status.
    ///            - `disliked: Any`: The updated disliked status.
    func updateForDownVote(post: ClassPost, phoneNumber: String) -> (votes: Int64, liked: Any, disliked: Any) {
        // If the user already disliked this post
        if post.usersDisliked.contains(phoneNumber) {
            // Revoke the downvote, by incrementing the vote count by 1 and removing the user's phone number from the list of users who disliked the post
            return (1, FieldValue.arrayRemove([phoneNumber]), FieldValue.arrayRemove([phoneNumber]))
        } else if post.usersLiked.contains(phoneNumber) {
            // If the user had previously liked the post, revoke the upvote and cast a downvote by decrementing the vote count by 2, removing the user's phone number from the list of users who liked the post, and adding the user's phone number to the list of users who disliked the post
            return (-2, FieldValue.arrayRemove([phoneNumber]), FieldValue.arrayUnion([phoneNumber]))
        } else {
            // If the user had neither liked nor disliked the post, cast a downvote by decrementing the vote count by 1 and adding the user's phone number to the list of users who disliked the post
            return (-1, FieldValue.arrayRemove([phoneNumber]), FieldValue.arrayUnion([phoneNumber]))
        }
    }
    
    
    /// Handles a vote action (upvote or downvote) on a `Reply` to a `ClassPost` in Firestore.
    ///
    /// - Parameters:
    ///   - vote: The type of vote (`VoteType`) to perform.
    ///   - post: The `ClassPost` to which the `Reply` belongs.
    ///   - reply: The `Reply` on which to perform the vote.
    ///   - completion: Asynchronous callback with an error if the operation fails.
    ///                 - `Error?`: An error object explaining the reason for the vote operation failure; `nil` if the operation is successful.
    func  handleVoteOnReplyFirestore(UpOrDown vote: VoteType, post: ClassPost, reply: Reply, completion: @escaping (Error?) -> Void) {
        
        // Guard clause checking for the presence of authenticated user and their phone number
            guard let user = Auth.auth().currentUser, let phoneNumber = user.phoneNumber, !phoneNumber.isEmpty else {
                completion(NSError(domain: "User authentication error", code: 401, userInfo: nil))
                return
            }
            
            // Guard clause checking for the presence of post and reply, and they are not empty strings
            guard !post.id.isEmpty,  !reply.id.isEmpty else {
                completion(NSError(domain: "Post or reply not found or is an empty string", code: 404, userInfo: nil))
                return
            }
        
        let ref = db.collection("replies").document(reply.id)
        
        // Variables for changing vote and like/dislike status
        let incrementByOne = FieldValue.increment(Int64(1))
        let decrementByOne = FieldValue.increment(Int64(-1))
        let incrementByTwo = FieldValue.increment(Int64(2))
        let decrementByTwo = FieldValue.increment(Int64(-2))
        
        let phoneNumberUnion = FieldValue.arrayUnion([phoneNumber])
        let phoneNumberRemove = FieldValue.arrayRemove([phoneNumber])

        // Perform the Firestore update operation based on the vote type
        switch vote {
        case VoteType.up:
            // User wants to upvote
            if reply.UsersLiked.contains(phoneNumber) {
                // User has already upvoted, undo the upvote
                ref.updateData(["votes": decrementByOne, "users_liked": phoneNumberRemove], completion: completion)
            } else if reply.UserDownVotes.contains(phoneNumber) {
                // User has previously downvoted, undo downvote and upvote
                ref.updateData(["votes": incrementByTwo, "users_liked": phoneNumberUnion, "users_disliked": phoneNumberRemove], completion: completion)
            } else {
                // User has not yet voted, upvote
                ref.updateData(["votes": incrementByOne, "users_liked": phoneNumberUnion], completion: completion)
            }
            ref.updateData(["users_disliked": phoneNumberRemove], completion: completion)

        case VoteType.down:
            // User wants to downvote
            if reply.UserDownVotes.contains(phoneNumber) {
                // User has already downvoted, undo the downvote
                ref.updateData(["votes": incrementByOne, "users_disliked": phoneNumberRemove], completion: completion)
            } else if reply.UsersLiked.contains(phoneNumber) {
                // User has previously upvoted, undo upvote and downvote
                ref.updateData(["votes": decrementByTwo, "users_liked": phoneNumberRemove, "users_disliked": phoneNumberUnion], completion: completion)
            } else {
                // User has not yet voted, downvote
                ref.updateData(["votes": decrementByOne, "users_disliked": phoneNumberUnion], completion: completion)
            }
            ref.updateData(["users_liked": phoneNumberRemove], completion: completion)
        
       
        }
    }

    
    
    /// Fetches a specific `Reply` for a given `ClassPost`.
    ///
    /// - Parameters:
    ///   - post: The `ClassPost` for which to fetch the reply.
    ///   - replyId: The identifier of the reply to fetch.
    ///   - completion: Asynchronous callback with the fetched reply and an error if the operation fails.
    ///                 - `Reply?`: The fetched `Reply` instance; `nil` if the operation fails.
    ///                 - `Error?`: An error object explaining the reason for the failure; `nil` if the operation is successful.
    func fetchReply(forPost post: ClassPost, replyId: String, completion: @escaping (Reply?, Error?) -> Void) {
        // Fetch the specific reply document from the "replies" collection in Firestore by its ID
        db.collection("replies").document(replyId).getDocument { (document, error) in
            // If there's an error (like no network connection), return it to the caller
            if let error = error {
                completion(nil, error)
            }
            // If the document exists and we can get the data from it
            else if let document = document, document.exists, let data = document.data() {
                // Create a Reply object from the Firestore data
                let reply = self.createReplyFromData(data)
                // Call the completion handler with the fetched Reply object
                completion(reply, nil)
            }
            else {
                // If the document doesn't exist, call the completion handler with an error
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No document found"]))
            }
        }
    }


    /// Deletes the posts, replies, and replies on each post of a user from a list of classes.
    ///
    /// - Parameters:
    ///   - fromClasses: A list of class identifiers from which to delete the posts, replies, and replies on each post.
    ///   - forPhoneNumber: The phone number of the user whose content should be deleted.
    ///   - college: The identifier of the college from which to delete the content.
    ///   - completion: Asynchronous callback with the status of the delete operation and an error if the operation fails.
    ///                 - `Bool`: `true` if the delete operation is successful; `false` otherwise.
    ///                 - `Error?`: An error object explaining the reason for the delete operation failure; `nil` if the operation is successful.
    
    func deleteUsersPostAndRepliesAndRepliesOnEachPostFromClass(fromClasses c: [String], forPhoneNumber: String, college: String, completion: @escaping (Bool, Error?) -> Void) {
        // Ensure the array of classes is not empty
        guard !c.isEmpty else {
            // If the array of classes is empty, call the completion handler with an error
            completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "The array of classes is empty."]))
            return
        }
        
        // Get the Firestore instance
        let db = Firestore.firestore()
        
        // Query all posts made by the user in the specified classes and college
        // Query all posts made by the user in the specified classes and college
        let query1 = db.collection("posts")
            .whereField("college", isEqualTo: college)         // Filter posts by the specified college
            .whereField("phone_number", isEqualTo: forPhoneNumber)  // Filter posts by the user's phone number
            .whereField("for_class", in: c)                 // Filter posts by the specified array of classes

        // Query all replies made by the user in the specified classes and college
        let query2 = db.collection("replies")
            .whereField("phone_number", isEqualTo: forPhoneNumber)  // Filter replies by the user's phone number
            .whereField("for_class", in: c)                 // Filter replies by the specified array of classes
            .whereField("college", isEqualTo: college)         // Filter replies by the specified college

        // Query all replies to posts that will be deleted
        


        var postsToDelete = [DocumentReference]()
        
        // Fetch documents for query1
        query1.getDocuments { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                // Add references of user's posts to the postsToDelete array
                for document in querySnapshot.documents {
                    postsToDelete.append(document.reference)
                }
            } else if let error = error {
                // If there's an error, call the completion handler with the error
                completion(false, error)
                return
            }

            // Fetch documents for query2
            query2.getDocuments { (querySnapshot, error) in
                let batch = db.batch()
                
                if let querySnapshot = querySnapshot {
                    // Delete user's replies in the classes
                    for document in querySnapshot.documents {
                        batch.deleteDocument(document.reference)
                    }
                } else if let error = error {
                    // If there's an error, call the completion handler with the error
                    completion(false, error)
                    return
                }
                
                if !postsToDelete.isEmpty {
                    // Query all replies to posts that will be deleted
                    let query3 = db.collection("replies")
                        .whereField("for_post_id", in: postsToDelete.map { $0.documentID })  // Filter replies by the post IDs of posts to be deleted

                    query3.getDocuments { (querySnapshot, error) in
                        if let querySnapshot = querySnapshot {
                            // Delete replies to posts
                            for document in querySnapshot.documents {
                                batch.deleteDocument(document.reference)
                            }
                        } else if let error = error {
                            // If there's an error, call the completion handler with the error
                            completion(false, error)
                            return
                        }

                        // Delete posts
                        for post in postsToDelete {
                            batch.deleteDocument(post)
                        }

                        // Commit the batch
                        batch.commit { (batchError) in
                            if let batchError = batchError {
                                // If there's an error in the batch deletion, call the completion handler with the error
                                print("Error deleting documents: \(batchError)")
                                completion(false, batchError)
                            } else {
                                // Batch delete completed successfully
                                print("Batch delete completed successfully.")
                                completion(true, nil)
                            }
                        }
                    }
                } else {
                    // No posts to delete but batch may contain user replies to delete
                    batch.commit { (batchError) in
                        if let batchError = batchError {
                            // If there's an error in the batch deletion, call the completion handler with the error
                            print("Error deleting documents: \(batchError)")
                            completion(false, batchError)
                        } else {
                            // Batch delete completed successfully
                            print("Batch delete completed successfully.")
                            completion(true, nil)
                        }
                    }
                }
            }
        }
    }









    
    /// Fetches all replies for a given `ClassPost`.
    ///
    /// - Parameters:
    ///   - post: The `ClassPost` for which to fetch the replies.
    ///   - completion: Asynchronous callback with an array of `Reply` instances.
    ///                 - `[Reply]`: An array of `Reply` instances corresponding to the `ClassPost`.
    func getReplies(forPost post: ClassPost, completion: @escaping ([Reply]) -> Void) {
       
        // Ensure that the post ID is not empty
        guard !post.id.isEmpty else {
            print("Error: post ID is empty.")
            completion([])
            return
        }

        // Get a reference to the "replies" collection in Firestore
        let repliesRef = db.collection("replies")
            .whereField("for_post_id", isEqualTo: post.id) // Filter replies where "for_post_id" matches the given post's id

        // Query the replies, ordered by "time_stamp" in ascending order (oldest first)
        repliesRef.order(by: "time_stamp", descending: false).getDocuments() { [weak self] querySnapshot, error in
            // Use [weak self] to prevent potential retain cycles and memory leaks

            // Check for errors and if querySnapshot is nil
            guard let self = self, let documents = querySnapshot?.documents else {
                // If there's an error or no documents found, print the error message (if available), call completion with an empty array, and return
                print("Error getting documents: \(error?.localizedDescription ?? "")")
                completion([])
                return
            }

            var replies: [Reply] = []

            // Loop through each document in the querySnapshot
            documents.forEach { document in
                let data = document.data()

                // Attempt to create a Reply object from the document's data
                if let reply = self.createReplyFromData(data) {
                    replies.append(reply)
                }
            }

            // Call the completion handler with the array of retrieved replies
            completion(replies)
        }
    }

    
    /// Creates a `Reply` instance from a dictionary of data.
    ///
    /// - Parameters:
    ///   - data: A dictionary containing key-value pairs mapping to `Reply` properties.
    /// - Returns: A `Reply` instance if the data is valid and matches the `Reply` structure; `nil` otherwise.
    func createReplyFromData(_ data: [String: Any]) -> Reply? {
        // Extract data from the data dictionary and perform type casting with guards
        guard let phoneNumber = data["phone_number"] as? String,
              let firstName = data["first_name"] as? String,
              let lastName = data["last_name"] as? String,
              let id = data["id"] as? String,
              let replyBody = data["reply_body"] as? String,
              let votes = data["votes"] as? Int64,
              let usersLiked = data["users_liked"] as? [String],
              let usersDisliked = data["users_disliked"] as? [String],
              let date = data["time_stamp"] as? Double,
              let postID = data["for_post_id"] as? String,
              let forClass = data["for_class"] as? String,
              let forCollege = data["for_college"] as? String
        else {
            // If any of the required data is missing or the type casting fails, return nil
            return nil
        }

        // Extract an optional profile picture URL
        let profilePicURL = data["profile_picture_url"] as? String

        // Create and return a new Reply object with the extracted data
        return Reply(replyBody: replyBody,
                     firstName: firstName,
                     lastName: lastName,
                     DatePosted: date,
                     votes: votes,
                     id: id,
                     usersLiked: Set(usersLiked),
                     usersDisliked: Set(usersDisliked),
                     phoneNumber: phoneNumber,
                     picURL: profilePicURL,
                     postID: postID,
                     inClass: forClass,
                     inCollege: forCollege)
    }


    /// Fetches all posts for a specific user from a specific college.
    ///
    /// - Parameters:
    
    ///   - user: The identifier of the user for whom to fetch the posts.
    ///   - completion: Asynchronous callback with an array of `ClassPost` instances and an error if the operation fails.
    ///                 - `[ClassPost]?`: An array of `ClassPost` instances if the operation is successful; `nil` otherwise.
    ///                 - `Error?`: An error object explaining the reason for the failure; `nil` if the operation is successful.
    // This method retrieves posts for a given user's phone number and sorts them by votes in descending order.
    func getPostsForUser(user: String, completion: @escaping ([ClassPost]?, Error?) -> Void) {
        // Check if the provided user's phone number is not empty
        guard !user.isEmpty else {
            // If the user's phone number is empty, return early
            return
        }

        // Get a reference to the "posts" collection in Firestore
        let path = db.collection("posts")

        // Create a query to retrieve posts where the "phone_number" field matches the provided user's phone number and sorted by "votes" in descending order
        let query = path
            .whereField("phone_number", isEqualTo: user)
            .order(by: "votes", descending: true)

        // Execute the query and get the documents from the Firestore
        query.getDocuments { querySnapshot, error in
            // Check if there are any documents in the query result
            guard let documents = querySnapshot?.documents else {
                // If there are no documents or there's an error, call the completion handler with nil for posts and the error
                completion(nil, error)
                return
            }

            var posts: [ClassPost] = []

            // Loop through each document in the query result
            for document in documents {
                let data = document.data()

                // Attempt to create a ClassPost object from the document's data
                if let post = self.createClassPost(from: data) {
                    posts.append(post)
                }
            }

            // Call the completion handler with the array of retrieved posts and nil for the error
            completion(posts, nil)
        }
    }

    
    
    
    /// Deletes all posts and replies of a user in Firestore.
    ///
    /// - Parameters:
    ///   - phoneNumber: The phone number of the user whose posts and replies need to be deleted.
    ///   - completion: Asynchronous callback with a boolean indicating whether the operation was successful and an error if the operation fails.
    ///                 - `Bool`: `true` if the operation was successful; `false` otherwise.
    ///                 - `Error?`: An error object explaining the reason for the operation failure; `nil` if the operation is successful.
    func deletePostsAndRepliesOfUser(phoneNumber: String, completion: @escaping (Bool, Error?) -> Void) {
        // Guard against an empty phone number
        guard !phoneNumber.isEmpty else {
            print("Error: Phone number is empty.")
            completion(false, nil)
            return
        }

        // Create a query to get all posts made by the user with the given phone number
        let query1 = db.collection("posts")
            .whereField("phone_number", isEqualTo: phoneNumber) // Filter posts where "phone_number" matches the provided phone number

        // Create a query to get all replies made by the user with the given phone number
        let query2 = db.collection("replies")
            .whereField("phone_number", isEqualTo: phoneNumber) // Filter replies where "phone_number" matches the provided phone number

        var postsToDelete = [DocumentReference]()

        // Fetch documents for query1
        query1.getDocuments { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                // Add references of user's posts to the postsToDelete array
                for document in querySnapshot.documents {
                    postsToDelete.append(document.reference)
                }
            } else if let error = error {
                // If there's an error, call the completion handler with the error
                completion(false, error)
                return
            }

            if !postsToDelete.isEmpty {
                // Create a query to get all replies to the posts that will be deleted
                let query3 = self.db.collection("replies").whereField("for_post_id", in: postsToDelete.map { $0.documentID })

                query3.getDocuments { (querySnapshot, error) in
                    if let querySnapshot = querySnapshot {
                        // Create a batch operation to delete all replies to the posts
                        let batch = self.db.batch()

                        // Delete replies to posts
                        for document in querySnapshot.documents {
                            batch.deleteDocument(document.reference)
                        }

                        // Fetch documents for query2 and delete replies
                        query2.getDocuments { (querySnapshot, error) in
                            if let querySnapshot = querySnapshot {
                                // Delete replies made by the user
                                for document in querySnapshot.documents {
                                    batch.deleteDocument(document.reference)
                                }
                            } else if let error = error {
                                // If there's an error, call the completion handler with the error
                                completion(false, error)
                                return
                            }

                            // Delete posts made by the user
                            for post in postsToDelete {
                                batch.deleteDocument(post)
                            }

                            // Commit the batch
                            batch.commit { (batchError) in
                                if let batchError = batchError {
                                    // If there's an error in the batch deletion, call the completion handler with the error
                                    print("Error deleting documents: \(batchError)")
                                    completion(false, batchError)
                                } else {
                                    // Batch delete completed successfully
                                    print("Batch delete completed successfully.")
                                    completion(true, nil)
                                }
                            }
                        }
                    } else if let error = error {
                        // If there's an error, call the completion handler with the error
                        completion(false, error)
                        return
                    }
                }
            } else {
                // If there are no posts to delete, call the completion handler with success
                completion(true, nil)
            }
        }
    }


    
    // Updates the profile picture on all posts and replies of a user in Firestore.
    ///
    /// - Parameters:
    ///   - phoneNumber: The phone number of the user whose profile picture needs to be updated.
    ///   - profilePicURL: The new profile picture URL.
    ///   - completion: Asynchronous callback with an error if the operation fails.
    ///                 - `Error?`: An error object explaining the reason for the operation failure; `nil` if the operation is successful.
    func updateProfilePicOnPostsAndReplies(wherePhoneNumber phoneNumber: String, profilePicURL: String, completion: @escaping (Error?) -> Void) {
        // Create a Firestore query to get all posts where "phone_number" matches the provided phone number
        let postsQuery = db.collection("posts").whereField("phone_number", isEqualTo: phoneNumber)
        
        // Create a Firestore query to get all replies where "phone_number" matches the provided phone number
        let repliesQuery = db.collection("replies").whereField("phone_number", isEqualTo: phoneNumber)
        
        // Create a dispatch group to synchronize the updates for both posts and replies
        let dispatchGroup = DispatchGroup()
        
        // Enter the dispatch group for updating posts
        dispatchGroup.enter()
        // Call the helper method to update the profile picture URL in batch for posts
        updateProfilePicURLInBatch(using: postsQuery, profilePicURL: profilePicURL) { error in
            // If there's an error during the update, call the completion handler with the error
            if let error = error {
                completion(error)
            }
            // Leave the dispatch group for updating posts
            dispatchGroup.leave()
        }
        
        // Enter the dispatch group for updating replies
        dispatchGroup.enter()
        // Call the helper method to update the profile picture URL in batch for replies
        updateProfilePicURLInBatch(using: repliesQuery, profilePicURL: profilePicURL) { error in
            // If there's an error during the update, call the completion handler with the error
            if let error = error {
                completion(error)
            }
            // Leave the dispatch group for updating replies
            dispatchGroup.leave()
        }
        
        // Notify the main queue when both updates for posts and replies are complete
        dispatchGroup.notify(queue: .main) {
            // Call the completion handler with nil to indicate success
            completion(nil)
        }
    }

    
    
    /// Private method to update the profile picture URL for all documents returned by the provided query in a batch operation.
    ///
    /// This method is used to handle mass updates of the user's profile picture URL in the Firestore database. It ensures the atomicity of the update process - meaning, all updates either complete successfully, or none of them are applied, preserving consistency in the database.
    ///
    /// - Parameters:
    ///   - query: A Firestore `Query` object that defines a set of conditions to be met by documents in the database. The profile picture URL of these documents will be updated.
    ///   - profilePicURL: The new profile picture URL to be updated in the documents.
    ///   - completion: Asynchronous callback that handles the result of the batch update operation.
    ///                 - `Error?`: An error object explaining the reason for the operation failure; `nil` if the operation is successful.
    ///
    /// - Note:
    /// The documents fetched by the provided query should have a field "profile_picture_url". If the field doesn't exist in a document, Firestore will return an error when trying to update it.
    private func updateProfilePicURLInBatch(using query: Query, profilePicURL: String, completion: @escaping (Error?) -> Void) {
        // Get the documents from the Firestore query
        query.getDocuments { (querySnapshot, error) in
            // Check for any error during the query
            if let error = error {
                // If there's an error, call the completion handler with the error
                completion(error)
            } else if let querySnapshot = querySnapshot {
                // If the query is successful and there are documents in the query result

                // Create a batch operation for updating the documents
                let batch = self.db.batch()

                // Loop through each document in the query result
                for document in querySnapshot.documents {
                    // Update the "profile_picture_url" field for each document with the provided profilePicURL
                    batch.updateData(["profile_picture_url": profilePicURL], forDocument: document.reference)
                }

                // Commit the batch to apply the updates
                batch.commit { (batchError) in
                    // Check for any error during the batch commit
                    // If there's an error, call the completion handler with the error
                    // If the batch commit is successful, call the completion handler with nil to indicate success
                    completion(batchError)
                }
            }
        }
    }


    /// Updates the profile picture URL of a user in Firestore.
    ///
    /// - Parameters:
    ///   - phoneNumber: The phone number of the user whose profile picture URL needs to be updated.
    ///   - newProfilePicURL: The new profile picture URL.
    ///   - completion: Asynchronous callback with an error if the operation fails.
    ///                 - `Error?`: An error object explaining the reason for the operation failure; `nil` if the operation is successful.
    func updateProfilePictureURL(forPhoneNumber phoneNumber: String, newProfilePicURL: String, completion: @escaping (Error?) -> Void) {
        // Guard against empty phone number and empty new profile picture URL
        guard !phoneNumber.isEmpty, !newProfilePicURL.isEmpty else {
            print("Error: Phone number or new profile picture URL is empty.")
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Phone number or new profile picture URL is empty."]))
            return
        }

        // Get a reference to the user's document in the "Users" collection
        let userDocRef = db.collection("Users").document(phoneNumber)

        // Update the "profile_picture_url" field in the user's document with the new profile picture URL
        userDocRef.updateData(["profile_picture_url": newProfilePicURL]) { error in
            // Check for any error during the update
            if let error = error {
                // If there's an error, call the completion handler with the error
                completion(error)
            } else {
                // If the update is successful, call the completion handler with nil to indicate success
                completion(nil)
            }
        }
    }


    
    /// Fetches the `UserDocument` from Firestore.
    ///
    /// - Parameter completion: Asynchronous callback with the fetched `UserDocument` and an error if the operation fails.
    ///                         - `UserDocument?`: The fetched `UserDocument` instance; `nil` if the operation fails.
    ///                         - `Error?`: An error object explaining the reason for the failure; `nil` if the operation is successful.
    func getDocument(completion: @escaping (UserDocument?, Error?) -> Void) {
        // Check if the current user's phone number is available
        guard let phoneNumber = Auth.auth().currentUser?.phoneNumber else {
            // If the phone number is not available, call the completion handler with an error
            completion(nil, FirebaseManagerError.currentUserPhoneNumberNotFound)
            return
        }

        // Get a reference to the user's document in the "Users" collection
        let doc = db.collection("Users").document(phoneNumber)

        // Fetch the document from Firestore
        doc.getDocument { documentSnapshot, error in
            if let error = error {
                // Check for any error during the fetch
                print("Error fetching document in getDocument: \(error)")
                // If there's an error, call the completion handler with the error
                completion(nil, error)
                return
            }

            // Unwrap and extract the data from the document snapshot
            guard let data = documentSnapshot?.data(),
                  let firstName = data["first_name"] as? String,
                  let lastName = data["last_name"] as? String,
                  let college = data["college"] as? String,
                  let major = data["major"] as? String,
                  let classes = data["classes"] as? [String],
                  let phoneNumber = data["phone_number"] as? String,
                  let profilePictureURL = data["profile_picture_url"] as? String else {
                // If there's missing or invalid data, call the completion handler with an error
                print("Invalid document data or missing fields")
                completion(nil, FirebaseManagerError.invalidDataOrMissingFields)
                return
            }

            // Create a UserDocument object from the retrieved data
            let retrievedDoc = UserDocument(firstName: firstName, lastName: lastName, college: college, major: major, classes: classes, phoneNumber: phoneNumber, profilePictureURL: profilePictureURL)

            // Call the completion handler with the retrieved UserDocument object and nil for error (indicating success)
            completion(retrievedDoc, nil)
        }
    }


    
    /// Updates the first name of a user on all their posts and replies in Firestore.
    ///
    /// - Parameters:
    ///   - phoneNumber: The phone number of the user whose name needs to be updated.
    ///   - name: The new first name of the user.
    ///   - completion: Asynchronous callback with an error if the operation fails.
    ///                 - `Error?`: An error object explaining the reason for the operation failure; `nil` if the operation is successful.
    func updateFirstNameOnPostsAndReplies(wherePhoneNumber phoneNumber: String, firstName name: String, completion: @escaping (Error?) -> Void) {
        // Create Firestore queries to get all posts where "phone_number" matches the provided phone number
        let query1 = db.collection("posts")
            .whereField("phone_number", isEqualTo: phoneNumber) // Filter posts where "phone_number" matches the provided phone number
        
        // Create Firestore queries to get all replies where "phone_number" matches the provided phone number
        let query2 = db.collection("replies")
            .whereField("phone_number", isEqualTo: phoneNumber) // Filter replies where "phone_number" matches the provided phone number

        let group = DispatchGroup() // Create a dispatch group to synchronize the async operations

        // Enter the dispatch group before the first async operation
        group.enter()
        // Call the helper method to update the first name field in the posts using query1
        updateQuery(query1, withName: name, field: "first_name") { error in
            if let error = error {
                // If there's an error during the update, print an error message and call the completion handler with the error
                print("Error updating posts: \(error)")
                completion(error)
            }
            // Leave the dispatch group after the first async operation completes
            group.leave()
        }

        // Repeat the process for the second async operation
        group.enter()
        // Call the helper method to update the first name field in the replies using query2
        updateQuery(query2, withName: name, field: "first_name") { error in
            if let error = error {
                // If there's an error during the update, print an error message and call the completion handler with the error
                print("Error updating replies: \(error)")
                completion(error)
            }
            // Leave the dispatch group after the second async operation completes
            group.leave()
        }

        // After both async operations in the group complete, call the completion handler on the main queue
        group.notify(queue: .main) {
            // Print a success message after all updates are completed
            print("Batch update completed successfully.")
            // Call the completion handler with nil to indicate success
            completion(nil)
        }
    }


    
    // Updates the last name of a user on all their posts and replies in Firestore.
    ///
    /// - Parameters:
    ///   - phoneNumber: The phone number of the user whose last name needs to be updated.
    ///   - name: The new last name of the user.
    ///   - completion: Asynchronous callback with an error if the operation fails.
    ///                 - `Error?`: An error object explaining the reason for the operation failure; `nil` if the operation is successful.
    // This method updates the last name for the user associated with the provided phone number in both posts and replies.
    func updateLastNameOnPostsAndReplies(wherePhoneNumber phoneNumber: String, lastName name: String, completion: @escaping (Error?) -> Void) {
        // Create Firestore queries to get all posts where "phone_number" matches the provided phone number
        let query1 = db.collection("posts")
            .whereField("phone_number", isEqualTo: phoneNumber) // Filter posts where "phone_number" matches the provided phone number
        
        // Create Firestore queries to get all replies where "phone_number" matches the provided phone number
        let query2 = db.collection("replies")
            .whereField("phone_number", isEqualTo: phoneNumber) // Filter replies where "phone_number" matches the provided phone number

        let group = DispatchGroup() // Create a dispatch group to synchronize the async operations

        // Enter the dispatch group before the first async operation
        group.enter()
        // Call the helper method to update the last name field in the posts using query1
        updateQuery(query1, withName: name, field: "last_name") { error in
            if let error = error {
                // If there's an error during the update, print an error message and call the completion handler with the error
                print("Error updating posts: \(error)")
                completion(error)
            }
            // Leave the dispatch group after the first async operation completes
            group.leave()
        }

        // Repeat the process for the second async operation
        group.enter()
        // Call the helper method to update the last name field in the replies using query2
        updateQuery(query2, withName: name, field: "last_name") { error in
            if let error = error {
                // If there's an error during the update, print an error message and call the completion handler with the error
                print("Error updating replies: \(error)")
                completion(error)
            }
            // Leave the dispatch group after the second async operation completes
            group.leave()
        }

        // After both async operations in the group complete, call the completion handler on the main queue
        group.notify(queue: .main) {
            // Print a success message after all updates are completed
            print("Batch update completed successfully.")
            // Call the completion handler with nil to indicate success
            completion(nil)
        }
    }


    /// Private method to update a specified field with a new value for all documents returned by the provided query in a batch operation.
    ///
    /// This method is used to handle mass updates of a specific field in the Firestore database. It ensures the atomicity of the update process - meaning, all updates either complete successfully, or none of them are applied, preserving consistency in the database.
    ///
    /// - Parameters:
    ///   - query: A Firestore `Query` object that defines a set of conditions to be met by documents in the database. The specified field of these documents will be updated.
    ///   - name: The new value to be updated in the specified field of the documents.
    ///   - field: The field in the documents to be updated.
    ///   - completion: Asynchronous callback that handles the result of the batch update operation.
    ///                 - `Error?`: An error object explaining the reason for the operation failure; `nil` if the operation is successful.
    ///
    /// - Note:
    /// The documents fetched by the provided query should have the field specified by the `field` parameter. If the field doesn't exist in a document, Firestore will return an error when trying to update it.
    private func updateQuery(_ query: Query, withName name: String, field: String, completion: @escaping (Error?) -> Void) {
        // Guard against empty name and field parameters
        guard !name.isEmpty, !field.isEmpty else {
            print("Error: Name or field parameter is empty.")
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Name or field parameter is empty."]))
            return
        }
        
        // Fetch documents based on the provided query
        query.getDocuments { (querySnapshot, error) in
            // Handle potential errors when fetching documents
            if let error = error {
                print("Error getting documents for the update: \(error)")
                // If there's an error, call the completion handler with the error
                completion(error)
            } else if let querySnapshot = querySnapshot {
                // If the fetch is successful and there are documents in the query result

                // Create a Firestore batch
                let batch = self.db.batch()

                // Loop through all the fetched documents
                for document in querySnapshot.documents {
                    // Update the specified field in each document with the new value (name)
                    batch.updateData([field: name], forDocument: document.reference)
                }

                // Commit the batch to apply all the updates
                batch.commit { (batchError) in
                    // Handle potential errors when committing the batch
                    if let batchError = batchError {
                        print("Error updating documents: \(batchError)")
                        // If there's an error, call the completion handler with the error
                        completion(batchError)
                    } else {
                        // If the batch update is successful, call the completion handler with nil to indicate success
                        completion(nil)
                    }
                }
            }
        }
    }



    /// Removes posts, replies, and posts of a user's replies from a specific college.
    ///
    /// - Parameters:
    ///   - phoneNumber: The phone number of the user whose content should be removed.
    ///   - college: The identifier of the college from which to remove the content.
    ///   - completion: Asynchronous callback with an error if the operation fails.
    ///                 - `Error?`: An error object explaining the reason for the operation failure; `nil` if the operation is successful.
    func removePostsRepliesAndPostsOfUserRepliesFromCollege(wherePhoneNumber phoneNumber: String, whereCollege college: String, completion: @escaping (Error?) -> Void) {
        // Guard against empty phoneNumber and college
        guard !phoneNumber.isEmpty, !college.isEmpty else {
            print("Error: Phone number or college parameter is empty.")
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Phone number or college parameter is empty."]))
            return
        }

        let db = Firestore.firestore()

        // Create Firestore query for posts where "phone_number" and "college" match the provided values
        let query1 = db.collection("posts")
            .whereField("phone_number", isEqualTo: phoneNumber) // Filter posts where "phone_number" matches the provided phone number
            .whereField("college", isEqualTo: college) // Filter posts where "college" matches the provided college

        // Create Firestore query for replies where "phone_number" and "college" match the provided values
        let query2 = db.collection("replies")
            .whereField("phone_number", isEqualTo: phoneNumber) // Filter replies where "phone_number" matches the provided phone number
            .whereField("college", isEqualTo: college) // Filter replies where "college" matches the provided college

        var postsToDelete = [DocumentReference]()

        // Fetch documents for query1
        query1.getDocuments { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    postsToDelete.append(document.reference)
                }
            } else if let error = error {
                // Handle potential error when fetching documents for query1
                completion(error)
                return
            }

            let batch = db.batch()

            if !postsToDelete.isEmpty {
                // Create Firestore query for replies to posts that will be deleted
                let query3 = db.collection("replies").whereField("for_post_id", in: postsToDelete.map { $0.documentID })

                // Fetch documents for query3 and delete replies to posts
                query3.getDocuments { (querySnapshot, error) in
                    if let querySnapshot = querySnapshot {
                        // Delete replies to posts
                        for document in querySnapshot.documents {
                            batch.deleteDocument(document.reference)
                        }
                    } else if let error = error {
                        // Handle potential error when fetching documents for query3
                        completion(error)
                        return
                    }
                }
            }

            // Fetch documents for query2 and delete replies
            query2.getDocuments { (querySnapshot, error) in
                if let querySnapshot = querySnapshot {
                    // Delete replies
                    for document in querySnapshot.documents {
                        batch.deleteDocument(document.reference)
                    }
                } else if let error = error {
                    // Handle potential error when fetching documents for query2
                    completion(error)
                    return
                }

                // Delete posts
                for post in postsToDelete {
                    batch.deleteDocument(post)
                }

                // Commit the batch to apply all the updates (deletions)
                batch.commit { (batchError) in
                    if let batchError = batchError {
                        // Handle potential error when committing the batch
                        print("Error deleting documents: \(batchError)")
                        completion(batchError)
                    } else {
                        // Batch delete completed successfully, call the completion handler with nil to indicate success
                        print("Batch delete completed successfully.")
                        completion(nil)
                    }
                }
            }
        }
    }



}


enum VoteType {
   case up
   case down
}

enum FirebaseManagerError: Error {
    case currentUserPhoneNumberNotFound
    case invalidDataOrMissingFields
}
