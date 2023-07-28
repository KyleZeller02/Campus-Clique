//
//  FirebaseManagerProtocol.swift
//  Campus Clique
//
//  Created by Kyle Zeller on 7/8/23.
//

import Foundation
import Firebase

protocol FirebaseManagerProtocol {
    
    /// Fetches a specific `ClassPost` instance by ID from Firebase Firestore.
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the `ClassPost` to fetch.
    ///   - completion: Asynchronous callback with the fetched `ClassPost` instance or an error if the fetch operation fails.
    ///                 - `ClassPost?`: The fetched `ClassPost` instance if the fetch operation is successful; `nil` otherwise.
    ///                 - `Error?`: An error object explaining the reason for the fetch operation failure; `nil` if the operation is successful.
    func fetchPost(byId id: String, completion: @escaping (ClassPost?, Error?) -> Void)
    
    
    /// Fetches the next 30 `ClassPost` instances for a specific class from Firebase Firestore, starting from the last fetched post.
    ///
    /// - Parameters:
    ///   - selectedClass: The name of the class for which to fetch posts.
    ///   - college: The name of the college for which to fetch posts.
    ///   - lastSnapshot: The last document snapshot from the previous fetch operation. This is used as the starting point for the fetch operation.
    ///   - completion: Asynchronous callback with the fetched `ClassPost` instances, the last document snapshot, or an error if the fetch operation fails.
    ///                 - `[ClassPost]?`: An array of the fetched `ClassPost` instances if the fetch operation is successful; `nil` otherwise.
    ///                 - `DocumentSnapshot?`: The last document snapshot fetched. This can be used as the starting point for the next fetch operation.
    ///                 - `Error?`: An error object explaining the reason for the fetch operation failure; `nil` if the operation is successful.
    func fetchNext30PostsForClass(fromClass selectedClass: String, fromCollege college: String, after lastSnapshot: DocumentSnapshot?, completion: @escaping ([ClassPost]?, DocumentSnapshot?, Error?) -> Void)
    
    
    /// Creates a new `ClassPost` instance from the provided data dictionary.
    ///
    /// - Parameters:
    ///   - data: A dictionary containing key-value pairs corresponding to the properties of `ClassPost`. The keys should be string representations of the property names.
    /// - Returns: The created `ClassPost` instance if the creation operation is successful; `nil` otherwise.
    func createClassPost(from data: [String: Any]) -> ClassPost?
    
    
    /// Fetches the first 30 `ClassPost` instances for a specific class from Firebase Firestore.
    ///
    /// - Parameters:
    ///   - className: The name of the class for which to fetch posts.
    ///   - college: The name of the college for which to fetch posts.
    ///   - completion: Asynchronous callback with the fetched `ClassPost` instances, the last document snapshot, or an error if the fetch operation fails.
    ///                 - `[ClassPost]?`: An array of the fetched `ClassPost` instances if the fetch operation is successful; `nil` otherwise.
    ///                 - `DocumentSnapshot?`: The last document snapshot fetched. This can be used as the starting point for the next fetch operation.
    ///                 - `Error?`: An error object explaining the reason for the fetch operation failure; `nil` if the operation is successful.
    func fetchFirst30PostsForClass(fromClass className: String, fromCollege college: String, completion: @escaping ([ClassPost]?, DocumentSnapshot?, Error?) -> Void)
    
    
    /// Deletes a specific `ClassPost` instance and all its associated replies from Firebase Firestore.
    ///
    /// - Parameters:
    ///   - post: The `ClassPost` instance to delete.
    ///   - completion: Asynchronous callback with the status of the delete operation.
    ///                 - `Bool`: `true` if the delete operation is successful; `false` otherwise.
    func deletePostAndItsReplies(_ post: ClassPost, completion: @escaping (Bool) -> Void)
    
    
    /// Commits a batch write operation to Firebase Firestore.
    ///
    /// - Parameters:
    ///   - batch: The `WriteBatch` instance containing the set of write operations to apply.
    ///   - completion: Asynchronous callback with the status of the commit operation.
    ///                 - `Bool`: `true` if the commit operation is successful; `false` otherwise.
    func commitBatch(_ batch: WriteBatch, completion: @escaping (Bool) -> Void)

    
    /// Deletes a specific `Reply` from a `ClassPost`.
    ///
    /// - Parameters:
    ///   - reply: The `Reply` instance to delete.
    ///   - post: The `ClassPost` instance from which to delete the reply.
    ///   - completion: Asynchronous callback with the result of the delete operation.
    ///                 - `Result<Void, Error>`: A result object that can be either:
    ///                     - `.success(())` if the delete operation is successful.
    ///                     - `.failure(Error)` if the operation fails, containing an error explaining the reason for the failure.
    func deleteReply(_ reply: Reply, fromPost post: ClassPost, completion: @escaping (Result<Void, Error>) -> Void)
    
    
    /// Performs a vote action (upvote or downvote) on a `ClassPost` for a specific `User`.
    ///
    /// - Parameters:
    ///   - vote: The type of vote (`VoteType`) to perform.
    ///   - post: The `ClassPost` on which to perform the vote.
    ///   - user: The `User` performing the vote.
    ///   - completion: Asynchronous callback with the status of the vote operation and an error if the operation fails.
    ///                 - `Bool`: `true` if the vote operation is successful; `false` otherwise.
    ///                 - `Error?`: An error object explaining the reason for the vote operation failure; `nil` if the operation is successful.
    func performAction(vote: VoteType, post: ClassPost, user: User, completion: @escaping (Bool, Error?) -> Void)
    
    
    /// Updates the `ClassPost` instance for an upvote action.
    ///
    /// - Parameters:
    ///   - post: The `ClassPost` instance to update.
    ///   - phoneNumber: The phone number of the user performing the upvote.
    /// - Returns: A tuple containing the updated vote count, the liked status, and the disliked status.
    ///            - `votes: Int64`: The updated vote count.
    ///            - `liked: Any`: The updated liked status.
    ///            - `disliked: Any`: The updated disliked status.
    func updateForUpVote(post: ClassPost, phoneNumber: String) -> (votes: Int64, liked: Any, disliked: Any)

    
    /// Updates the `ClassPost` instance for a downvote action.
    ///
    /// - Parameters:
    ///   - post: The `ClassPost` instance to update.
    ///   - phoneNumber: The phone number of the user performing the downvote.
    /// - Returns: A tuple containing the updated vote count, the liked status, and the disliked status.
    ///            - `votes: Int64`: The updated vote count.
    ///            - `liked: Any`: The updated liked status.
    ///            - `disliked: Any`: The updated disliked status.
    func updateForDownVote(post: ClassPost, phoneNumber: String) -> (votes: Int64, liked: Any, disliked: Any)
    
    
    /// Handles a vote action (upvote or downvote) on a `Reply` to a `ClassPost` in Firestore.
    ///
    /// - Parameters:
    ///   - vote: The type of vote (`VoteType`) to perform.
    ///   - post: The `ClassPost` to which the `Reply` belongs.
    ///   - reply: The `Reply` on which to perform the vote.
    ///   - completion: Asynchronous callback with an error if the operation fails.
    ///                 - `Error?`: An error object explaining the reason for the vote operation failure; `nil` if the operation is successful.
    func handleVoteOnReplyFirestore(UpOrDown vote: VoteType, post: ClassPost, reply: Reply, completion: @escaping (Error?) -> Void)
    
    
    /// Fetches a specific `Reply` for a given `ClassPost`.
    ///
    /// - Parameters:
    ///   - post: The `ClassPost` for which to fetch the reply.
    ///   - replyId: The identifier of the reply to fetch.
    ///   - completion: Asynchronous callback with the fetched reply and an error if the operation fails.
    ///                 - `Reply?`: The fetched `Reply` instance; `nil` if the operation fails.
    ///                 - `Error?`: An error object explaining the reason for the failure; `nil` if the operation is successful.
    func fetchReply(forPost post: ClassPost, replyId: String, completion: @escaping (Reply?, Error?) -> Void)
    
    
    /// Deletes the posts, replies, and replies on each post of a user from a list of classes.
    ///
    /// - Parameters:
    ///   - fromClasses: A list of class identifiers from which to delete the posts, replies, and replies on each post.
    ///   - forPhoneNumber: The phone number of the user whose content should be deleted.
    ///   - college: The identifier of the college from which to delete the content.
    ///   - completion: Asynchronous callback with the status of the delete operation and an error if the operation fails.
    ///                 - `Bool`: `true` if the delete operation is successful; `false` otherwise.
    ///                 - `Error?`: An error object explaining the reason for the delete operation failure; `nil` if the operation is successful.
    func deleteUsersPostAndRepliesAndRepliesOnEachPostFromClass(fromClasses c: [String], forPhoneNumber: String, college: String, completion: @escaping (Bool, Error?) -> Void)

    
    /// Fetches all replies for a given `ClassPost`.
    ///
    /// - Parameters:
    ///   - post: The `ClassPost` for which to fetch the replies.
    ///   - completion: Asynchronous callback with an array of `Reply` instances.
    ///                 - `[Reply]`: An array of `Reply` instances corresponding to the `ClassPost`.
    func getReplies(forPost post: ClassPost, completion: @escaping ([Reply]) -> Void)
    
    
    /// Creates a `Reply` instance from a dictionary of data.
    ///
    /// - Parameters:
    ///   - data: A dictionary containing key-value pairs mapping to `Reply` properties.
    /// - Returns: A `Reply` instance if the data is valid and matches the `Reply` structure; `nil` otherwise.
    func createReplyFromData(_ data: [String: Any]) -> Reply?
    
    
    /// Fetches all posts for a specific user from a specific college.
    ///
    /// - Parameters:
    ///   - user: The identifier of the user for whom to fetch the posts.
    ///   - completion: Asynchronous callback with an array of `ClassPost` instances and an error if the operation fails.
    ///                 - `[ClassPost]?`: An array of `ClassPost` instances if the operation is successful; `nil` otherwise.
    ///                 - `Error?`: An error object explaining the reason for the failure; `nil` if the operation is successful.
    func getPostsForUser( user:String, completion: @escaping ([ClassPost]?, Error?) -> Void)
    
    
    /// Removes posts, replies, and posts of a user's replies from a specific college.
    ///
    /// - Parameters:
    ///   - phoneNumber: The phone number of the user whose content should be removed.
    ///   - college: The identifier of the college from which to remove the content.
    ///   - completion: Asynchronous callback with an error if the operation fails.
    ///                 - `Error?`: An error object explaining the reason for the operation failure; `nil` if the operation is successful.
    func removePostsRepliesAndPostsOfUserRepliesFromCollege(wherePhoneNumber phoneNumber:String, whereCollege college:String, completion: @escaping (Error?) -> Void)
    
    
    /// Fetches the `UserDocument` from Firestore.
    ///
    /// - Parameter completion: Asynchronous callback with the fetched `UserDocument` and an error if the operation fails.
    ///                         - `UserDocument?`: The fetched `UserDocument` instance; `nil` if the operation fails.
    ///                         - `Error?`: An error object explaining the reason for the failure; `nil` if the operation is successful.
    func getDocument(completion: @escaping (UserDocument?, Error?) -> Void)

    
    /// Adds a new post to the Firestore.
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
    func addNewPost(firstName: String, lastName:String, postBody: String, forClass: String, college: String, phoneNumber: String, profilePictureURL:String, completion: @escaping (ClassPost?, Error?) -> Void)
    
    
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
    func addReply(_ replyBody: String, to post: ClassPost, firstName: String,lastName:String, phoneNumber: String, profilePictureURL:String, completion: @escaping (Result<Reply, Error>) -> Void)
    
    
    /// Updates the first name of a user on all their posts and replies in Firestore.
    ///
    /// - Parameters:
    ///   - phoneNumber: The phone number of the user whose name needs to be updated.
    ///   - name: The new first name of the user.
    ///   - completion: Asynchronous callback with an error if the operation fails.
    ///                 - `Error?`: An error object explaining the reason for the operation failure; `nil` if the operation is successful.
    func updateFirstNameOnPostsAndReplies(wherePhoneNumber phoneNumber: String, firstName name: String, completion: @escaping (Error?) -> Void)
    
    
    /// Deletes all posts and replies of a user in Firestore.
    ///
    /// - Parameters:
    ///   - phoneNumber: The phone number of the user whose posts and replies need to be deleted.
    ///   - completion: Asynchronous callback with a boolean indicating whether the operation was successful and an error if the operation fails.
    ///                 - `Bool`: `true` if the operation was successful; `false` otherwise.
    ///                 - `Error?`: An error object explaining the reason for the operation failure; `nil` if the operation is successful.
    func deletePostsAndRepliesOfUser( phoneNumber: String, completion: @escaping (Bool, Error?) -> Void)

    
    /// Updates the last name of a user on all their posts and replies in Firestore.
    ///
    /// - Parameters:
    ///   - phoneNumber: The phone number of the user whose last name needs to be updated.
    ///   - name: The new last name of the user.
    ///   - completion: Asynchronous callback with an error if the operation fails.
    ///                 - `Error?`: An error object explaining the reason for the operation failure; `nil` if the operation is successful.
    func updateLastNameOnPostsAndReplies(wherePhoneNumber phoneNumber: String, lastName name: String, completion: @escaping (Error?) -> Void)

    
    /// Uploads a profile image to Firestore.
    ///
    /// - Parameters:
    ///   - image: The `UIImage` instance representing the profile picture to be uploaded.
    ///   - completion: Asynchronous callback with the URL of the uploaded image and an error if the operation fails.
    ///                 - `Result<String, Error>`: A result object containing either the URL of the uploaded image if the operation is successful, or an `Error` explaining the reason for the failure.
    func uploadProfileImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> ())

    
    /// Updates the profile picture URL of a user in Firestore.
    ///
    /// - Parameters:
    ///   - phoneNumber: The phone number of the user whose profile picture URL needs to be updated.
    ///   - newProfilePicURL: The new profile picture URL.
    ///   - completion: Asynchronous callback with an error if the operation fails.
    ///                 - `Error?`: An error object explaining the reason for the operation failure; `nil` if the operation is successful.
    func updateProfilePictureURL(forPhoneNumber phoneNumber: String, newProfilePicURL: String, completion: @escaping (Error?) -> Void)

    
    /// Deletes the old profile picture of a user from Firestore.
    ///
    /// - Parameters:
    ///   - phoneNumber: The phone number of the user whose old profile picture needs to be deleted.
    ///   - completion: Asynchronous callback with a boolean indicating whether the operation was successful and an error if the operation fails.
    ///                 - `Bool`: `true` if the operation was successful; `false` otherwise.
    ///                 - `Error?`: An error object explaining the reason for the operation failure; `nil` if the operation is successful.
    func deleteOldProfilePictureFromFirestore(forPhoneNumber phoneNumber: String, completion: @escaping (Bool, Error?) -> Void)

    
    /// Updates the profile picture on all posts and replies of a user in Firestore.
    ///
    /// - Parameters:
    ///   - phoneNumber: The phone number of the user whose profile picture needs to be updated.
    ///   - profilePicURL: The new profile picture URL.
    ///   - completion: Asynchronous callback with an error if the operation fails.
    ///                 - `Error?`: An error object explaining the reason for the operation failure; `nil` if the operation is successful.
    func updateProfilePicOnPostsAndReplies(wherePhoneNumber phoneNumber: String, profilePicURL: String, completion: @escaping (Error?) -> Void)

}
