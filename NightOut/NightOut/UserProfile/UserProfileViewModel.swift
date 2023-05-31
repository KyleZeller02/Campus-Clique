import SwiftUI
import Firebase

class UserProfileViewModel: ObservableObject {
    @Published var usersPosts: [ClassPost] = []
    let db = Firestore.firestore()
    
    private var userManager: UserManager
    
    func getPostsForUser(for user: String) {
        guard let college = UserManager.shared.currentUser?.College else { return }
        let path = db.collection("posts")
        
        let query = path
            .whereField("college", isEqualTo: college)
            .whereField("email", isEqualTo: user)
            .order(by: "votes")
        
        query.getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents in getPostsForUser(): \(error?.localizedDescription ?? "")")
                return
            }
            
            var posts: [ClassPost] = []
            
            for document in documents {
               
                let data = document.data()
                let author = data["author"] as? String ?? ""
                        let postBody = data["post_body"] as? String ?? ""
                        let forClass = data["for_class"] as? String ?? ""
                        let date = data["time_stamp"] as? Double ?? 0.0
                        let votes = data["votes"] as? Int64 ?? 0
                        let id = data["id"] as? String ?? ""
                        let usersLiked = data["users_liked"] as? [String] ?? []
                        let usersDisliked = data["users_disliked"] as? [String] ?? []
                        let email = data["email"] as? String ?? ""
                        let college = data["college"] as? String ?? ""
                let post = ClassPost(postBody: postBody, postAuthor: author, forClass: forClass, datePosted: date, votes: votes, id: id, usersLiked: Set(usersLiked), usersDisliked: Set(usersDisliked), email: email, college: college)
                posts.append(post)
            }
            
            DispatchQueue.main.async {
                
                
                self.usersPosts = posts
                self.objectWillChange.send()
            }
        }
    }


    func deletePostAndReplies(_ post: ClassPost) {
        guard let college = UserManager.shared.currentUser?.College else { return }
        let selectedClass = post.forClass

        // Get the references to the post and its replies
        let postRef = db.collection("Colleges").document(college).collection(selectedClass).document(post.id)
        let repliesRef = postRef.collection("Replies")

        // Create a batch to delete the post and all of its replies
        let batch = db.batch()

        // Delete all replies of the post
        repliesRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting replies: \(error)")
            } else {
                if !querySnapshot!.isEmpty {
                    for document in querySnapshot!.documents {
                        batch.deleteDocument(document.reference)
                    }
                }

                // Delete the post itself
                batch.deleteDocument(postRef)

                // Commit the batch
                batch.commit { (batchError) in
                    if let batchError = batchError {
                        print("Error executing batch: \(batchError)")
                    } else {
                        if let index = self.usersPosts.firstIndex(where: { $0.id == post.id }) {
                            self.usersPosts.remove(at: index)
                        }
                        if let userPostIndex = self.usersPosts.firstIndex(where: { $0.id == post.id }) {
                            self.usersPosts.remove(at: userPostIndex)
                        }
                       
                    }
                }
            }
        }
    }
    
    
    init(userManager: UserManager = UserManager.shared) {
        self.userManager = userManager

        userManager.initializeUser { [weak self] currentUser in
            guard let curUser = currentUser?.Email else { return }
            
            self?.getPostsForUser(for: curUser)
        }
    }
    
    private func parseMajor(major: String) -> [String] {
        return major.components(separatedBy: ",")
    }
}
