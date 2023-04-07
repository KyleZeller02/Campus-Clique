//
//  ClassPosts.swift
//  NightOut
//
//  Created by Kyle Zeller on 1/13/23.
//

import SwiftUI

struct ClassPosts: View {
    @StateObject var viewRouter: ViewRouter
    @StateObject var posts: ClassPostsViewModel = ClassPostsViewModel()
    @State private var isShowingSheet = false
    @State var addedPost: String = ""
    @AppStorage("Email") var SavedEmail: String?
    @StateObject var profileVM: UserProfileViewModel = UserProfileViewModel()
    var body: some View {
        
        NavigationView{
            
            List{
                ForEach(posts.postsArray){ post in
                    NavigationLink( destination: DetailView(selectedPost: post ,viewModel: posts) , label: {
                        
                        VStack(alignment: .leading){
                            // post author and post body
                            HStack{
                               
                                //the author of the ppost
                                Text("\(post.postAuthor)")
                                    .padding(5)
                                    .background(Color.Gray)
                                //the body of the post
                                Text("\(post.postBody)")
                                    .foregroundColor(Color.Black)
                                
                                
                                
                            }
                            //spacer to seperate the post text and post voting
                            Spacer()
                            // vote buttons
                            HStack{
                                //votes on the post
                                Text("\(post.votes)")
                                
                                //upvote button
                                Button(action: {
                                    DispatchQueue.main.async {
                                        posts.handleVoteOnPost(UpOrDown: "up", onPost: post)
                                       
                                    }
                                }, label: {
                                    Image(systemName: "arrow.up")
                                })
                                .buttonStyle(.borderedProminent)
                                .padding(.leading,10)
                                //downvote button
                                Button(action: {
                                    DispatchQueue.main.async {
                                        posts.handleVoteOnPost(UpOrDown: "down", onPost: post)
                                        
                                    }
                                }, label: {
                                    Image(systemName: "arrow.down")
                                })
                                .padding(.leading,10)
                                .buttonStyle(.borderedProminent)
                            }
                            
                            .padding(.bottom,10)
                            
                        }
                        
                    })
                    
                }
                
            }
            .refreshable {
                 posts.getPosts(selectedClass: posts.selectedClass){ newPosts in
                    posts.postsArray = newPosts
                }
            }
            
            
            .navigationTitle("\(posts.selectedClass)")
            .toolbar{
                Button {
                    self.isShowingSheet = true
                } label: {
                    Text("Add Post")
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
                        }
                        .simultaneousGesture(TapGesture().onEnded() {
                               
                            profileVM.getDocument(){ doc in
                                self.profileVM.userDocument = doc
                            }
                            })
            }
            .listStyle(GroupedListStyle())
            
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
                            
                    }
                    
                    Spacer()
                    //upvote button
                    HStack{
                        Text("\(reply.votes)")
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
                    
                    .padding(.leading,10)
                    
                }
                
            }
            
            
        }
        .listStyle(GroupedListStyle())
        .toolbar{
            Button {
                self.showSheet = true
            } label: {
                Text("Add Reply")
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
                                viewModel.sortReplies()
                                
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
                viewModel.sortReplies()
                
            }
            for rep in selectedPost.replies{
                print("reply: \(rep.UsersLiked)")
            }
            
        }
        
    }
        
}
