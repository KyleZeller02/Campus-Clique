//
//  ClassPostsViewModel.swift
//  NightOut
//
//  Created by Kyle Zeller on 1/13/23.
//

import Foundation
import FirebaseFirestore
import Firebase



class ClassPostsViewModel: ObservableObject{
    
    /// the array of posts that is retrieved from firebase for the specific class at a specific university
    @Published var postsArray: [ClassPost] = []
    @Published var curReplies: [Replies] = []
    //userVM needs to be published incase the user edits their profile while viewing posts.
    //@Published var userVM: UserProfileViewModel = UserProfileViewModel()
    @Published var profileVM: UserProfileViewModel = UserProfileViewModel()
    
    
    @Published var selectedClass: String = "Selected Class"
    
   
    let db = Firestore.firestore()
    
    
    
    /// on initialization of this object, we get the posts from firebase
    /// this will also need to be called when we refresh the page
    init() {
        let curUser = profileVM.CurUser()
        profileVM.getDocument(user: curUser) { [weak self] doc in
            guard let self = self else { return } // Add weak self capture list to avoid retain cycle
            self.profileVM.userDocument = doc
            self.selectedClass = doc.Classes?.first ?? "Selected Class" // Use .first instead of [0] to safely access first element
            self.getPosts(selectedClass: self.selectedClass) { res in
                self.postsArray = res
            }
        }

        profileVM.userDocument.Classes?.sort() // Sort classes in place

        
        //sortPosts()
    }
    
    func deletePost(){
        
    }
    
    func getDocument(email: String?, completion: @escaping ((UserDocument) -> ())) {
        let doc = db.collection("Users").document(email ?? "")
        doc.getDocument { [weak self] document, error in
            guard self != nil else { return } // Add weak self capture list to avoid retain cycle
            if let document = document, document.exists {
                let data = document.data()
                let firstName = data?["FirstName"] as? String ?? ""
                let lastName = data?["LastName"] as? String ?? ""
                let college = data?["College"] as? String ?? ""
                let birthday = data?["Birthday"] as? String ?? ""
                let major = data?["Major"] as? [String] ?? []
                let classes = data?["Classes"] as? [String] ?? []
                let email = data?["Email"] as? String ?? ""
                let retrievedDoc = UserDocument(FirstName: firstName, LastName: lastName, College: college, Birthday: birthday, Major: major, Classes: classes, Email: email)
                completion(retrievedDoc)
            } else {
                print("Document does not exist")
                // Call completion block with empty UserDocument when document does not exist
                let retrievedDoc = UserDocument(FirstName: "", LastName: "", College: "", Birthday: "", Major: [], Classes: [], Email: "")
                completion(retrievedDoc)
            }
        }
    }

    
    func getPosts(selectedClass: String, completion: @escaping ([ClassPost]) -> ()) {
        if selectedClass == "Selected Class" {
            return
        }
        
        let curuser = profileVM.CurUser()
        self.profileVM.getDocument(user: curuser) { newDoc in
            self.profileVM.userDocument = newDoc
        }
        
        // Clear the array before adding new elements
        self.postsArray.removeAll()
        
        // Make a temp array that is set in view closure
        var tempPosts: [ClassPost] = []
        
        // Use a DispatchGroup to ensure retrieval of posts happens on the same thread
        let g = DispatchGroup()
        
        let college: String = profileVM.userDocument.College
        
        // This could break if the selected class or college does not exist in the database
        let postLocation = db.collection("Colleges").document("\(college)").collection("\(selectedClass)")
        
        // Gather documents
        g.enter()
        postLocation.order(by: "datePosted", descending: true).getDocuments() { [weak self] (querySnapshot, err) in
            guard self != nil else { return }
            if let err = err {
                print("Something went wrong getting posts from Firebase: \(err.localizedDescription)")
                g.leave()
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let author = data["author"] as? String ?? ""
                    let postBody = data["postBody"] as? String ?? ""
                    let forClass = data["forClass"] as? String ?? ""
                    let date = data["datePosted"] as? Double ?? 0.0
                    let votes = data["votes"] as? Int64 ?? 0
                    let id = data["id"] as? String ?? ""
                    let usersLiked = data["UsersLiked"] as? [String]  ?? []
                    let usersDisliked = data["UsersDisliked"] as? [String]  ?? []
                    let email = data["email"] as? String ?? ""
                    
                    let post = ClassPost(postBody: postBody, postAuthor: author, forClass: forClass, DatePosted: date, votes:votes, id: id,usersLiked: Set(usersLiked), usersDisliked: Set(usersDisliked),email: email)
                    
                    tempPosts.append(post)
                }
                g.leave()
            }
        }
        
        g.notify(queue: .main) {
            completion(tempPosts)
        }
    }

    
    
    func sortPosts(){
        
        self.postsArray.sort(by: {$0.DatePosted > $1.DatePosted})
    }
    
    func addPost(postBody: String) {
        if selectedClass == "Selected Class" { return }

        // Get reference to Firebase
        let college = self.profileVM.userDocument.College
        let postLocation = db.collection("Colleges").document("\(college)").collection(selectedClass)

        // Create a new document without setting any fields, so we can access the document ID and set the ID property
        let newPostReference = postLocation.document()
        let newPostID = newPostReference.documentID

        // Create a dictionary of properties to set
        let postProperties: [String: Any] = [
            "author": self.profileVM.userDocument.FullName,
            "datePosted": Date().timeIntervalSince1970,
            "forClass": selectedClass,
            "postBody": postBody,
            "votes": 0,
            "id": newPostID,
            "email": self.profileVM.userDocument.Email
        ]

        // Set the data in the document
        newPostReference.setData(postProperties) { error in
            if let error = error {
                print("Error adding post to Firebase: \(error.localizedDescription)")
                return
            }

            // Create the new post object to update the view without reloading all the documents
            let newPost = ClassPost(postBody: postBody, postAuthor: self.profileVM.userDocument.FullName, forClass: self.selectedClass, votes: 0, id: newPostID, email: self.profileVM.userDocument.Email)

            // Append the new post to the posts array
            self.postsArray.append(newPost)

            // Sort the posts array
            self.sortPosts()
        }
    }

    
    
    func handleVoteOnPost(UpOrDown vote: String, onPost post: ClassPost){
        guard let user = Auth.auth().currentUser, let email = user.email else {
            return // Return if user is not logged in
        }
        
        let ref = db.collection("Colleges").document(profileVM.userDocument.College).collection(selectedClass).document(post.id)
        switch vote {
            //ther user is trying to upvote
        case "up":
            //if the user has already upvoted
            if post.UsersLiked.contains(email){
                
                //remove the set element(local)
                post.UsersLiked.remove(email)
                //remove the vote local vote count(local)
                castDownVote(for: post)
                //decrement vote in firebase by 1(firebase) and remove name from upvoted list(firebase)
                ref.updateData([
                    "votes" : FieldValue.increment(Int64(-1)),
                    "UsersLiked" : FieldValue.arrayRemove([email])
                ])
            }
            //if the user has already downvoted:
            else if post.UserDownVotes.contains(email){
                //upvote local count twice
                castUpVote(for: post)
                castUpVote(for: post)
                //remove their name from the disliked set(local)
                post.UserDownVotes.remove(email)
                //add their name to the upvote set(local)
                post.UsersLiked.insert(email)
                //add their name to upvote set(firebase)
                
                
                
                ref.updateData([
                    //increase vote value by 2 in firebase
                    "votes" : FieldValue.increment(Int64(2)),
                    // add name to UsersLiked in firebase
                    "UsersLiked" : FieldValue.arrayUnion([email]),
                    //remove name from usersDisliked in firebase
                    "UsersDisliked" : FieldValue.arrayRemove([email])
                ])
                
            }
            // else, the user has not voted at all
            else{
                //add their name to the upvote set(local)
                post.UsersLiked.insert(email)
                //add a vote to the count(local)
                castUpVote(for: post)
                ref.updateData([
                    //add a vote to post object(firebase)
                    "votes" : FieldValue.increment(Int64(1)),
                    //add their name to upvote set(fireabse)
                    "UsersLiked" : FieldValue.arrayUnion([email])
                ])
            }
            //the user has not downvoted, might as well set that, other wise it breaks
            ref.updateData([
                
                "UsersDisliked" : FieldValue.arrayRemove([email])
            ])
            post.UserDownVotes.remove(email)
            break
        case "down" :
            //if user has already downvoted:
            if post.UserDownVotes.contains(email){
                //increase vote count by 1(local)
                castUpVote(for: post)
                
                //remove name from downvote list(local)
                post.UserDownVotes.remove(email)
                ref.updateData([
                    //increment votecount by 1(firebase)
                    "votes" : FieldValue.increment(Int64(1)),
                    //remove name from downvote list (firebase)
                    "UsersDisliked" : FieldValue.arrayRemove([email])
                ])
                
                
                
            }
            
            //if user has already upvoted:
            else if post.UsersLiked.contains(email){
                // decrease vote count by 2(local)
                castDownVote(for: post)
                castDownVote(for: post)
                //remove name from userliked set(local)
                post.UsersLiked.remove(email)
                //add name to users downVoted (local)
                post.UserDownVotes.insert(email)
                
                ref.updateData([
                    //decrease vote count by 2 (firebase)
                    "votes" : FieldValue.increment(Int64(-2)),
                    //remove name from userliked set(firebase)
                    "UsersLiked" : FieldValue.arrayRemove([email]),
                    //add name to users downVoted (local)
                    "UsersDisliked" : FieldValue.arrayUnion([email])
                ])
            }
            //if user has not cast any vote yet
            else {
                //decrement vote count by 1(local)
                castDownVote(for: post)
                
                //add name to downvote set (local)
                post.UserDownVotes.insert(email)
                
                
                ref.updateData([
                    //decrement vote count by 1 (firebase)
                    "votes" : FieldValue.increment(Int64(-1)),
                    //add name to usersDisliked (fireabase)
                    "UsersDisliked" : FieldValue.arrayUnion([email])
                ])
            }
            //at the end of upvoting something, the user has not liked anything, remove thier name
            ref.updateData([
                "UsersLiked" : FieldValue.arrayRemove([email])
            ])
            post.UsersLiked.remove(email)
            break
        default:
            break
        }
    }
    
    func handleVoteOnReply(UpOrDown vote: String, onPost post: ClassPost ,onReply reply: Replies){
        guard let user = Auth.auth().currentUser, let email = user.email else {
            return // Return if user is not logged in
        }
        
        let ref = db.collection("Colleges").document(profileVM.userDocument.College).collection(selectedClass).document(post.id).collection("Replies").document(reply.id)
        
        // Update vote count and user vote status based on the vote type
        switch vote {
        case "up":
            if reply.UsersLiked.contains(email) { // If already upvoted, remove upvote
                reply.UsersLiked.remove(email)
                castDownVoteReply(for: reply)
                ref.updateData([
                    "votes": FieldValue.increment(Int64(-1)),
                    "UsersLiked": FieldValue.arrayRemove([email])
                ])
            } else if reply.UserDownVotes.contains(email) { // If already downvoted, change to upvote
                castUpVoteReply(for: reply)
                castUpVoteReply(for: reply)
                reply.UserDownVotes.remove(email)
                reply.UsersLiked.insert(email)
                ref.updateData([
                    "votes": FieldValue.increment(Int64(2)),
                    "UsersLiked": FieldValue.arrayUnion([email]),
                    "UsersDisliked": FieldValue.arrayRemove([email])
                ])
            } else { // If not voted, add upvote
                reply.UsersLiked.insert(email)
                castUpVoteReply(for: reply)
                ref.updateData([
                    "votes": FieldValue.increment(Int64(1)),
                    "UsersLiked": FieldValue.arrayUnion([email])
                ])
            }
            // Remove from downvote list
            ref.updateData([
                "UsersDisliked": FieldValue.arrayRemove([email])
            ])
            reply.UserDownVotes.remove(email)
        case "down":
            if reply.UserDownVotes.contains(email) { // If already downvoted, remove downvote
                castUpVoteReply(for: reply)
                reply.UserDownVotes.remove(email)
                ref.updateData([
                    "votes": FieldValue.increment(Int64(1)),
                    "UsersDisliked": FieldValue.arrayRemove([email])
                ])
            } else if reply.UsersLiked.contains(email) { // If already upvoted, change to downvote
                castDownVoteReply(for: reply)
                castDownVoteReply(for: reply)
                reply.UsersLiked.remove(email)
                reply.UserDownVotes.insert(email)
                ref.updateData([
                    "votes": FieldValue.increment(Int64(-2)),
                    "UsersLiked": FieldValue.arrayRemove([email]),
                    "UsersDisliked": FieldValue.arrayUnion([email])
                ])
            } else { // If not voted, add downvote
                castDownVoteReply(for: reply)
                reply.UserDownVotes.insert(email)
                ref.updateData([
                    "votes": FieldValue.increment(Int64(-1)),
                    "UsersDisliked": FieldValue.arrayUnion([email])
                ])
            }
            // Remove from upvote list
            ref.updateData([
                "UsersLiked": FieldValue.arrayRemove([email])
            ])
            reply.UsersLiked.remove(email)
        default:
            break
        }
    }

    
    func addReply(forPost post: ClassPost, replyBody body: String) {
        let date = Date().timeIntervalSince1970
        let replyDocument = db.collection("Colleges").document("\(self.profileVM.userDocument.College)").collection(self.selectedClass).document(post.id).collection("Replies").document()

        let batch = db.batch()
        batch.setData([
            "author": self.profileVM.userDocument.FullName,
            "forClass" : post.forClass,
            "postBody" : body,
            "votes" : 0,
            "id" : replyDocument.documentID,
            "date" : date
        ], forDocument: replyDocument)

        // Update the post document to add the reply ID using arrayUnion
        batch.updateData([
            "replies": FieldValue.arrayUnion([replyDocument.documentID])
        ], forDocument: db.collection("Colleges").document("\(self.profileVM.userDocument.College)").collection(self.selectedClass).document(post.id))

        batch.commit { (error) in
            if let error = error {
                // Handle error
                print(error.localizedDescription)
            } else {
                // Make other local changes
                let reply: Replies = Replies(replyBody: body, replyAuthor: self.profileVM.userDocument.FullName, forClass: self.selectedClass, votes: 0,id: replyDocument.documentID)
                post.replies.append(reply)
                self.objectWillChange.send()
            }
        }
    }


    
    
    func getReplies(forPost post: ClassPost, completion: @escaping ([Replies]) -> ()) {
        post.replies.removeAll()

        let college: String = profileVM.userDocument.College
        let postLocation = db.collection("Colleges").document(college).collection(selectedClass).document(post.id).collection("Replies")

        postLocation.order(by: "date", descending: false).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("something went wrong getting replies on post from Firebase: \(err.localizedDescription)")
                completion([])
            } else {
                var tempReplies: [Replies] = []

                for document in querySnapshot!.documents {
                    let data = document.data()
                    let author = data["author"] as? String ?? ""
                    let forClass = data["forClass"] as? String ?? ""
                    let id = data["id"] as? String ?? ""
                    let postBody = data["postBody"] as? String ?? ""
                    let votes = data["votes"] as? Int64 ?? 0
                    let usersLiked = data["UsersLiked"] as? [String]  ?? []
                    let usersDisliked = data["UsersDisliked"] as? [String]  ?? []
                    let date = data["datePosted"] as? Double ?? 0.0
                    let reply = Replies(replyBody: postBody, replyAuthor: author, forClass: forClass, DatePosted: date, votes: votes, id: id, usersLiked: Set(usersLiked), usersDisliked: Set(usersDisliked))
                    tempReplies.append(reply)
                }

                completion(tempReplies)
            }
        }
    }


    
//    func sortReplies(){
//        self.curReplies.sort(by: {$0.votes > $1.votes})
//    }
    
    
    
    /// will increase vote count by 1 for a specific post
    /// - Parameter post: the post we are adding 1 to vote property
    func castUpVote(for post:ClassPost){
        objectWillChange.send()
        post.votes += 1
    }
    /// will decrease vote count by 1 for a specific post
    /// - Parameter post: the post we are subtracting 1 from the  vote property
    func castDownVote(for post:ClassPost){
        objectWillChange.send()
        post.votes -= 1
    }
    // same methods as above, for replies
    /// will increase vote count by 1 for a specific post
    /// - Parameter post: the post we are adding 1 to vote property
    func castUpVoteReply(for reply:Replies){
        objectWillChange.send()
        reply.votes += 1
        
    }
    
    /// will decrease vote count by 1 for a specific post
    /// - Parameter post: the post we are subtracting 1 from the  vote property
    func castDownVoteReply(for reply:Replies){
        objectWillChange.send()
        reply.votes -= 1
    }
    
    
        
}




