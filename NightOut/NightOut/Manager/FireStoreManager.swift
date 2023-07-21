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

 enum VoteType {
    case up
    case down
}

class FirestoreService {
    let db = Firestore.firestore()

    func uploadProfileImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> ()) {

        let fixedImage = image.fixedOrientation()

        guard let imageData = fixedImage.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Couldn't convert image to data"])))
            return
        }

        let imageName = UUID().uuidString
        let imageReference = Storage.storage().reference().child("profileImages/\(imageName)")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        imageReference.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                return completion(.failure(error))
            }

            imageReference.downloadURL { url, error in
                if let error = error {
                    return completion(.failure(error))
                }

                guard let url = url else {
                    return completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Couldn't retrieve URL"])))
                }

                // Return the URL as a string without updating the Firestore
                completion(.success(url.absoluteString))
            }
        }
    }
    
    

    
    func deleteOldProfilePictureFromFirestore(forPhoneNumber phoneNumber: String, completion: @escaping (Bool, Error?) -> Void) {
        // Get reference to user's document in Firestore
        let userDocRef = db.collection("Users").document(phoneNumber)

        // Get the current user's document
        userDocRef.getDocument { (document, error) in
            if let error = error {
                // Handle error
                completion(false, error)
            } else {
                // Get the URL for the profile picture
                if let document = document, let profilePictureURLString = document.data()?["profile_picture_url"] as? String, let profilePictureURL = URL(string: profilePictureURLString) {

                    // Create a reference to the file in Cloud Storage
                    let storageRef = Storage.storage().reference(forURL: profilePictureURL.absoluteString)

                    // Delete the file
                    storageRef.delete { error in
                        if let error = error {
                            // Handle error
                            completion(false, error)
                        } else {
                            // File deleted successfully
                            completion(true, nil)
                        }
                    }
                } else {
                    // Profile picture URL not found
                    completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Profile picture URL not found"]))
                }
            }
        }
    }



    func updateProfilePicUrlForPostAndReplies(forPhoneNumber phoneNumber: String, withUrl urlString: String, completion: @escaping (Bool, Error?) -> Void) {
        // Define function to update 'profile_pic_url' in documents in a given collection where the 'email' field matches the given email
        func updateProfilePicUrlInCollection(_ collection: String) {
            let userDocsRef = db.collection(collection).whereField("phone_number", isEqualTo: phoneNumber)
            
            userDocsRef.getDocuments { (querySnapshot, err) in
                if let err = err {
                    completion(false, err)
                } else if let querySnapshot = querySnapshot {
                    let batch = self.db.batch()
                    
                    querySnapshot.documents.forEach { document in
                        let docRef = self.db.collection(collection).document(document.documentID)
                        batch.updateData(["profile_picture_url": urlString], forDocument: docRef)
                    }
                    
                    batch.commit { (batchError) in
                        if let batchError = batchError {
                            completion(false, batchError)
                        } else {
                            completion(true, nil)
                        }
                    }
                }
            }
        }
        updateProfilePicUrlInCollection("posts")
        updateProfilePicUrlInCollection("replies")
        
    }




    
    func fetchPosts(fromClass selectedClass: String, fromCollege college: String, completion: @escaping ([ClassPost]?, Error?) -> Void) {
            
        db.collection("posts")
            .whereField("college", isEqualTo: college)
            .whereField("for_class", isEqualTo: selectedClass)
            .order(by: "time_stamp", descending: true)
            .getDocuments { querySnapshot, error in
                
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    completion(nil, nil)
                    return
                }
                
                var posts: [ClassPost] = []
                
                for document in documents {
                    let data = document.data()
                    if let post = self.createClassPost(from: data){
                        posts.append(post)
                    }
                }
                completion(posts, nil)
            }
        }
    func fetchPost(byId id: String, completion: @escaping (ClassPost?, Error?) -> Void) {
        db.collection("posts").document(id).getDocument { document, error in
            if let error = error {
                completion(nil, error)
            } else if let document = document, document.exists {
                if let data = document.data(){
                    if let post = self.createClassPost(from: data) {
                        completion(post, nil)
                    }
                }
                else {
                    let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not create post from data"])
                    completion(nil, error)
                }
            } else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No such document"])
                completion(nil, error)
            }
        }
    }
    
    func fetchNext30PostsForClass(fromClass selectedClass: String, fromCollege college: String, after lastSnapshot: DocumentSnapshot?, completion: @escaping ([ClassPost]?, DocumentSnapshot?, Error?) -> Void) {
            var query = db.collection("posts")
                .whereField("college", isEqualTo: college)
                .whereField("for_class", isEqualTo: selectedClass)
                .order(by: "time_stamp", descending: true)
                .limit(to: 30)
            
            if let lastSnapshot = lastSnapshot {
                query = query.start(afterDocument: lastSnapshot)
            }
            
            query.getDocuments { querySnapshot, error in
                if let error = error {
                    completion(nil, nil, error)
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    completion(nil, nil, nil)
                    return
                }
                
                var posts: [ClassPost] = []
                for document in documents {
                    let data = document.data()
                    if let post = self.createClassPost(from: data) {
                        posts.append(post)
                    }
                }
                let lastDocument = documents.last
                completion(posts, lastDocument, nil)
            }
        }

    

     func createClassPost(from data: [String: Any]) -> ClassPost? {
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
            return nil
        }

        let usersLiked = Set<String>(usersLikedData)
        let usersDisliked = Set<String>(usersDislikedData)
        
        let profilePictureURL = data["profile_picture_url"] as? String

        return ClassPost(postBody: postBody, firstName: firstname, lastName: lastname, forClass: forClass, datePosted: date, votes: votes, id: id, usersLiked: usersLiked, usersDisliked: usersDisliked, phoneNumber: phoneNumber, college: college, picURL: profilePictureURL)
    }

    
    func addNewPost(firstName: String, lastName:String, postBody: String, forClass: String, college: String, phoneNumber: String, profilePictureURL:String, completion: @escaping (ClassPost?, Error?) -> Void) {
        let postPath = db.collection("posts").document()
        let postId = postPath.documentID
        let datePosted = Date().timeIntervalSince1970
        
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


        postPath.setData(postData) { [weak self] error in
            if let error = error {
                print("Error adding new post: \(error)")
                completion(nil, error)
            } else {
                let post = self?.createClassPost(from: postData)
                completion(post, nil)
            }
        }
    }
    func fetchFirst30PostsForClass(fromClass className: String, fromCollege college: String, completion: @escaping ([ClassPost]?, DocumentSnapshot?, Error?) -> Void) {
        db.collection("posts")
            .whereField("for_class", isEqualTo: className)
            .whereField("college", isEqualTo: college)
            .order(by: "time_stamp", descending: true)
            .limit(to: 30)
            .getDocuments() { (querySnapshot, error) in
                if let error = error {
                    print("Error getting posts: \(error)")
                    completion(nil, nil, error)
                } else {
                    var posts = [ClassPost]()
                    for document in querySnapshot!.documents {
                        if let post = self.createClassPost(from: document.data()) {
                            posts.append(post)
                        }
                    }
                    let lastSnapshot = querySnapshot?.documents.last
                    completion(posts, lastSnapshot, nil)
                }
            }
    }




    func addReply(_ replyBody: String, to post: ClassPost, firstName: String,LastName:String, phoneNumber: String, profilePictureURL:String, completion: @escaping (Result<Reply, Error>) -> Void) {
        // Use the top-level replies collection instead of a subcollection
        let replyPath = db.collection("replies").document()
        let replyId = replyPath.documentID
        let datePosted = Date().timeIntervalSince1970

        let replyData: [String: Any] = [
            "first_name": firstName,
            "last_name" : LastName,
            "reply_body": replyBody,
            "time_stamp": datePosted,
            "id": replyId,
            "phone_number": phoneNumber,
            "votes": 0,
            "users_liked": [String](),
            "users_disliked": [String](),
            "for_post_id": post.id, // Add the ID of the post this reply is for
            "profile_picture_url" : profilePictureURL,
            "for_class": post.forClass,
            "for_college": post.forCollege,
        ]

        replyPath.setData(replyData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                let reply = Reply(replyBody: replyBody, firstName: firstName,lastName: LastName, DatePosted: datePosted, votes: 0, id: replyId, usersLiked: Set([String]()), usersDisliked: Set([String]()), phoneNumber: phoneNumber, picURL: profilePictureURL, postID: post.id,inClass: post.forClass, inCollege: post.forCollege)
                completion(.success(reply))
            }
        }
    }


    func deletePostAndItsReplies(_ post: ClassPost, completion: @escaping (Bool) -> Void) {
        let postRef = db.collection("posts").document(post.id)
        let repliesRef = db.collection("replies")
            .whereField("for_post_id", isEqualTo: post.id)
            

        repliesRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting replies: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let documents = querySnapshot?.documents else {
                completion(false)
                return
            }

            let batch = self.db.batch()

            // Delete all replies
            for document in documents {
                batch.deleteDocument(document.reference)
            }

            // Delete the post
            batch.deleteDocument(postRef)

            // Commit the batch
            batch.commit { (error) in
                if let error = error {
                    print("Error removing documents: \(error)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }


    internal func commitBatch(_ batch: WriteBatch, completion: @escaping (Bool) -> Void) {
        batch.commit { (error) in
            if let error = error {
                print("Error executing batch: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    func deleteReply(_ reply: Reply, fromPost post: ClassPost, completion: @escaping (Result<Void, Error>) -> Void) {
        let replyPath = db.collection("replies").document(reply.id)

        replyPath.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    
    // In your FireStoreManager

   

     func performAction(vote: VoteType, post: ClassPost, user: User, completion: @escaping (Bool, Error?) -> Void) {
        guard let phoneNumber = user.phoneNumber else {
            completion(false, NSError(domain: "No authenticated user", code: 401))
            return
        }
        
        let ref = db.collection("posts").document(post.id)
        let (votes, likedData, dislikedData) = vote == .up ? updateForUpVote(post: post, phoneNumber: phoneNumber) : updateForDownVote(post: post, phoneNumber: phoneNumber)
        
        ref.updateData(["votes": FieldValue.increment(votes), "users_liked": likedData, "users_disliked": dislikedData]) { error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }
    
     func updateForUpVote(post: ClassPost, phoneNumber: String) -> (votes: Int64, liked: Any, disliked: Any) {
        if post.usersLiked.contains(phoneNumber) {
            // Revoke the upvote
            return (-1, FieldValue.arrayRemove([phoneNumber]), FieldValue.arrayRemove([phoneNumber]))
        } else if post.usersDisliked.contains(phoneNumber) {
            // Revoke the downvote and cast an upvote
            return (2, FieldValue.arrayUnion([phoneNumber]), FieldValue.arrayRemove([phoneNumber]))
        } else {
            // Cast an upvote
            return (1, FieldValue.arrayUnion([phoneNumber]), FieldValue.arrayRemove([phoneNumber]))
        }
    }
    
     func updateForDownVote(post: ClassPost, phoneNumber: String) -> (votes: Int64, liked: Any, disliked: Any) {
        if post.usersDisliked.contains(phoneNumber) {
            // Revoke the downvote
            return (1, FieldValue.arrayRemove([phoneNumber]), FieldValue.arrayRemove([phoneNumber]))
        } else if post.usersLiked.contains(phoneNumber) {
            // Revoke the upvote and cast a downvote
            return (-2, FieldValue.arrayRemove([phoneNumber]), FieldValue.arrayUnion([phoneNumber]))
        } else {
            // Cast a downvote
            return (-1, FieldValue.arrayRemove([phoneNumber]), FieldValue.arrayUnion([phoneNumber]))
        }
    }
    
    func handleVoteOnReplyFirestore(UpOrDown vote: VoteType, post: ClassPost, reply: Reply, completion: @escaping (Error?) -> Void) {
            guard let user = Auth.auth().currentUser, let phoneNumber = user.phoneNumber else {
                completion(NSError(domain: "User authentication error", code: 401, userInfo: nil))
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
                if reply.UsersLiked.contains(phoneNumber) {
                    ref.updateData(["votes": decrementByOne, "users_liked": phoneNumberRemove], completion: completion)
                } else if reply.UserDownVotes.contains(phoneNumber) {
                    ref.updateData(["votes": incrementByTwo, "users_liked": phoneNumberUnion, "users_disliked": phoneNumberRemove], completion: completion)
                } else {
                    ref.updateData(["votes": incrementByOne, "users_liked": phoneNumberUnion], completion: completion)
                }
                ref.updateData(["users_disliked": phoneNumberRemove], completion: completion)

            case VoteType.down:
                if reply.UserDownVotes.contains(phoneNumber) {
                    ref.updateData(["votes": incrementByOne, "users_disliked": phoneNumberRemove], completion: completion)
                } else if reply.UsersLiked.contains(phoneNumber) {
                    ref.updateData(["votes": decrementByTwo, "users_liked": phoneNumberRemove, "users_disliked": phoneNumberUnion], completion: completion)
                } else {
                    ref.updateData(["votes": decrementByOne, "users_disliked": phoneNumberUnion], completion: completion)
                }
                ref.updateData(["users_liked": phoneNumberRemove], completion: completion)

            default:
                break
            }
            
        }
    func fetchReply(forPost post: ClassPost, replyId: String, completion: @escaping (Reply?, Error?) -> Void) {
        db.collection("replies").document(replyId).getDocument { (document, error) in
            if let error = error {
                completion(nil, error)
            } else if let document = document, document.exists, let data = document.data() {
                let reply = self.createReplyFromData(data)
                completion(reply, nil)
            } else {
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No document found"]))
            }
        }
    }

    func deleteUsersPostAndRepliesAndRepliesOnEachPostFromClass(fromClasses c: [String], forPhoneNumber: String, college: String, completion: @escaping (Bool, Error?) -> Void) {
        guard !c.isEmpty else {
                completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "The array of classes is empty."]))
                return
            }
        // Query all posts made by user in classes we are deleting
        let query1 =
            db.collection("posts")
            .whereField("college", isEqualTo: college)
            .whereField("phone_number", isEqualTo: forPhoneNumber)
            .whereField("for_class", in: c)

        // Query all replies made by user in classes we are deleting
        let query2 = db.collection("replies")
            .whereField("phone_number", isEqualTo: forPhoneNumber)
            .whereField("for_class", in: c)
            .whereField("college", isEqualTo: college)

        var postsToDelete = [DocumentReference]()
        
        // Fetch documents for query1
        // Fetch documents for query1
            query1.getDocuments { (querySnapshot, error) in
                if let querySnapshot = querySnapshot {
                    for document in querySnapshot.documents {
                        postsToDelete.append(document.reference)
                    }
                } else if let error = error {
                    completion(false, error)
                    return
                }

                // Fetch documents for query2
                query2.getDocuments { (querySnapshot, error) in
                    
                    if let querySnapshot = querySnapshot {
                        let batch = self.db.batch()
                        // Delete user's replies in the classes
                        for document in querySnapshot.documents {
                            batch.deleteDocument(document.reference)
                        }
                        if postsToDelete.isEmpty {
                               print("No posts to delete.")
                               completion(true, nil)  // or however you want to handle this case
                               return
                           }
                        // Query all replies to posts that will be deleted
                        let query3 = self.db.collection("replies").whereField("for_post_id", in: postsToDelete.map { $0.documentID })

                        query3.getDocuments { (querySnapshot, error) in
                            if let querySnapshot = querySnapshot {
                                // Delete replies to posts
                                for document in querySnapshot.documents {
                                    batch.deleteDocument(document.reference)
                                }

                                // Delete posts
                                for post in postsToDelete {
                                    batch.deleteDocument(post)
                                }

                                // Commit the batch
                                batch.commit { (batchError) in
                                    if let batchError = batchError {
                                        print("Error deleting documents: \(batchError)")
                                        completion(false, batchError)
                                    } else {
                                        print("Batch delete completed successfully.")
                                        completion(true, nil)
                                    }
                                }
                            } else if let error = error {
                                completion(false, error)
                                return
                            }
                        }
                    } else if let error = error {
                        completion(false, error)
                        return
                    }
                }
            }
    }







    
     
    func getReplies(forPost post: ClassPost, completion: @escaping ([Reply]) -> Void) {
        // guard let college = UserManager.shared.currentUser?.College else { return }
        let repliesRef = db.collection("replies")
            .whereField("for_post_id", isEqualTo: post.id)
            
        
        repliesRef.order(by: "time_stamp", descending: false).getDocuments() { [weak self] querySnapshot, error in
            guard let self = self, let documents = querySnapshot?.documents else {
                print("Error getting documents: \(error?.localizedDescription ?? "")")
                completion([])
                return
            }

            var replies: [Reply] = []

            documents.forEach { document in
                let data = document.data()
                if let reply = self.createReplyFromData(data){
                    replies.append(reply)
                }
            }

            completion(replies)
        }
    }


        func createReplyFromData(_ data: [String: Any]) -> Reply? {
            guard let phoneNumber = data["phone_number"] as? String ,
            let firstName = data["first_name"] as? String,
            let lastName = data["last_name"] as? String,
            let id = data["id"] as? String ,
            let replyBody = data["reply_body"] as? String,
            let votes = data["votes"] as? Int64,
            let usersLiked = data["users_liked"] as? [String],
            let usersDisliked = data["users_disliked"] as? [String],
            let date = data["time_stamp"] as? Double,
            let postID = data["for_post_id"] as? String,
            let forClass = data["for_class"] as? String,
            let forCollege = data["for_college"] as? String
            
            else {
                return nil
            }
            
            let profilePicURL = data["profile_picture_url"] as? String

            return Reply(replyBody: replyBody, firstName: firstName, lastName:lastName , DatePosted: date, votes: votes, id: id, usersLiked: Set(usersLiked), usersDisliked: Set(usersDisliked), phoneNumber: phoneNumber, picURL: profilePicURL, postID: postID, inClass: forClass, inCollege: forCollege)
        }

    func getPostsForUser( college: String, user:String, completion: @escaping ([ClassPost]?, Error?) -> Void) {
        guard  !user.isEmpty, !college.isEmpty else {return}
        let path = db.collection("posts")
        let query = path
            .whereField("phone_number", isEqualTo: user)
            .order(by: "votes",descending: true)
            
        
        query.getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                completion(nil, error)
                return
            }
            
            var posts: [ClassPost] = []
            
            for document in documents {
                let data = document.data()
                if let post = self.createClassPost(from: data){
                    posts.append(post)
                }
            }
            completion(posts, nil)
        }
    }
    // this will aslo delete replies
    
    func deletePostsAndRepliesOfUser( phoneNumber: String, completion: @escaping (Bool, Error?) -> Void) {
        // Get a reference to the Firestore database
        let db = Firestore.firestore()

        // Query for all posts from the specified college and by the specified user
        db.collection("posts")
            .whereField("phone_number", isEqualTo: phoneNumber)
            .getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    completion(false, err)
                } else {
                    // Delete all the posts
                    for document in querySnapshot!.documents {
                        document.reference.delete { err in
                            if let err = err {
                                print("Error deleting document: \(err)")
                                completion(false, err)
                            } else {
                                print("Document successfully deleted")
                            }
                        }
                    }
                }
            }

        // Query for all replies from the specified college and by the specified user
        db.collection("replies")
            .whereField("phone_number", isEqualTo: phoneNumber)
            .getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting replies: \(err)")
                    completion(false, err)
                } else {
                    // Delete all the replies
                    for document in querySnapshot!.documents {
                        document.reference.delete { err in
                            if let err = err {
                                print("Error deleting reply: \(err)")
                                completion(false, err)
                            } else {
                                print("Reply successfully deleted")
                            }
                        }
                    }
                }
            }

        completion(true, nil)
    }

     func updateProfilePicOnPostsAndReplies(wherePhoneNumber phoneNumber: String, profilePicURL: String, completion: @escaping (Error?) -> Void) {
        let postsQuery = db.collection("posts").whereField("phone_number", isEqualTo: phoneNumber)
        let repliesQuery = db.collection("replies").whereField("phone_number", isEqualTo: phoneNumber)
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        updateProfilePicURLInBatch(using: postsQuery, profilePicURL: profilePicURL) { error in
            if let error = error {
                completion(error)
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        updateProfilePicURLInBatch(using: repliesQuery, profilePicURL: profilePicURL) { error in
            if let error = error {
                completion(error)
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(nil)
        }
    }
    private func updateProfilePicURLInBatch(using query: Query, profilePicURL: String, completion: @escaping (Error?) -> Void) {
            query.getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(error)
                } else if let querySnapshot = querySnapshot {
                    let batch = self.db.batch()

                    for document in querySnapshot.documents {
                        batch.updateData(["profile_picture_url": profilePicURL], forDocument: document.reference)
                    }

                    batch.commit { (batchError) in
                        completion(batchError)
                    }
                }
            }
        }
    func updateProfilePictureURL(forPhoneNumber phoneNumber: String, newProfilePicURL: String, completion: @escaping (Error?) -> Void) {
           let userDocRef = db.collection("Users").document(phoneNumber)
           userDocRef.updateData(["profile_picture_url": newProfilePicURL]) { error in
               if let error = error {
                   completion(error)
               } else {
                   completion(nil)
               }
           }
       }

    func getDocument(completion: @escaping (UserDocument?, Error?) -> Void) {
            guard let phoneNumber = Auth.auth().currentUser?.phoneNumber else {
                completion(nil, FirebaseManagerError.currentUserEmailNotFound)
                return
            }
            
            let doc = db.collection("Users").document(phoneNumber)
            
            doc.getDocument { documentSnapshot, error in
                if let error = error {
                    print("Error fetching document in getDocument: \(error)")
                    completion(nil, error)
                    return
                }
                
                guard let data = documentSnapshot?.data(),
                      let firstName = data["first_name"] as? String,
                      let lastName = data["last_name"] as? String,
                      let college = data["college"] as? String,
                     
                      let major = data["major"] as? String,
                      let classes = data["classes"] as? [String],
                      let phoneNumber = data["phone_number"] as? String,
                      let profilePictureURL = data["profile_picture_url"] as? String else {
                    print("Invalid document data or missing fields")
                    completion(nil, FirebaseManagerError.invalidDataOrMissingFields)
                    return
                }
                
                let retrievedDoc = UserDocument(FirstName: firstName, LastName: lastName, College: college,  Major: major, Classes: classes, phoneNumber: phoneNumber, profilePictureURL: profilePictureURL)
                completion(retrievedDoc, nil)
            }
        }

    func updateFirstNameOnPostsAndReplies(wherePhoneNumber phoneNumber: String, firstName name: String, completion: @escaping (Error?) -> Void) {
        let query1 = db.collection("posts").whereField("phone_number", isEqualTo: phoneNumber)
        let query2 = db.collection("replies").whereField("phone_number", isEqualTo: phoneNumber)
        
        let group = DispatchGroup() // Create a dispatch group

        // Enter group before each async operation
        group.enter()
        updateQuery(query1, withName: name, field: "first_name") { error in
            if let error = error {
                print("Error updating posts: \(error)")
                completion(error)
            }
            // Leave group after each async operation completes
            group.leave()
        }

        // Repeat for the second query
        group.enter()
        updateQuery(query2, withName: name, field: "first_name") { error in
            if let error = error {
                print("Error updating posts: \(error)")
                completion(error)
            }
            // Leave group after each async operation completes
            group.leave()
        }

        // After all operations complete, call the completion handler
        group.notify(queue: .main) {
            print("Batch update completed successfully.")
            completion(nil)
        }
    }

    

    func updateLastNameOnPostsAndReplies(wherePhoneNumber phoneNumber: String, lastName name: String, completion: @escaping (Error?) -> Void) {
        let query1 = db.collection("posts").whereField("phone_number", isEqualTo: phoneNumber)
        let query2 = db.collection("replies").whereField("phone_number", isEqualTo: phoneNumber)
        
        let group = DispatchGroup() // Create a dispatch group

        // Enter group before each async operation
        group.enter()
        updateQuery(query1, withName: name, field: "last_name") { error in
            if let error = error {
                print("Error updating posts: \(error)")
                completion(error)
            }
            // Leave group after each async operation completes
            group.leave()
        }

        // Repeat for the second query
        group.enter()
        updateQuery(query2, withName: name, field: "last_name") { error in
            if let error = error {
                print("Error updating replies: \(error)")
                completion(error)
            }
            group.leave()
        }

        // After all operations complete, call the completion handler
        group.notify(queue: .main) {
            print("Batch update completed successfully.")
            completion(nil)
        }
    }

    private func updateQuery(_ query: Query, withName name: String, field: String, completion: @escaping (Error?) -> Void) {
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents for the update: \(error)")
                completion(error)
            } else if let querySnapshot = querySnapshot {
                let batch = self.db.batch()

                for document in querySnapshot.documents {
                    batch.updateData([field: name], forDocument: document.reference)
                }

                batch.commit { (batchError) in
                    if let batchError = batchError {
                        print("Error updating documents: \(batchError)")
                        completion(batchError)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }

    func removePostsRepliesAndPostsOfUserRepliesFromCollege(wherePhoneNumber phoneNumber:String, whereCollege college:String, completion: @escaping (Error?) -> Void){
        let query1 = db.collection("posts")
            .whereField("phone_number", isEqualTo: phoneNumber)
            .whereField("college", isEqualTo: college)
        
        let query2 = db.collection("replies")
            .whereField("phone_number", isEqualTo: phoneNumber)
            .whereField("college", isEqualTo: college)
        
        var postsToDelete = [DocumentReference]()
        
        // Fetch documents for query1
        query1.getDocuments { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    postsToDelete.append(document.reference)
                }
            } else if let error = error {
                completion(error)
                return
            }
            if !postsToDelete.isEmpty {
                let query3 = self.db.collection("replies").whereField("for_post_id", in: postsToDelete.map { $0.documentID })
                
                query3.getDocuments { (querySnapshot, error) in
                    if let querySnapshot = querySnapshot {
                        let batch = self.db.batch()
                        
                        // Delete replies to posts
                        for document in querySnapshot.documents {
                            batch.deleteDocument(document.reference)
                        }
                        
                        // Fetch documents for query2 and delete replies
                        query2.getDocuments { (querySnapshot, error) in
                            if let querySnapshot = querySnapshot {
                                for document in querySnapshot.documents {
                                    batch.deleteDocument(document.reference)
                                }
                            } else if let error = error {
                                completion(error)
                                return
                            }
                            
                            // Delete posts
                            for post in postsToDelete {
                                batch.deleteDocument(post)
                            }
                            
                            // Commit the batch
                            batch.commit { (batchError) in
                                if let batchError = batchError {
                                    print("Error deleting documents: \(batchError)")
                                    completion(batchError)
                                } else {
                                    print("Batch delete completed successfully.")
                                    completion(nil)
                                }
                            }
                        }
                    } else if let error = error {
                        completion(error)
                        return
                    }
                }
            } else {
               completion(nil)
            }
            // Query all replies to posts that will be deleted
           
        }
    }







}



enum FirebaseManagerError: Error {
    case currentUserEmailNotFound
    case invalidDataOrMissingFields
}
