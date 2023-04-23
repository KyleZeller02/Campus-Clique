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
            NavigationView{
                if posts.postsArray.isEmpty{
                    Text("There are currently no posts in this class. Get the party started!")
                        .padding(.bottom, 10)
                        .padding(.leading, 10)
                        .padding(.trailing,10)
                        .padding(.top,10)
                        
                        .background(Color.indigo)
                        .foregroundColor(.white)
                        .cornerRadius(10.0)
                        
                        .font(.largeTitle)
                        .navigationBarTitleDisplayMode(.inline)
                                   
                        .navigationBarItems(leading: CustomNavigationBarTitle(selectedTitle: posts.selectedClass, ErrorMessage: true))
                        .toolbar{
                            Button {
                                self.isShowingSheet = true
                            } label: {
                                Text("Add Post")
                                    .padding(.bottom, 10)
                                    .padding(.leading, 10)
                                    .padding(.trailing,10)
                                    .padding(.top,10)
                                    
                                    .background(Color.indigo)
                                    .foregroundColor(.white)
                                    .cornerRadius(10.0)
                                    
                                    .font(.headline)
                            }
                            .sheet(isPresented: $isShowingSheet)
                            {
                                ZStack{
                                    VStack{
                                        Text("Share A Post With Your Classmates!")
                                            .padding(30)
                                            .font(.system(size:40))
                                        TextField("Your Post", text: $addedPost)
                                            .autocapitalization(UITextAutocapitalizationType.words)
                                            .padding()
                                            .background(Color.Gray)
                                            .cornerRadius(5.0)
                                            .padding(.leading, 20)
                                            .padding(.trailing, 20)
                                            .frame(minWidth: 200, maxWidth: .infinity,minHeight: 50,maxHeight: .infinity)
                                        Button {
                                            //send to firebase and update view
                                            if addedPost == ""{
                                                self.isShowingSheet.toggle()
                                                //Probably needs to get rid of this posts.add
                                                //posts.addPost(postBody: addedPost)
                                            }
                                            else{
                                                posts.addPost(postBody: addedPost)
                                                addedPost = ""
                                                self.isShowingSheet.toggle()
                                            }
                                        } label: {
                                            Text("Share Post")
                                                .font(.system(size:30))
                                                .foregroundColor(.white)
                                                .padding()
                                                .frame(width: 190, height: 60)
                                                .background(.indigo)
                                                .cornerRadius(15.0)
                                        }
                                    }
                                }
                                Spacer()
                            }
                            Menu {
                                ForEach(profileVM.userDocument.Classes ?? [], id: \.self){ curClass in
                                    Button {
                                        
                                        posts.selectedClass = curClass
                                        DispatchQueue.main.async {
                                            posts.getPosts(selectedClass: posts.selectedClass) { res in
                                                posts.postsArray = res
                                                posts.sortPosts()
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
                                    
                                    .background(Color.indigo)
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
                else{
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(posts.postsArray) { post in
                                NavigationLink(destination: DetailView(selectedPost: post, viewModel: posts, canEdit: true)) {
                                    VStack(alignment: .leading) {
                                        // post author and post body
                                        HStack {
                                            // the author of the post
                                            Text("\(post.postAuthor)")
                                                .padding(.bottom, 10)
                                                .padding(.leading, 10)
                                                .padding(.trailing,10)
                                                .padding(.top,10)
                                                
                                                .background(Color.indigo)
                                                .foregroundColor(.white)
                                                .cornerRadius(10.0)
                                                
                                                .font(.headline) // Updated from Color.Gray
                                            // the body of the post
                                            // Updated from Color.Black
                                        }
                                        // spacer to separate the post text and post voting
                                        Spacer()
                                        HStack{
                                            Text("\(post.postBody)")
                                                .padding(.bottom, 10)
                                                .padding(.leading, 10)
                                                .padding(.trailing,10)
                                                .padding(.top,10)
                                                
                                                .font(.headline)
                                                .foregroundColor(Color.White)
                                                .cornerRadius(10.0)
                                        }
                                        // vote buttons
                                        HStack {
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
                                            .padding(.leading, 10)
                                            .padding(.top, 10)
                                            .padding(.bottom, 10)
                                            .padding(.trailing, 10)
                                            .buttonStyle(BorderlessButtonStyle()) // Use BorderlessButtonStyle instead of .borderedProminent
                                            .background(Color.White)
                                            .foregroundColor(Color.Black)// Set the background color of the button to red
                                            .cornerRadius(8)
                                            // downvote button
                                            Button(action: {
                                                DispatchQueue.main.async {
                                                    posts.handleVoteOnPost(UpOrDown: "down", onPost: post)
                                                }
                                            }) {
                                                Image(systemName: "arrow.down")
                                            }
                                            .padding(.leading, 10)
                                            .padding(.top, 10)
                                            .padding(.bottom, 10)
                                            .padding(.trailing, 10)
                                            .buttonStyle(BorderlessButtonStyle()) // Use BorderlessButtonStyle instead of .borderedProminent
                                            .background(Color.White)
                                            .foregroundColor(Color.Black) // Set the background color of the button to red
                                            .cornerRadius(8)
                                        }
                                        .padding(.bottom, 10)
                                        .padding(.leading, 10)
                                        .padding(.trailing,10)
                                        .padding(.top,10)
                                        
                                        .background(Color.indigo)
                                        .foregroundColor(.white)
                                        .cornerRadius(5.0)
                                        
                                        .font(.headline)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .cornerRadius(10) // Set corner radius for rounded edges
                                    .background(Color.gray) // Set background color for the list items
                                }
                            }
                        }
                        
                        //.background(Color.gray) // Set background color for the LazyVStack
                    }
                    
                    .background(Color.Black)
                   
                    .refreshable {
                        posts.getPosts(selectedClass: posts.selectedClass) { newPosts in
                            posts.postsArray = newPosts
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
                                
                                .background(Color.indigo)
                                .foregroundColor(.white)
                                .cornerRadius(10.0)
                                
                                .font(.headline)
                        }
                        .sheet(isPresented: $isShowingSheet)
                        {
                            ZStack{
                                VStack{
                                    Text("Share A Post With Your Classmates!")
                                        .padding(30)
                                        .font(.system(size:40))
                                    TextField("Your Post", text: $addedPost)
                                        .autocapitalization(UITextAutocapitalizationType.words)
                                        .padding()
                                        .background(Color.Gray)
                                        .cornerRadius(5.0)
                                        .padding(.leading, 20)
                                        .padding(.trailing, 20)
                                        .frame(minWidth: 200, maxWidth: .infinity,minHeight: 50,maxHeight: .infinity)
                                    Button {
                                        //send to firebase and update view
                                        if addedPost == ""{
                                            self.isShowingSheet.toggle()
                                            //Probably needs to get rid of this posts.add
                                            //posts.addPost(postBody: addedPost)
                                        }
                                        else{
                                            posts.addPost(postBody: addedPost)
                                            addedPost = ""
                                            self.isShowingSheet.toggle()
                                        }
                                    } label: {
                                        Text("Share Post")
                                            .font(.system(size:30))
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(width: 190, height: 60)
                                            .background(.indigo)
                                            .cornerRadius(15.0)
                                    }
                                }
                            }
                            Spacer()
                        }
                        Menu {
                            ForEach(profileVM.userDocument.Classes ?? [], id: \.self){ curClass in
                                Button {
                                    
                                    posts.selectedClass = curClass
                                    DispatchQueue.main.async {
                                        posts.getPosts(selectedClass: posts.selectedClass) { res in
                                            posts.postsArray = res
                                            posts.sortPosts()
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
                                
                                .background(Color.indigo)
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
    
    
    var body: some View{
        VStack{
            Text("\(selectedPost.postBody)")
                .multilineTextAlignment(.leading)
                .font(.title)
            Text("- \(selectedPost.postAuthor)")
                .font(.title)
        }
        
        List{
            ForEach(viewModel.curReplies) { reply in
                
                VStack{
                    HStack(){
                        Text("\(reply.replyAuthor)")
                            .padding(5)
                            .background(Color.Gray)
                        
                        
                        //the body of the post
                        Text("\(reply.replyBody)")
                            .foregroundColor(Color.Black)
                        Spacer()
                    }
                    
                    Spacer()
                    //upvote button
                    HStack(){
                        Text("\(reply.votes)")
                        
                        if canEdit{
                            Button {
                                DispatchQueue.main.async {
                                    viewModel.handleVoteOnReply(UpOrDown: "up", onPost: selectedPost, onReply: reply)
                                }
                                
                                
                            } label: {
                                Image(systemName: "arrow.up")
                            }
                            .padding(.leading,10)
                            .buttonStyle(.borderedProminent)
                            
                            //downvote button
                            Button(action: {
                                DispatchQueue.main.async {
                                    viewModel.handleVoteOnReply(UpOrDown: "down", onPost: selectedPost, onReply: reply)
                                }
                            }, label: {
                                Image(systemName: "arrow.down")
                                
                            })
                            .padding(.leading,10)
                            .buttonStyle(.borderedProminent)
                        }
                        Spacer()
                    }
                    
                    .padding(.leading,10)
                    
                }
                
            }
            
            
        }
        .listStyle(GroupedListStyle())
        .toolbar{
            if canEdit{
                Button {
                    self.showSheet = true
                } label: {
                    Text("Add Reply")
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
                    TextField("Your Reply", text: $addedReply)
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
                            viewModel.addReply(forPost: selectedPost, replyBody: addedReply)
                            DispatchQueue.main.async {
                                viewModel.getReplies(forPost: selectedPost){ replies in
                                    viewModel.curReplies = replies
                                }
                                
                                
                            }
                            addedReply = ""
                            self.showSheet.toggle()
                        }
                        else{
                            addedReply = ""
                            self.showSheet.toggle()
                        }
                    } label: {
                        Text("Share Post")
                            .font(.system(size:30))
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 190, height: 60)
                            .background(.indigo)
                            .cornerRadius(15.0)
                    }
                }
            }
            Spacer()
        }
        .onAppear{
            DispatchQueue.main.async {
                viewModel.getReplies(forPost: selectedPost){ replies in
                    viewModel.curReplies = replies
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
