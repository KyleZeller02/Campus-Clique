//
//  FirebaseManagerProtocol.swift
//  Campus Clique
//
//  Created by Kyle Zeller on 7/8/23.
//

import Foundation
import Firebase

protocol FirebaseManagerProtocol {
    func fetchPosts(fromClass selectedClass: String, fromCollege college: String, completion: @escaping ([ClassPost]?, Error?) -> Void)
    
    func fetchPost(byId id: String, completion: @escaping (ClassPost?, Error?) -> Void)
    
    func fetchNext30PostsForClass(fromClass selectedClass: String, fromCollege college: String, after lastSnapshot: DocumentSnapshot?, completion: @escaping ([ClassPost]?, DocumentSnapshot?, Error?) -> Void)
    
    func createClassPost(from data: [String: Any]) -> ClassPost?
    
    func addNewPost(author: String, postBody: String, forClass: String, college: String, email: String, profilePictureURL:String, completion: @escaping (ClassPost?, Error?) -> Void)
    
    func fetchFirst30PostsForClass(fromClass className: String, fromCollege college: String, completion: @escaping ([ClassPost]?, DocumentSnapshot?, Error?) -> Void)
    
    func addReply(_ replyBody: String, to post: ClassPost, author: String, email: String, profilePictureURL:String, completion: @escaping (Result<Reply, Error>) -> Void)
    
    func deletePostAndReplies(_ post: ClassPost, completion: @escaping (Bool) -> Void)
    
    func commitBatch(_ batch: WriteBatch, completion: @escaping (Bool) -> Void)
    
    func deleteReply(_ reply: Reply, fromPost post: ClassPost, completion: @escaping (Result<Void, Error>) -> Void)
    
    func performAction(vote: VoteType, post: ClassPost, user: User, completion: @escaping (Bool, Error?) -> Void)
    
    func updateForUpVote(post: ClassPost, email: String) -> (votes: Int64, liked: Any, disliked: Any)
    
    func updateForDownVote(post: ClassPost, email: String) -> (votes: Int64, liked: Any, disliked: Any)
    
    func handleVoteOnReplyFirestore(UpOrDown vote: VoteType, post: ClassPost, reply: Reply, completion: @escaping (Error?) -> Void)
    
    func fetchReply(forPost post: ClassPost, replyId: String, completion: @escaping (Reply?, Error?) -> Void)
    
    func deleteUsersPostAndRepliesFromClass(fromClasses c: [String], email:String, college:String, completion: @escaping (Bool, Error?) -> Void)
    
    func getReplies(forPost post: ClassPost, completion: @escaping ([Reply]) -> Void)
    
    func createReplyFromData(_ data: [String: Any]) -> Reply?
    
    func getPostsForUser( college: String, user:String, completion: @escaping ([ClassPost]?, Error?) -> Void)
    
    func deletePostsAndRepliesOfUserFromCollege(fromCollege: String, userEmail: String, completion: @escaping (Bool, Error?) -> Void)
    
    func getDocument(completion: @escaping (UserDocument?, Error?) -> Void)
}
