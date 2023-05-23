//
//  ClassPosts.swift
//  NightOut
//
//  Created by Kyle Zeller on 1/13/23.
//

import SwiftUI
import Firebase

struct ClassPosts: View {
    @StateObject var viewRouter: ViewRouter
    @StateObject var posts: ClassPostsViewModel = ClassPostsViewModel()
    @State private var isShowingSheet = false
    @State var addedPost: String = ""
    @StateObject var profileVM: UserProfileViewModel = UserProfileViewModel()
    
   
    var body: some View {
        
        ZStack{
            Color.Black
            NavigationView{
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(posts.postsArray) { post in
                                NavigationLink(destination: DetailView(selectedPost: post, viewModel: posts, canEdit: true)) {
                                    VStack(alignment: .leading) {
                                        // post author
                                        HStack {
                                            Text("\(post.postAuthor)")
                                                .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                                .background(Color.Purple)
                                                .foregroundColor(Color.White)
                                                .font(.headline)
                                                .cornerRadius(10.0)
                                        }
                                        // spacer to separate the post text and post voting
                                        Spacer().frame(height: 20)
                                        // post body with rounded background color
                                        ZStack {
                                            Color.gray // Background color with rounded corners
                                                .cornerRadius(10) // Add corner radius to round the corners
                                                .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)) // Adjust padding to not go to the edge
                                            HStack {
                                                Text("\(post.postBody)")
                                                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                                    .foregroundColor(Color.White)
                                                    .cornerRadius(5.0)
                                                    .font(.headline)
                                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading) // Push text all the way to the left
                                            }
                                        }
                                        Spacer().frame(height: 20)
                                        // vote buttons
                                        HStack() {
                                            // votes on the post
                                            Text("\(post.votes)")
                                            // upvote button
                                            Button(action: {
                                                DispatchQueue.main.async {
                                                    posts.handleVoteOnPost(UpOrDown: "up", onPost: post)
                                                }
                                            }, label: {
                                                Image(systemName: "arrow.up")
                                            })
                                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                            .buttonStyle(BorderlessButtonStyle())
                                            .background(Color.White)
                                            .foregroundColor(Color.Black)
                                            .cornerRadius(10)
                                            // downvote button
                                            Button(action: {
                                                DispatchQueue.main.async {
                                                    posts.handleVoteOnPost(UpOrDown: "down", onPost: post)
                                                }
                                            }) {
                                                Image(systemName: "arrow.down")
                                            }
                                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                            .buttonStyle(BorderlessButtonStyle())
                                            .background(Color.White)
                                            .foregroundColor(Color.Black)
                                            .cornerRadius(10)
                                        }
                                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                        .background(Color.Purple)
                                        .foregroundColor(Color.White)
                                        .cornerRadius(15)
                                        .font(.headline)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.Gray)
                                    .cornerRadius(10) // Add corner radius to round the corners
                                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                                    
                                }
                            }
                        }
                        
                        
                        //.background(Color.gray) // Set background color for the LazyVStack
                    }
                    
                    .background(Color.Black)
                    
                    
                    .refreshable {
                        posts.getPosts(selectedClass: posts.selectedClass){ p in
                            posts.postsArray = p
                            posts.objectWillChange.send()
                        }
                    }
                    
                    
                    .navigationBarTitleDisplayMode(.inline)
                    
                    .navigationBarItems(leading: CustomNavigationBarTitle(selectedTitle: posts.selectedClass, ErrorMessage: false))
                    .toolbar{
                        Button {
                            self.isShowingSheet = true
                        } label: {
                            Text("Add Post")
                                .padding(.bottom, 10)
                                .padding(.leading, 10)
                                .padding(.trailing,10)
                                .padding(.top,10)
                            
                                .background(Color.Purple)
                                .foregroundColor(.white)
                                .cornerRadius(10.0)
                            
                                .font(.headline)
                        }
                        .sheet(isPresented: $isShowingSheet)
                        {
                            AddPostView()
                        }
                        Menu {
                            ForEach(profileVM.userDocument.Classes ?? [], id: \.self){ curClass in
                                Button {
                                    
                                    posts.selectedClass = curClass
                                    DispatchQueue.main.async {
                                        posts.getPosts(selectedClass: posts.selectedClass){ p in
                                            posts.postsArray = p
                                            
                                            posts.objectWillChange.send()
                                        }
                                    }
                                    
                                } label: {
                                    Text("\(curClass)")
                                    
                                }
                            }
                            
                        } label: {
                            Text("Classes")
                                .padding(.bottom, 10)
                                .padding(.leading, 10)
                                .padding(.trailing,10)
                                .padding(.top,10)
                            
                                .background(Color.Purple)
                                .foregroundColor(.white)
                                .cornerRadius(10.0)
                            
                                .font(.headline)
                        }
                        .simultaneousGesture(TapGesture().onEnded() {
                            let curUser = profileVM.CurUser()
                            profileVM.getDocument(user: curUser){ doc in
                                self.profileVM.userDocument = doc
                                
                            }
                        })
                    }
                    
                    
                
            }
        }
            
            
        
        
        
        
        
    }
}

struct ClassPosts_Previews: PreviewProvider {
    static var previews: some View {
        ClassPosts(viewRouter: ViewRouter())
    }
}


struct DetailView: View{
    let selectedPost: ClassPost
    @ObservedObject var viewModel: ClassPostsViewModel
    @State var showSheet: Bool = false
    @State var addedReply: String = ""
    let canEdit: Bool
    @State private var fetchedReplies: [Replies] = []
    @Environment (\.presentationMode) var presentationMode
    
    
    
    var body: some View{
        
        ZStack{
            Color.Black
                .ignoresSafeArea()
            VStack{
                VStack(alignment: .leading) {
                    
                    Text("\(selectedPost.postAuthor)")
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                        .background(Color.Purple)
                        .foregroundColor(Color.White)
                        .font(.headline)
                        .cornerRadius(10.0)
                    Spacer()
                    ZStack {
                        Color.gray // Background color with rounded corners
                            .cornerRadius(10) // Add corner radius to round the corners
                            .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)) // Adjust padding to not go to the edge
                        HStack {
                            Text("\(selectedPost.postBody)")
                                .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                .foregroundColor(Color.White)
                                .cornerRadius(5.0)
                                .font(.headline)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading) // Push text all the way to the left
                        }
                    }
                    Spacer()
                    HStack() {
                        // votes on the post
                        Text("\(selectedPost.votes)")
                        // upvote button
                        Button(action: {
                            DispatchQueue.main.async {
                                viewModel.handleVoteOnPost(UpOrDown: "up", onPost: selectedPost)
                            }
                        }, label: {
                            Image(systemName: "arrow.up")
                        })
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                        .buttonStyle(BorderlessButtonStyle())
                        .background(Color.White)
                        .foregroundColor(Color.Black)
                        .cornerRadius(10)
                        // downvote button
                        Button(action: {
                            DispatchQueue.main.async {
                                viewModel.handleVoteOnPost(UpOrDown: "down", onPost: selectedPost)
                            }
                        }) {
                            Image(systemName: "arrow.down")
                        }
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                        .buttonStyle(BorderlessButtonStyle())
                        .background(Color.White)
                        .foregroundColor(Color.Black)
                        .cornerRadius(10)
                    }
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                    .background(Color.Purple)
                    .foregroundColor(Color.White)
                    .cornerRadius(15)
                    .font(.headline)
                   
                    
                }
                .frame(height: UIScreen.main.bounds.height / 3)
                .background(Color.Gray)
                .cornerRadius(10)
                // Add corner radius to round the corners
                //.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            
            
            
            
            
            
            
            
            ScrollView{
                LazyVStack(spacing: 10) {
                    ForEach(fetchedReplies) { reply in
                       
                        VStack(alignment: .leading) {
                            
                            HStack {
                                Text("\(reply.replyAuthor)")
                                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                    .background(Color.Purple)
                                    .foregroundColor(Color.White)
                                    .font(.headline)
                                    .cornerRadius(10.0)
                            }
                            // post body with rounded background color
                            ZStack {
                                Color.gray // Background color with rounded corners
                                    .cornerRadius(10) // Add corner radius to round the corners
                                    .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)) // Adjust padding to not go to the edge
                                HStack {
                                    Text("\(reply.replyBody)")
                                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                        .foregroundColor(Color.White)
                                        .cornerRadius(5.0)
                                        .font(.headline)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading) // Push text all the way to the left
                                }
                            }
                            
                            Spacer()
                            // vote buttons
                            HStack() {
                                // votes on the post
                                Text("\(reply.votes)")
                                // upvote button
                                Button(action: {
                                    DispatchQueue.main.async {
                                        viewModel.handleVoteOnReply(UpOrDown: "up", onPost: selectedPost, onReply: reply)
                                    }
                                }, label: {
                                    Image(systemName: "arrow.up")
                                })
                                .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                .buttonStyle(BorderlessButtonStyle())
                                .background(Color.White)
                                .foregroundColor(Color.Black)
                                .cornerRadius(10)
                                // downvote button
                                Button(action: {
                                    DispatchQueue.main.async {
                                        viewModel.handleVoteOnReply(UpOrDown: "down", onPost: selectedPost, onReply: reply)
                                    }
                                }) {
                                    Image(systemName: "arrow.down")
                                }
                                .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                .buttonStyle(BorderlessButtonStyle())
                                .background(Color.White)
                                .foregroundColor(Color.Black)
                                .cornerRadius(10)
                            }
                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                            .background(Color.Purple)
                            .foregroundColor(Color.White)
                            .cornerRadius(15)
                            .font(.headline)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.Gray)
                        .cornerRadius(10) // Add corner radius to round the corners
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                        
                    }
                    
                }
                .background(Color.Black)
                
                
            }
            
            .onAppear {
                selectedPost.getReplies { replies in
                    DispatchQueue.main.async {
                        fetchedReplies = replies
                    }
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
                .padding(.bottom, 10)
                .padding(.leading, 10)
                .padding(.trailing,10)
                .padding(.top,10)
            
                .background(Color.Purple)
                .foregroundColor(.white)
                .cornerRadius(10.0)
            
                .font(.headline)
            })
            )
            .background(Color.Black)
            .listStyle(GroupedListStyle())
            .toolbar{
                if canEdit{
                    Button {
                        self.showSheet = true
                    } label: {
                        Text("Add Reply")
                            .padding(.bottom, 10)
                            .padding(.leading, 10)
                            .padding(.trailing,10)
                            .padding(.top,10)
                        
                            .background(Color.Purple)
                            .foregroundColor(.white)
                            .cornerRadius(10.0)
                        
                            .font(.headline)
                    }
                }
                
                
                
            }
           
            .sheet(isPresented: $showSheet)
            {
                ZStack{
                    VStack{
                        Text("Join In On The Conversation!")
                            .padding(30)
                            .font(.system(size:40))
                        TextEditor(text: $addedReply)
                            .autocapitalization(UITextAutocapitalizationType.words)
                            .padding()
                            .background(Color.Gray)
                            .cornerRadius(5.0)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                            .frame(minWidth: 200, maxWidth: .infinity,minHeight: 50,maxHeight: .infinity)
                        Button {
                            //send to firebase and update view
                            if addedReply != "" {
                                let author = viewModel.profileVM.userDocument.FullName

                                DispatchQueue.global().async {
                                    selectedPost.addReply(author: author, replyBody: addedReply)
                                    addedReply = ""
                                    self.showSheet.toggle()
                                }

                                
                            } else {
                                addedReply = ""
                                self.showSheet.toggle()
                            }

                        } label: {
                            Text("Share Post")
                                .font(.system(size:30))
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 190, height: 60)
                                .background(Color.Purple)
                                .cornerRadius(15.0)
                        }
                    }
                }
                Spacer()
            }
            }
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



