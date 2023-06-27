
import SwiftUI
import Firebase
import Kingfisher

struct ClassPosts: View {
    @StateObject var viewRouter: ViewRouter
    @EnvironmentObject var inAppVM: inAppViewVM
    @Environment(\.colorScheme) var colorScheme
    @State private var isShowingDetail = false
    @State private var isShowingSheet = false
    @State private var selectedPost: ClassPost?
    @State var addedPost: String = ""
    var body: some View {
        
        ZStack{
            NavigationView{
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        LazyVStack(spacing: 8) {
                            if inAppVM.postsForClass.isEmpty {
                                Text("There might have been a problem fetching the posts, try reloading the app. Or, you're the first to the party. You can get the party started!")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            } else {
                                ForEach(inAppVM.postsForClass) { post in
                                    Button(action: {
                                        withAnimation(.easeIn){
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                                                self.selectedPost = post
                                                self.isShowingDetail = true
                                                inAppVM.fetchReplies(forPost: post)
                                            }
                                        }
                                        
                                        
                                    }) {
                                        PostCellView(selectedPost: post).environmentObject(inAppVM)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.bottom,50)
                .background(Color.Black)
                .refreshable {
                    withAnimation {
                        inAppVM.getPosts(){ _ in}
                    }
                }
                
                .fullScreenCover(isPresented: $isShowingDetail) {
                    
                        if let post = selectedPost {
                            DetailView(selectedPost: post, isShowingDetail: $isShowingDetail)
                                .environmentObject(inAppVM)
                        }
                    
                    
                }
                
                
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading: Text("\(inAppVM.selectedClass)").foregroundColor(.white).font(.largeTitle))
                .toolbar{
                    Button {
                        self.isShowingSheet = true
                    } label: {
                        Text("Add Post")
                            .foregroundColor(.cyan)
                    }
                    
                    .fullScreenCover(isPresented: $isShowingSheet)
                    {
                        AddPostView()
                            .environmentObject(inAppVM)
                    }
                    Menu {
                        ForEach(inAppVM.userDoc.Classes, id: \.self){ curClass in
                            Button {
                                
                                inAppVM.selectedClass = curClass
                                DispatchQueue.main.async {
                                    inAppVM.getPosts(){ _ in}
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



struct ProfileImageView: View {
    let urlString: String?
    
    var body: some View {
        if let urlString = urlString, let url = URL(string: urlString) {
            KFImage(url)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
        } else {
            Image(systemName: "person.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
        }
    }
}




func convertEpochTimeToDate(epochTime: Double) -> String {
    let timeInterval = Date().timeIntervalSince1970 -  epochTime
    
    
    let secondsInYear: TimeInterval = 31536000
    let secondsInDay: TimeInterval = 86400
    let secondsInHour: TimeInterval = 3600
    let secondsInMinute: TimeInterval = 60
    
    if timeInterval < secondsInMinute {
        let seconds = Int(timeInterval)
        return "\(seconds) second\(seconds == 1 ? "" : "s") ago"
    } else if timeInterval < secondsInHour {
        let minutes = Int(timeInterval / secondsInMinute)
        return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
    } else if timeInterval < secondsInDay {
        let hours = Int(timeInterval / secondsInHour)
        return "\(hours) hour\(hours == 1 ? "" : "s") ago"
    } else if timeInterval < secondsInYear {
        let days = Int(timeInterval / secondsInDay)
        return "\(days) day\(days == 1 ? "" : "s") ago"
    } else {
        let years = Int(timeInterval / secondsInYear)
        return "\(years) year\(years == 1 ? "" : "s") ago"
    }
}








struct PostCellView: View {
    @State private var showingDeleteAlert = false
    var selectedPost: ClassPost  // Replace `Post` with your actual data type
    @EnvironmentObject var viewModel: inAppViewVM  // Replace `ViewModel` with your actual data type
    
    //Placeholder for your function to check if a post is authored by the current user
    
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                // post author
                HStack {
                    if let urlString = selectedPost.profilePicURL, let url = URL(string: urlString) {
                        KFImage(url)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    }
                    Text("\(selectedPost.postAuthor)")
                        .padding(10)
                        .foregroundColor(.cyan)
                        .cornerRadius(10.0)
                    Spacer()
                    Text("\(convertEpochTimeToDate(epochTime: selectedPost.datePosted))")
                        .foregroundColor(Color.white)
                        .padding(10)
                }
                .padding(.top,10)
                .padding(.leading,5)
                
                // post body with rounded background color
                Text("\(selectedPost.postBody)")
                    .padding(10)
                    .foregroundColor(Color.white)
                    .cornerRadius(5.0)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading) // Push text all the way to the left
                
                // vote buttons
                HStack {
                    // votes on the post
                    Text("\(selectedPost.votes)")
                        .foregroundColor(.cyan)
                    
                   
                        // upvote button
                    Button(action: {
                        DispatchQueue.main.async {
                            viewModel.handleVoteOnPost(UpOrDown: VoteType.up, onPost: selectedPost)
                        }
                    }) {
                        Image(systemName: "chevron.up")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .padding(10) // This line moved down
                    .foregroundColor(selectedPost.usersLiked.contains(viewModel.userDoc.Email ) ? Color.green : Color.gray)
                    .opacity(selectedPost.usersDisliked.contains(viewModel.userDoc.Email) ? 0.5 : 1)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.cyan, lineWidth: 1)
                    )
                    .disabled(viewModel.isVotingInProgress)

                        
                        // downvote button
                        Button(action: {
                            DispatchQueue.main.async {
                                viewModel.handleVoteOnPost(UpOrDown: VoteType.down, onPost: selectedPost)
                                
                            }
                        }) {
                            Image(systemName: "chevron.down")
                               
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .padding(10)
                        .foregroundColor(selectedPost.usersDisliked.contains(viewModel.userDoc.Email ) ? Color.red : Color.gray)
                        .opacity(viewModel.isVotingInProgress ? 0 : selectedPost.usersDisliked.contains(viewModel.userDoc.Email) ? 1 : 0.5)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.cyan, lineWidth: 1)
                                
                        )
                        
                        .disabled(viewModel.isVotingInProgress)
                   
                    
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
                    .opacity(isAuthorPost(ofPost: selectedPost) ? 1.0 : 0.0)  // Adjusts the opacity based on whether the post is authored by the current user
                    .disabled(!isAuthorPost(ofPost: selectedPost))  // Disables the button for posts not authored by the current user
                }
                .padding(.leading,10)
                .padding(.trailing,10)
                .cornerRadius(15)
            }
            .background(Color.Gray)
            
            .padding(.top,1)
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
        .cornerRadius(10)
    }
}


func isAuthorPost(ofPost post:ClassPost) ->Bool{
    let user = Auth.auth().currentUser
    let email = user?.email
    return email == post.email
}

func isAuthorReply(ofReply reply:Reply) ->Bool{
    let user = Auth.auth().currentUser
    let email = user?.email
    return email == reply.email
}

struct SlideOverTransition: ViewModifier {
    var show: Bool

    func body(content: Content) -> some View {
        Group {
            if show {
                content
                    .transition(.move(edge: .trailing))
                    .animation(.default)
            }
        }
    }
}
