
import SwiftUI
import Firebase

struct ClassPosts: View {
    @StateObject var viewRouter: ViewRouter
    @StateObject var posts: ClassPostsViewModel = ClassPostsViewModel()
    @State private var isLoading:Bool = false
    @State private var isShowingSheet = false
    @State var addedPost: String = ""
    var body: some View {
        
        ZStack{
            //Color.Black
            NavigationView{
                
                ScrollView {
                    
                    LazyVStack(spacing: 10) {
                        if posts.postsArray.isEmpty{
                            Text("There might have been a problem fetching the posts, try reloading the app. Or, your the first to the party. You can get the party started!")
                                .font(.headline)
                                .foregroundColor(.White)
                            
                        }else{
                            ForEach(posts.postsArray) { post in
                                NavigationLink(destination: DetailView(selectedPost: post, viewModel: posts)) {
                                    ClassPostViewPostCell(post: post, viewModel: posts)
                                    
                                }
                            }
                        }
                        
                    }
                    
                    
                    //.background(Color.gray) // Set background color for the LazyVStack
                }
                
                .background(Color.Black)
                
                
                .refreshable {
                    //  posts.getPosts(selectedClass: posts.selectedClass)
                }
                
                
                .navigationBarTitleDisplayMode(.inline)
                
                .navigationBarItems(leading: CustomNavigationBarTitle(selectedTitle: posts.selectedClass, ErrorMessage: false))
                .toolbar{
                    Button {
                        self.isShowingSheet = true
                    } label: {
                        Text("Add Post")
                            .foregroundColor(.cyan)
                    }
                    
                    .fullScreenCover(isPresented: $isShowingSheet)
                    {
                        AddPostView(viewModel: posts)
                    }
                    Menu {
                        ForEach(UserManager.shared.currentUser?.Classes ?? [], id: \.self){ curClass in
                            Button {
                                
                                posts.selectedClass = curClass
                                DispatchQueue.main.async {
                                    posts.getPosts()
                                }
                                
                            } label: {
                                Text("\(curClass)")
                                
                            }
                        }
                        
                    } label: {
                        Text("Classes")
                            .foregroundColor(.cyan)
                    }
                    
                }
                
            }
            .onAppear {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                
                let black = Color(red: 5/255, green: 5/255, blue: 5/255, opacity: 1.0)
                
                appearance.backgroundColor = UIColor(black)
                
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
            
        }
        
        
        
    }
}







struct DetailView: View{
    let selectedPost: ClassPost
    @ObservedObject var viewModel: ClassPostsViewModel
    @State var addingReply: Bool = false
    @State var addedReply: String = ""
    @FocusState private var focused:Bool
    @State  var fetchedReplies: [Replies] = []
    @Environment (\.presentationMode) var presentationMode
    @State private  var showingDeleteAlert: Bool = false
    @State private  var showingDeleteAlertReply: Bool = false
    func setFocus() {
        focused = true
    }
    private func hideKeyboard() {
#if os(iOS)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
#endif
    }
    
    
    
    
    var body: some View{
        ZStack{
            ZStack{
                Color.Black
                    .ignoresSafeArea()
                VStack{
                    VStack(alignment: .leading) {
                        // post author
                        HStack {
                            Text("\(selectedPost.postAuthor)")
                                .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                            
                                .foregroundColor(.cyan)
                            
                                .cornerRadius(10.0)
                            Spacer()
                            Text("\(convertEpochTimeToDate(epochTime: selectedPost.datePosted))")
                                .foregroundColor(Color.White)
                                .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                        }
                        // spacer to separate the post text and post voting
                        Spacer().frame(height: 20)
                        // post body with rounded background color
                        
                        HStack {
                            Text("\(selectedPost.postBody)")
                                .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                .foregroundColor(Color.White)
                                .cornerRadius(5.0)
                            
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)// Push text all the way to the left
                        }
                        
                        Spacer().frame(height: 20)
                        // vote buttons
                        HStack() {
                            // votes on the post
                            Text("\(selectedPost.votes)")
                                .foregroundColor(.cyan)
                            if !isAuthorPost(ofPost: selectedPost){
                                // upvote button
                                Button(action: {
                                    DispatchQueue.main.async {
                                        viewModel.handleVoteOnPost(UpOrDown: VoteType.up, onPost: selectedPost)
                                        
                                    }
                                }, label: {
                                    Image(systemName: "chevron.up")
                                })
                                .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                .buttonStyle(BorderlessButtonStyle())
                                
                                .foregroundColor(selectedPost.usersLiked.contains(UserManager.shared.currentUser?.Email ?? "") ? Color.green : Color.gray)
                                .opacity(selectedPost.usersLiked.contains(UserManager.shared.currentUser?.Email ?? "") ? 1 : 0.5)
                                .cornerRadius(10)
                                
                                // downvote button
                                Button(action: {
                                    DispatchQueue.main.async {
                                        viewModel.handleVoteOnPost(UpOrDown: VoteType.down, onPost: selectedPost)
                                    }
                                }) {
                                    Image(systemName: "chevron.down")
                                }
                                .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                .buttonStyle(BorderlessButtonStyle())
                                
                                .foregroundColor(selectedPost.usersDisliked.contains(UserManager.shared.currentUser?.Email ?? "") ? Color.red : Color.gray)
                                .opacity(selectedPost.usersDisliked.contains(UserManager.shared.currentUser?.Email ?? "") ? 1 : 0.5)
                                .cornerRadius(10)
                            }
                            
                            if isAuthorPost(ofPost: selectedPost) {
                                Spacer()
                                Button(action: {
                                    showingDeleteAlert = true
                                }) {
                                    Image(systemName: "trash")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .padding()
                                        .foregroundColor(.red)
                                        .cornerRadius(10)
                                }
                                .alert(isPresented: $showingDeleteAlert) {
                                    Alert(
                                        title: Text("Delete Post"),
                                        message: Text("Are you sure you want to delete this post?"),
                                        primaryButton: .destructive(Text("Delete")) {
                                            viewModel.deletePostAndReplies(selectedPost)
                                        },
                                        secondaryButton: .cancel()
                                    )
                                }
                            }
                        }
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                        
                        
                        .cornerRadius(15)
                        
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.Gray)
                    .cornerRadius(10) // Add corner radius to round the corners
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                    // Add corner radius to round the corners
                    //.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                    Spacer()
                    
                    
                    
                    
                    if selectedPost.replies.isEmpty{
                        Text("Replies will show up here")
                            .foregroundColor(.cyan)
                    }
                    ScrollView{
                        LazyVStack(spacing: 10) {
                            ForEach(selectedPost.replies) { reply in
                                
                                VStack(alignment: .leading) {
                                    // post author
                                    HStack {
                                        Text("\(reply.replyAuthor)")
                                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                        
                                            .foregroundColor(.cyan)
                                        
                                            .cornerRadius(10.0)
                                        Spacer()
                                        Text("\(convertEpochTimeToDate(epochTime: reply.DatePosted))")
                                            .foregroundColor(Color.White)
                                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                    }
                                    // spacer to separate the post text and post voting
                                    Spacer().frame(height: 20)
                                    // post body with rounded background color
                                    
                                    HStack {
                                        Text("\(reply.replyBody)")
                                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                            .foregroundColor(Color.White)
                                            .cornerRadius(5.0)
                                        
                                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                            .multilineTextAlignment(.leading)// Push text all the way to the left
                                    }
                                    
                                    Spacer().frame(height: 20)
                                    // vote buttons
                                    HStack() {
                                        // votes on the post
                                        Text("\(reply.votes)")
                                            .foregroundColor(.cyan)
                                        
                                        if !isAuthorReply(ofReply: reply){
                                            // upvote button
                                            Button(action: {
                                                DispatchQueue.main.async {
                                                    viewModel.handleVoteOnReply(VoteType.up, onPost: selectedPost, onReply: reply)
                                                }
                                            }, label: {
                                                Image(systemName: "chevron.up")
                                            })
                                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                            .buttonStyle(BorderlessButtonStyle())
                                            
                                            .foregroundColor(reply.UsersLiked.contains(UserManager.shared.currentUser?.Email ?? "") ? Color.green : Color.gray)
                                            .opacity(reply.UsersLiked.contains(UserManager.shared.currentUser?.Email ?? "") ? 1 : 0.5)
                                            .cornerRadius(10)
                                            
                                            // downvote button
                                            Button(action: {
                                                DispatchQueue.main.async {
                                                    viewModel.handleVoteOnReply(VoteType.down, onPost: selectedPost, onReply: reply)
                                                }
                                            }) {
                                                Image(systemName: "chevron.down")
                                            }
                                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                            .buttonStyle(BorderlessButtonStyle())
                                            
                                            .foregroundColor(reply.UserDownVotes.contains(UserManager.shared.currentUser?.Email ?? "") ? Color.red : Color.gray)
                                            .opacity(reply.UserDownVotes.contains(UserManager.shared.currentUser?.Email ?? "") ? 1 : 0.5)
                                            .cornerRadius(10)
                                        }
                                        
                                        
                                        if isAuthorReply(ofReply: reply) {
                                            Spacer()
                                            Button(action: {
                                                self.showingDeleteAlertReply = true
                                            }) {
                                                Image(systemName: "trash")
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                    .padding()
                                                    .foregroundColor(.red)
                                                    .cornerRadius(10)
                                            }
                                            .alert(isPresented: $showingDeleteAlertReply) {
                                                Alert(
                                                    title: Text("Delete Reply"),
                                                    message: Text("Are you sure you want to delete this reply?"),
                                                    primaryButton: .destructive(Text("Delete")) {
                                                        viewModel.deleteReply(reply, fromPost: selectedPost)
                                                    },
                                                    secondaryButton: .cancel()
                                                )
                                            }
                                        }
                                        
                                        
                                        
                                    }
                                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                    
                                    
                                    .cornerRadius(15)
                                    
                                    
                                    
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.Gray)
                                .cornerRadius(10) // Add corner radius to round the corners
                                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                                
                            }
                            
                        }
                        .background(Color.Black)
                        
                        
                    }
                    .padding(.leading, 10)
                    .padding(.trailing,10)
                    
                    .onAppear(){
                        selectedPost.getReplies(){r in
                            selectedPost.replies = r
                        }
                    }
                    .navigationBarBackButtonHidden(true)
                    .navigationBarItems(leading:
                                            Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        HStack{
                            Image(systemName: "arrow.left")
                            
                            
                            
                        }
                        .foregroundColor(.cyan)
                    })
                    )
                    .background(Color.Black)
                    .listStyle(GroupedListStyle())
                    .toolbar{
                        
                        Button {
                            
                            self.addingReply = true
                            
                        } label: {
                            Text("Add Reply")
                                .foregroundColor(.cyan)
                        }
                    }
                    
                    
                }
                
            }
        }
        .onTapGesture {
            hideKeyboard()
            self.addingReply = false
        }
        .onChange(of: focused) { newValue in
            if !newValue {
                hideKeyboard()
            }
        }
        
        if #available(iOS 16.0, *) {
            if addingReply {
                Group {
                    TextField("reply to \(selectedPost.postAuthor)", text: $addedReply,axis:.vertical)
                        .padding()
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                        .background(Color.gray)
                        .cornerRadius(5.0)
                        .multilineTextAlignment(.leading) // or .center
                        .focused($focused, equals: true)
                    
                }
                .onAppear {
                    
                    setFocus()
                    
                }
                .onChange(of: addedReply) { newValue in
                    if newValue.count > 300 {
                        addedReply = String(newValue.prefix(300))
                    }
                }
                .overlay(
                    HStack {
                        Spacer()
                        Button(action: {
                            let reply = addedReply.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !reply.isEmpty{
                                
                                viewModel.addReply(reply, to: selectedPost)
                            }
                            self.addedReply = ""
                            self.addingReply = false
                        }) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                                .padding(.horizontal, 10)
                        }
                    }
                )
            }
        } else {
            // Fallback on earlier versions
            Group {
                TextField("reply to \(selectedPost.postAuthor)", text: $addedReply)
                    .padding()
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                    .background(Color.gray)
                    .cornerRadius(5.0)
                    .multilineTextAlignment(.leading) // or .center
                    .focused($focused, equals: true)
                
            }
            .onAppear {
                DispatchQueue.main.async {
                    focused = true
                }
            }
            .onChange(of: addedReply) { newValue in
                if newValue.count > 300 {
                    addedReply = String(newValue.prefix(300))
                }
            }
            .overlay(
                HStack {
                    Spacer()
                    Button(action: {
                        let reply = addedReply.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !reply.isEmpty{
                            
                            viewModel.addReply(reply, to: selectedPost)
                        }
                        self.addedReply = ""
                        self.addingReply = false
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                            .padding(.horizontal, 10)
                    }
                }
            )
        }
        
        
        
    }
    
}
struct CustomNavigationBarTitle: View {
    let selectedTitle: String
    let ErrorMessage: Bool
    var body: some View {
        if ErrorMessage{
            Text("\(selectedTitle)")
                .padding(.leading, 5)
                .padding(.top, 5)
                .padding(.bottom, 1)
                .padding(.trailing, 5)
            // Use BorderlessButtonStyle instead of .borderedProminent
            
                .foregroundColor(Color.Black)// Set the background color of the button to red
                .cornerRadius(8)
                .font(.largeTitle)
        }
        else{
            Text("\(selectedTitle)")
                .padding(.leading, 5)
                .padding(.top, 5)
                .padding(.bottom, 1)
                .padding(.trailing, 5)
            // Use BorderlessButtonStyle instead of .borderedProminent
            
                .foregroundColor(Color.White)// Set the background color of the button to red
                .cornerRadius(8)
                .font(.largeTitle)
        }
        
    }
}
func convertEpochTimeToDate(epochTime: Double) -> String {
    let date = Date(timeIntervalSince1970: epochTime)
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd h:mm a"
    
    return dateFormatter.string(from: date)
}







struct ClassPostViewPostCell: View {
    let post: ClassPost
    @ObservedObject var viewModel: ClassPostsViewModel
    @State  private var showingDeleteAlert: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            // post author
            HStack {
                Text("\(post.postAuthor)")
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                    .foregroundColor(.cyan)
                    .cornerRadius(10.0)
                Spacer()
                Text("\(convertEpochTimeToDate(epochTime: post.datePosted))")
                    .foregroundColor(Color.White)
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            }
            Spacer().frame(height: 20)
            // post body with rounded background color
            HStack {
                Text("\(post.postBody)")
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                    .foregroundColor(Color.White)
                    .cornerRadius(5.0)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)// Push text all the way to the left
            }
            Spacer().frame(height: 20)
            // vote buttons
            HStack() {
                // votes on the post
                Text("\(post.votes)")
                    .foregroundColor(.cyan)
                
                if !isAuthorPost(ofPost: post){
                    // upvote button
                    Button(action: {
                        DispatchQueue.main.async {
                            viewModel.handleVoteOnPost(UpOrDown: VoteType.up, onPost: post)
                        }
                    }, label: {
                        Image(systemName: "chevron.up")
                    })
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                    .buttonStyle(BorderlessButtonStyle())
                    .foregroundColor(post.usersLiked.contains(UserManager.shared.currentUser?.Email ?? "") ? Color.green : Color.gray)
                    .opacity(post.usersLiked.contains(UserManager.shared.currentUser?.Email ?? "") ? 1 : 0.5)
                    .cornerRadius(10)
                    
                    // downvote button
                    Button(action: {
                        DispatchQueue.main.async {
                            viewModel.handleVoteOnPost(UpOrDown: VoteType.down, onPost: post)
                        }
                    }) {
                        Image(systemName: "chevron.down")
                    }
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                    .buttonStyle(BorderlessButtonStyle())
                    .foregroundColor(post.usersDisliked.contains(UserManager.shared.currentUser?.Email ?? "") ? Color.red : Color.gray)
                    .opacity(post.usersDisliked.contains(UserManager.shared.currentUser?.Email ?? "") ? 1 : 0.5)
                    .cornerRadius(10)
                }
                Spacer()
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding()
                        .foregroundColor(.red)
                        .cornerRadius(10)
                }
                .alert(isPresented: $showingDeleteAlert) {
                    Alert(
                        title: Text("Delete Post"),
                        message: Text("Are you sure you want to delete this post?"),
                        primaryButton: .destructive(Text("Delete")) {
                            viewModel.deletePostAndReplies(post)
                        },
                        secondaryButton: .cancel()
                    )
                }
                .opacity(isAuthorPost(ofPost: post) ? 1.0 : 0.0)  // Adjusts the opacity based on whether the post is authored by the current user
                .disabled(!isAuthorPost(ofPost: post))  // Disables the button for posts not authored by the current user
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            .cornerRadius(15)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.Gray)
        .cornerRadius(10) // Add corner radius to round the corners
        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
    }
}

func isAuthorPost(ofPost post:ClassPost) ->Bool{
    let user = Auth.auth().currentUser
    let email = user?.email
    return email == post.email
}

func isAuthorReply(ofReply reply:Replies) ->Bool{
    let user = Auth.auth().currentUser
    let email = user?.email
    return email == reply.email
}
