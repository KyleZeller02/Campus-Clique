//
//  FireStoreManager.swift
//  Campus Clique
//
//  Created by Kyle Zeller on 5/30/23.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

enum VoteType {
    case up
    case down
}

class FirestoreService {
    let db = Firestore.firestore()
    
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

    

    private func createClassPost(from data: [String: Any]) -> ClassPost? {
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

        return ClassPost(postBody: postBody, postAuthor: author, forClass: forClass, datePosted: date, votes: votes, id: id, usersLiked: usersLiked, usersDisliked: usersDisliked, email: email, college: college)
    }
    
    func addNewPost(author: String, postBody: String, forClass: String, college: String, email: String, completion: @escaping ((String, Bool)?) -> Void) {
        let postPath = db.collection("posts").document()
        let postId = postPath.documentID
        let datePosted = Date().timeIntervalSince1970

        let postData: [String: Any] = [
            "author": author,
            "post_body": postBody,
            "for_class": forClass,
            "time_stamp": datePosted,
            "votes": 0,
            "id": postId,
            "email": email,
            "college": college,
            "users_liked": [String](),
            "users_disliked" : [String]()
        ]

        postPath.setData(postData) { error in
            if let error = error {
                print("Error adding new post: \(error)")
                completion(nil)
            } else {
                completion((postId, true))
            }
        }
    }

    func addReply(_ replyBody: String, to post: ClassPost, author: String, email: String, completion: @escaping (Result<Replies, Error>) -> Void) {
        let postPath = db.collection("posts").document(post.id)
        let replyPath = postPath.collection("replies").document()
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
            "users_disliked": [String]()
        ]

        replyPath.setData(replyData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                let reply = Replies(replyBody: replyBody, replyAuthor: author, DatePosted: datePosted, votes: 0, id: replyId, usersLiked: Set([String]()), usersDisliked: Set([String]()), email: email)
                completion(.success(reply))
            }
        }
    }

    func deletePostAndReplies(_ post: ClassPost, completion: @escaping (Bool) -> Void) {
        let postRef = db.collection("posts").document(post.id)
        let repliesRef = postRef.collection("replies")
        
        let batch = db.batch()
        
        repliesRef.getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents, error == nil else {
                print("Error getting replies: \(error!)")
                completion(false)
                return
            }
            
            documents.forEach { batch.deleteDocument($0.reference) }
            batch.deleteDocument(postRef)
            
            self.commitBatch(batch, completion: completion)
        }
    }

    private func commitBatch(_ batch: WriteBatch, completion: @escaping (Bool) -> Void) {
        batch.commit { (error) in
            if let error = error {
                print("Error executing batch: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    func deleteReply(_ reply: Replies, fromPost post: ClassPost, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let college = UserManager.shared.currentUser?.College else {
                let error = NSError(domain: "YourDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing college information"])
                completion(.failure(error))
                return
            }
        

        let replyPath = db.collection("posts").document(post.id).collection("replies").document(reply.id)

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
    func performActionOnReply(vote: VoteType, post: ClassPost, reply: Replies, user: User, completion: @escaping (Bool, Error?) -> Void) {
            guard let email = user.email else {
                completion(false, NSError(domain: "No authenticated user", code: 401))
                return
            }

            let ref = db.collection("posts").document(post.id).collection("replies").document(reply.id)

            var updateData: [String: Any] = [:]

            switch vote {
            case .up:
                if reply.UsersLiked.contains(email) {
                    updateData = [
                        "votes": FieldValue.increment(Int64(-1)),
                        "users_liked": FieldValue.arrayRemove([email])
                    ]
                } else if reply.UserDownVotes.contains(email) {
                    updateData = [
                        "votes": FieldValue.increment(Int64(2)),
                        "users_liked": FieldValue.arrayUnion([email]),
                        "users_disliked": FieldValue.arrayRemove([email])
                    ]
                } else {
                    updateData = [
                        "votes": FieldValue.increment(Int64(1)),
                        "users_liked": FieldValue.arrayUnion([email])
                    ]
                }
                updateData["users_disliked"] = FieldValue.arrayRemove([email])

            case .down:
                if reply.UserDownVotes.contains(email) {
                    updateData = [
                        "votes": FieldValue.increment(Int64(1)),
                        "users_disliked": FieldValue.arrayRemove([email])
                    ]
                } else if reply.UsersLiked.contains(email) {
                    updateData = [
                        "votes": FieldValue.increment(Int64(-2)),
                        "users_liked": FieldValue.arrayRemove([email]),
                        "users_disliked": FieldValue.arrayUnion([email])
                    ]
                } else {
                    updateData = [
                        "votes": FieldValue.increment(Int64(-1)),
                        "users_disliked": FieldValue.arrayUnion([email])
                    ]
                }
                updateData["users_liked"] = FieldValue.arrayRemove([email])
            }

            ref.updateData(updateData) { error in
                if let error = error {
                    completion(false, error)
                } else {
                    completion(true, nil)
                }
            }
        }
    
    




}
