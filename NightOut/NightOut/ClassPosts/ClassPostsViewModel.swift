//
//  ClassPostsViewModel.swift
//  NightOut
//
//  Created by Kyle Zeller on 1/13/23.
//

import Foundation
import FirebaseFirestore



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
        
        profileVM.getDocument { doc in
            self.profileVM.userDocument = doc
        }
//        getPosts(selectedClass: profileVM.userDocument.Classes?[0] ?? "Selected Class" ) { res in
//            
//            self.postsArray = res
//        }
        
        profileVM.userDocument.Classes?.sort()
        
        sortPosts()
    }
    
    func deletePost(){
        
    }
    
    func getDocument(email:String?,completion:@escaping((UserDocument) -> ())) async{
        
       
         
        let g = DispatchGroup()
        var tempDoc: UserDocument = UserDocument(FirstName: "", LastName: "", College: "", Birthday: "", Major: [], Classes: [], Email: "")
        
        let doc = db.collection("Users").document(email ?? "")
        g.enter()
        doc.getDocument { (document, error) in
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
                tempDoc = retrievedDoc
                g.leave()
            } else {
                print("Document does not exist")
                g.leave()
            }
        }
       
       
        
        g.notify(queue:.main) {
            completion(tempDoc)
        }
        
        
        /*
        userDocument = UserDocument( FirstName: "Kyle", LastName: "Zeller", College: "Kansas State University", Birthday: "02/01/2002", Major: ["Computer Science"], Classes: ["CIS450", "CIS501", "CIS575","CIS415"], Email: "zellerkyl@gmail.com", ProfilePicture: Image(systemName: "person.circle"))
         */
    }
    
    func getPosts(selectedClass:String,completion:@escaping(([ClassPost]) -> ())){
        if selectedClass == "Selected Class"{
            return
        }
        self.profileVM.getDocument(){newDoc in
           self.profileVM.userDocument = newDoc
            
       }
        //clear the array before adding new elements
        self.postsArray.removeAll()
        //make temp array that is set in view closure
        var tempPosts:[ClassPost] = []
        //dispatch group to make retrieving posts occur on the same thread
        let g = DispatchGroup()
        
        
       
        let college: String = profileVM.userDocument.College
        //this could break if the selected class or college does not exist in the database
        let postLocation = db.collection("Colleges").document("\(college)").collection("\(selectedClass)")
        
        //gather documenets
        g.enter()
        postLocation.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("somethng went wrong getting posts from firebase: \(err.localizedDescription)")
                g.leave()
            }
            else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let author = data["author"] as? String ?? ""
                    let postBody = data["postBody"] as? String ?? ""
                    let forClass = data["forClass"] as? String ?? ""
                    let date = data["datePosted"] as? String ?? ""
                    let votes = data["votes"] as? Int64 ?? 0
                    let id = data["id"] as? String ?? ""
                    let usersLiked = data["UsersLiked"] as? [String]  ?? []
                    let usersDisliked = data["UsersDisliked"] as? [String]  ?? []
                    
                    let post = ClassPost(postBody: postBody, postAuthor: author, forClass: forClass, DatePosted: date, votes:votes, id: id,usersLiked: Set(usersLiked), usersDisliked: Set(usersDisliked))
                    print("Post in getPosts: \(Mirror(reflecting: post))")
                    
                    tempPosts.append(post)
                }
                g.leave()
            }
        }
        g.notify(queue:.main) {
            completion(tempPosts)
        }
        
    }
    
    
    
    func sortPosts(){
        
        self.postsArray.sort(by: {$0.DatePosted > $1.DatePosted})
    }
    
    func addPost(postBody:String){
        if selectedClass == "Selected Class"{return}
        //handle date formatting , get datetime right now
        let df: DateFormatter = DateFormatter()
        df.dateFormat = "YYYY-MM-DD,HH:mm:ss"
        let date = Date()
        let ds = df.string(from: date)
        
        //get refernce to firebase
        
        
        //create the new documnet, but do not set any fields. this way we can access the document id, and set the id property
        let newPostReference = db.collection("Colleges").document("\(self.profileVM.userDocument.College)").collection(self.selectedClass).document()
        
        newPostReference.setData([
            //set properties
            "author": self.profileVM.userDocument.FullName,
            "datePosted" :ds,
            "forClass" : self.selectedClass,
            "postBody" : postBody,
            "votes" : 0,
            "id" : newPostReference.documentID,
            
        ])
        
        //create the new post so we can update the View without reloading all the documents
        let newPost = ClassPost(postBody: postBody, postAuthor: self.profileVM.userDocument.FullName, forClass: self.selectedClass, votes: 0, id: newPostReference.documentID)
        self.postsArray.append(newPost)
        
        self.sortPosts()
    }
    
    
    func handleVoteOnPost(UpOrDown vote: String, onPost post: ClassPost){
        let email = profileVM.userDocument.Email
        
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
        let email = profileVM.userDocument.Email
        
        let ref = db.collection("Colleges").document(profileVM.userDocument.College).collection(selectedClass).document(post.id).collection("Replies").document(reply.id)
        switch vote {
            //ther user is trying to upvote
        case "up":
            //if the user has already upvoted
            if reply.UsersLiked.contains(email){
                
                //remove the set element(local)
                reply.UsersLiked.remove(email)
                //remove the vote local vote count(local)
                castDownVoteReply(for: reply)
                //decrement vote in firebase by 1(firebase) and remove name from upvoted list(firebase)
                ref.updateData([
                    "votes" : FieldValue.increment(Int64(-1)),
                    "UsersLiked" : FieldValue.arrayRemove([email])
                ])
            }
            //if the user has already downvoted:
            else if reply.UserDownVotes.contains(email){
                //upvote local count twice
                castUpVoteReply(for: reply)
                castUpVoteReply(for: reply)
                //remove their name from the disliked set(local)
                reply.UserDownVotes.remove(email)
                //add their name to the upvote set(local)
                reply.UsersLiked.insert(email)
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
                reply.UsersLiked.insert(email)
                //add a vote to the count(local)
                castUpVoteReply(for: reply)
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
            reply.UserDownVotes.remove(email)
            break
        case "down" :
            //if user has already downvoted:
            if reply.UserDownVotes.contains(email){
                //increase vote count by 1(local)
                castUpVoteReply(for: reply)
                
                //remove name from downvote list(local)
                reply.UserDownVotes.remove(email)
                ref.updateData([
                    //increment votecount by 1(firebase)
                    "votes" : FieldValue.increment(Int64(1)),
                    //remove name from downvote list (firebase)
                    "UsersDisliked" : FieldValue.arrayRemove([email])
                ])
                
                
                
            }
            
            //if user has already upvoted:
            else if reply.UsersLiked.contains(email){
                // decrease vote count by 2(local)
                castDownVoteReply(for: reply)
                castDownVoteReply(for: reply)
                //remove name from userliked set(local)
                reply.UsersLiked.remove(email)
                //add name to users downVoted (local)
                reply.UserDownVotes.insert(email)
                
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
                castDownVoteReply(for: reply)
                
                //add name to downvote set (local)
                reply.UserDownVotes.insert(email)
                
                
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
            reply.UsersLiked.remove(email)
            break
        default:
            break
        }
    }
    
    func addReply(forPost post: ClassPost, replyBody body: String){
        let df: DateFormatter = DateFormatter()
        df.dateFormat = "YYYY-MM-DD,HH:mm:ss"
        let date = Date()
        let ds = df.string(from: date)
        //create the document that represents the reply in firebase
        let replyDocument = db.collection("Colleges").document("\(self.profileVM.userDocument.College)").collection(self.selectedClass).document(post.id).collection("Replies").document()
            
        //set the document data in firebase (firebase)
        replyDocument.setData([
            "author": self.profileVM.userDocument.FullName,
            "forClass" : post.forClass,
            "postBody" : body,
            "votes" : 0,
            "id" : replyDocument.documentID,
            "date" : ds
        ])
        
        //make the reply object
        let reply: Replies = Replies(replyBody: body, replyAuthor: profileVM.userDocument.FullName, forClass: selectedClass, votes: 0,id: replyDocument.documentID)
        
        //add the reply to the post it was on(local)
        post.replies.append(reply)
        
        //this call will change the property of the view model and update the view
        objectWillChange.send()
    }
    
    
    func getReplies(forPost post: ClassPost,completion:@escaping(([Replies]) -> ())){
        post.replies.removeAll()
        
        //make temp array that is set in view closure
        var tempReplies:[Replies] = []
        //dispatch group to make retrieving posts occur on the same thread
        let g = DispatchGroup()
        
        
        let college: String = profileVM.userDocument.College
        //this could break if the selected class or college does not exist in the database
        let postLocation = db.collection("Colleges").document("\(college)").collection("\(selectedClass)").document(post.id).collection("Replies")
        
        g.enter()
        postLocation.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("somethng went wrong getting replies on post from firebase: \(err.localizedDescription)")
                g.leave()
            }
            else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let author = data["author"] as? String ?? ""
                    let forClass = data["forClass"] as? String ?? ""
                    let id = data["id"] as? String ?? ""
                    let postBody = data["postBody"] as? String ?? ""
                    let votes = data["votes"] as? Int64 ?? 0
                    let usersLiked = data["UsersLiked"] as? [String]  ?? []
                    let usersDisliked = data["UsersDisliked"] as? [String]  ?? []
                    let date = data["datePosted"] as? String ?? ""
                    let reply = Replies(replyBody: postBody, replyAuthor: author, forClass: forClass, DatePosted: date, votes: votes, id: id, usersLiked: Set(usersLiked), usersDisliked: Set(usersDisliked))
                    
                    tempReplies.append(reply)
                   
                }
                g.leave()
            }
        }
        g.notify(queue:.main) {
            completion(tempReplies)
        }
    }
    
    func sortReplies(){
        self.curReplies.sort(by: {$0.votes > $1.votes})
    }
    
    
    
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




