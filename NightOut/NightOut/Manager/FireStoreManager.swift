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

class FirestoreService:FirebaseManagerProtocol {
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
    
    

    
    func deleteProfilePicture(forEmail email: String, completion: @escaping (Bool, Error?) -> Void) {
        // Get reference to user's document in Firestore
        let userDocRef = db.collection("Users").document(email)

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

                            // Now, remove 'profile_pic_url' property from the user document
                            userDocRef.updateData([
                                "profile_picture_url": FieldValue.delete(),
                            ]) { err in
                                if let err = err {
                                    completion(false, err)
                                } else {
                                    // Define function to delete 'profile_pic_url' from documents in a given collection where the 'email' field matches the given email
                                    func deleteProfilePicUrl(fromCollection collection: String) {
                                        // Start a new batch
                                        let batch = self.db.batch()
                                        
                                        let userDocsRef = self.db.collection(collection).whereField("email", isEqualTo: email)

                                        userDocsRef.getDocuments { (querySnapshot, err) in
                                            if let err = err {
                                                completion(false, err)
                                            } else if let querySnapshot = querySnapshot {
                                                querySnapshot.documents.forEach { document in
                                                    let docRef = self.db.collection(collection).document(document.documentID)
                                                    batch.updateData([
                                                        "profile_picture_url": FieldValue.delete()
                                                    ], forDocument: docRef)
                                                }
                                                
                                                // Commit the batch
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

                                    // Remove 'profile_pic_url' from any posts and replies made by the user
                                    deleteProfilePicUrl(fromCollection: "posts")
                                    deleteProfilePicUrl(fromCollection: "replies")
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func updateProfilePicUrl(forEmail email: String, withUrl urlString: String, completion: @escaping (Bool, Error?) -> Void) {
        // Define function to update 'profile_pic_url' in documents in a given collection where the 'email' field matches the given email
        func updateProfilePicUrlInCollection(_ collection: String) {
            let userDocsRef = db.collection(collection).whereField("email", isEqualTo: email)
            
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
        guard let author = data["author"] as? String,
              let postBody = data["post_body"] as? String,
              let forClass = data["for_class"] as? String,
              let date = data["time_stamp"] as? Double,
              let votes = data["votes"] as? Int64,
              let id = data["id"] as? String,
              let email = data["email"] as? String,
              let college = data["college"] as? String,
              let usersLikedData = data["users_liked"] as? [String],
              let usersDislikedData = data["users_disliked"] as? [String]
        else {
            return nil
        }

        let usersLiked = Set<String>(usersLikedData)
        let usersDisliked = Set<String>(usersDislikedData)
        
        let profilePictureURL = data["profile_picture_url"] as? String

        return ClassPost(postBody: postBody, postAuthor: author, forClass: forClass, datePosted: date, votes: votes, id: id, usersLiked: usersLiked, usersDisliked: usersDisliked, email: email, college: college, picURL: profilePictureURL)
    }

    
    func addNewPost(author: String, postBody: String, forClass: String, college: String, email: String, profilePictureURL:String, completion: @escaping (ClassPost?, Error?) -> Void) {
        let postPath = db.collection("posts").document()
        let postId = postPath.documentID
        let datePosted = Date().timeIntervalSince1970
        
        let postData: [String: Any] = [
            "author": author,
            "post_body": postBody,
            "for_class": forClass,
            "time_stamp": datePosted,
            "votes": Int64(0),
            "id": postId,
            "email": email,
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




    func addReply(_ replyBody: String, to post: ClassPost, author: String, email: String, profilePictureURL:String, completion: @escaping (Result<Reply, Error>) -> Void) {
        // Use the top-level replies collection instead of a subcollection
        let replyPath = db.collection("replies").document()
        let replyId = replyPath.documentID
        let datePosted = Date().timeIntervalSince1970

        let replyData: [String: Any] = [
            "author": author,
            "reply_body": replyBody,
            "time_stamp": datePosted,
            "id": replyId,
            "email": email,
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
                let reply = Reply(replyBody: replyBody, replyAuthor: author, DatePosted: datePosted, votes: 0, id: replyId, usersLiked: Set([String]()), usersDisliked: Set([String]()), email: email, picURL: profilePictureURL, postID: post.id,inClass: post.forClass, inCollege: post.forCollege)
                completion(.success(reply))
            }
        }
    }


    func deletePostAndReplies(_ post: ClassPost, completion: @escaping (Bool) -> Void) {
        let postRef = db.collection("posts").document(post.id)
        let repliesRef = db.collection("replies")
            .whereField("for_post_id", isEqualTo: post.id)
            .whereField("for_class", isEqualTo: post.forClass)
            .whereField("for_college", isEqualTo: post.forCollege)

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
        guard let email = user.email else {
            completion(false, NSError(domain: "No authenticated user", code: 401))
            return
        }
        
        let ref = db.collection("posts").document(post.id)
        let (votes, likedData, dislikedData) = vote == .up ? updateForUpVote(post: post, email: email) : updateForDownVote(post: post, email: email)
        
        ref.updateData(["votes": FieldValue.increment(votes), "users_liked": likedData, "users_disliked": dislikedData]) { error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }
    
     func updateForUpVote(post: ClassPost, email: String) -> (votes: Int64, liked: Any, disliked: Any) {
        if post.usersLiked.contains(email) {
            // Revoke the upvote
            return (-1, FieldValue.arrayRemove([email]), FieldValue.arrayRemove([email]))
        } else if post.usersDisliked.contains(email) {
            // Revoke the downvote and cast an upvote
            return (2, FieldValue.arrayUnion([email]), FieldValue.arrayRemove([email]))
        } else {
            // Cast an upvote
            return (1, FieldValue.arrayUnion([email]), FieldValue.arrayRemove([email]))
        }
    }
    
     func updateForDownVote(post: ClassPost, email: String) -> (votes: Int64, liked: Any, disliked: Any) {
        if post.usersDisliked.contains(email) {
            // Revoke the downvote
            return (1, FieldValue.arrayRemove([email]), FieldValue.arrayRemove([email]))
        } else if post.usersLiked.contains(email) {
            // Revoke the upvote and cast a downvote
            return (-2, FieldValue.arrayRemove([email]), FieldValue.arrayUnion([email]))
        } else {
            // Cast a downvote
            return (-1, FieldValue.arrayRemove([email]), FieldValue.arrayUnion([email]))
        }
    }
    
    func handleVoteOnReplyFirestore(UpOrDown vote: VoteType, post: ClassPost, reply: Reply, completion: @escaping (Error?) -> Void) {
            guard let user = Auth.auth().currentUser, let email = user.email else {
                completion(NSError(domain: "User authentication error", code: 401, userInfo: nil))
                return
            }

        let ref = db.collection("replies").document(reply.id)

            // Variables for changing vote and like/dislike status
            let incrementByOne = FieldValue.increment(Int64(1))
            let decrementByOne = FieldValue.increment(Int64(-1))
            let incrementByTwo = FieldValue.increment(Int64(2))
            let decrementByTwo = FieldValue.increment(Int64(-2))

            let emailUnion = FieldValue.arrayUnion([email])
            let emailRemove = FieldValue.arrayRemove([email])

            // Perform the Firestore update operation based on the vote type
            switch vote {
            case VoteType.up:
                if reply.UsersLiked.contains(email) {
                    ref.updateData(["votes": decrementByOne, "users_liked": emailRemove], completion: completion)
                } else if reply.UserDownVotes.contains(email) {
                    ref.updateData(["votes": incrementByTwo, "users_liked": emailUnion, "users_disliked": emailRemove], completion: completion)
                } else {
                    ref.updateData(["votes": incrementByOne, "users_liked": emailUnion], completion: completion)
                }
                ref.updateData(["users_disliked": emailRemove], completion: completion)

            case VoteType.down:
                if reply.UserDownVotes.contains(email) {
                    ref.updateData(["votes": incrementByOne, "users_disliked": emailRemove], completion: completion)
                } else if reply.UsersLiked.contains(email) {
                    ref.updateData(["votes": decrementByTwo, "users_liked": emailRemove, "users_disliked": emailUnion], completion: completion)
                } else {
                    ref.updateData(["votes": decrementByOne, "users_disliked": emailUnion], completion: completion)
                }
                ref.updateData(["users_liked": emailRemove], completion: completion)

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

    func deleteUsersPostAndRepliesFromClass(fromClasses c: [String], email:String, college:String, completion: @escaping (Bool, Error?) -> Void) {
        guard !email.isEmpty, !college.isEmpty
              else {
            completion(false, nil)
            return
        }

        let queryPosts = db.collection("posts")
            .whereField("college", isEqualTo: college)
            .whereField("email", isEqualTo: email)
            .whereField("for_class", in: c)
        
        let queryReplies = db.collection("replies")
            .whereField("college", isEqualTo: college)
            .whereField("email", isEqualTo: email)
            .whereField("for_class", in: c)

        let postBatch = db.batch()
        let replyBatch = db.batch()
        
        // Deleting the posts
        queryPosts.getDocuments { [weak self] querySnapshot, error in
            guard let self = self else {
                completion(false, nil)
                return
            }

            if let error = error {
                // Handle the error
                print("Error retrieving documents: \(error)")
                completion(false, error)
                return
            }

            let documents = querySnapshot?.documents ?? []
            
            for document in documents {
                postBatch.deleteDocument(document.reference)
            }
            
            // Commit the post batch
            postBatch.commit { commitError in
                if let commitError = commitError {
                    // Handle the commit error
                    print("Error deleting posts: \(commitError)")
                    completion(false, commitError)
                } else {
                    // Deletion of posts successful
                    print("Posts deleted successfully.")
                }
            }
        }

        // Deleting the replies
        queryReplies.getDocuments { [weak self] querySnapshot, error in
            guard let self = self else {
                completion(false, nil)
                return
            }

            if let error = error {
                // Handle the error
                print("Error retrieving replies: \(error)")
                completion(false, error)
                return
            }

            let replyDocuments = querySnapshot?.documents ?? []

            for replyDocument in replyDocuments {
                replyBatch.deleteDocument(replyDocument.reference)
            }
            
            // Commit the reply batch
            replyBatch.commit { commitError in
                if let commitError = commitError {
                    // Handle the commit error
                    print("Error deleting replies: \(commitError)")
                    completion(false, commitError)
                } else {
                    // Deletion of replies successful
                    print("Replies deleted successfully.")
                    
                    // Completion handler should be invoked after both posts and replies are deleted
                    completion(true, nil)
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
            guard let email = data["email"] as? String ,
            let author = data["author"] as? String,
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

            return Reply(replyBody: replyBody, replyAuthor: author, DatePosted: date, votes: votes, id: id, usersLiked: Set(usersLiked), usersDisliked: Set(usersDisliked), email: email, picURL: profilePicURL, postID: postID, inClass: forClass, inCollege: forCollege)
        }

    func getPostsForUser( college: String, user:String, completion: @escaping ([ClassPost]?, Error?) -> Void) {
        guard  !user.isEmpty, !college.isEmpty else {return}
        let path = db.collection("posts")
        let query = path
            .whereField("email", isEqualTo: user)
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
    func deletePostsAndRepliesOfUserFromCollege(fromCollege: String, userEmail: String, completion: @escaping (Bool, Error?) -> Void) {
        // Get a reference to the Firestore database
        let db = Firestore.firestore()

        // Query for all posts from the specified college and by the specified user
        db.collection("posts")
            .whereField("college", isEqualTo: fromCollege)
            .whereField("email", isEqualTo: userEmail)
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
            .whereField("for_college", isEqualTo: fromCollege)
            .whereField("email", isEqualTo: userEmail)
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
    
    func deletePostsAndRepliesOfUser( userEmail: String, completion: @escaping (Bool, Error?) -> Void) {
        // Get a reference to the Firestore database
        let db = Firestore.firestore()

        // Query for all posts from the specified college and by the specified user
        db.collection("posts")
            .whereField("email", isEqualTo: userEmail)
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
            .whereField("email", isEqualTo: userEmail)
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


    func getDocument(completion: @escaping (UserDocument?, Error?) -> Void) {
            guard let email = Auth.auth().currentUser?.email else {
                completion(nil, FirebaseManagerError.currentUserEmailNotFound)
                return
            }
            
            let doc = db.collection("Users").document(email)
            
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
                      let email = data["email"] as? String,
                      let profilePictureURL = data["profile_picture_url"] as? String else {
                    print("Invalid document data or missing fields")
                    completion(nil, FirebaseManagerError.invalidDataOrMissingFields)
                    return
                }
                
                let retrievedDoc = UserDocument(FirstName: firstName, LastName: lastName, College: college,  Major: major, Classes: classes, Email: email, profilePictureURL: profilePictureURL)
                completion(retrievedDoc, nil)
            }
        }




}



enum FirebaseManagerError: Error {
    case currentUserEmailNotFound
    case invalidDataOrMissingFields
}
