//
//  UserProfileView.swift
//  NightOut
//
//  Created by Kyle Zeller on 12/20/22.
//
// need to finish the edit button and the edit screen

import SwiftUI
import Firebase
import Kingfisher



struct UserProfileView: View {
    
    @StateObject var viewRouter: ViewRouter
    @EnvironmentObject var inAppVM: inAppViewVM
    
    
    //EditProfileView Variables
    @State private var showingEditProfile: Bool = false
    @State private var showingCover:Bool = false
    @State private var isShowingDetail = false
    @State private var isShowingReply = false
    @State private var selectedPost: ClassPost?
    
    
    
    var body: some View {
    
                NavigationView{
                    ZStack {
                        Color.black
                            .ignoresSafeArea()
        
                        VStack {
                            HStack{
                                if let urlString = inAppVM.userDoc.profilePictureURL, let url = URL(string: urlString) {
                                        KFImage(url)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                            .padding(.trailing,10)
                                    } else {
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                            .padding(.trailing,10)
                                    }
        
        
                                Text("\(inAppVM.userDoc.FullName)")
                                                            .font(.largeTitle)
                                                            .foregroundColor(.white)
                                                            .accessibilityHidden(true)
                                Spacer()
                                Button(action: {
                                    showingCover = true
                                }) {
                                    Image(systemName: "gear")
                                        .font(.title)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.leading,20)
                            .padding(.trailing,20)
                            VStack(alignment: .leading, spacing: 20){
        
                                Text("\(inAppVM.userDoc.College)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
        
                                Text("Studying \(inAppVM.userDoc.Major)")
                                    .font(.body)
                                    .foregroundColor(.white)
        
                                Divider()
                                    .background(Color.gray)
                                    .padding(.vertical, 20)
        
                                Text("My Posts")
                                    .font(.title)
                                    .foregroundColor(.white)
        
                                if inAppVM.postsforUser.isEmpty {
                                    Text("Posts you have made will show up here.")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .padding(.top, 10)
                                }
                            }
                            .padding(.horizontal, 20)
        
                            ScrollView(showsIndicators: false) {
                                VStack(spacing: 8) {
        //                            if inAppVM.isLoadingPosts {
        //                                ProgressView()
        //                                    .scaleEffect(1.5)
        //                            }
        
                                    LazyVStack(spacing: 8) {
                                        if inAppVM.postsforUser.isEmpty {
                                            Text("There might have been a problem fetching the posts, try reloading the app. Or, you're the first to the party. You can get the party started!")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                        } else {
                                            ForEach(inAppVM.postsforUser) { post in
                                                Button(action: {
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                                                        self.selectedPost = post
                                                        self.isShowingReply = true
                                                        inAppVM.fetchReplies(forPost: post)
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
                            .refreshable {
                                withAnimation {
        
        
                                    inAppVM.getPostsForUser(){_ in}
        
                                }
                            }
                            .fullScreenCover(isPresented: $isShowingReply) {
                                if let post = selectedPost {
                                    DetailView(selectedPost: post, isShowingDetail: $isShowingReply)
                                        .environmentObject(inAppVM)
                                }
                            }
                            .overlay(
                                Group {
                                    if inAppVM.isLoadingPosts {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
                                    }
                                }
                            )
        
        
                        }
        //
        
        
                    }
        
                }
                .fullScreenCover(isPresented: $showingCover) {
                    SettingsView(viewRouter: viewRouter)
                        .environmentObject(inAppVM)
                }
            }
        
    }
    
    
    struct ClassTextModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(5)
                .background(Color.gray)
                .foregroundColor(Color.White)
                .cornerRadius(10)
            
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    struct UserProfilePostCell: View {
        let selectedPost:ClassPost
        @EnvironmentObject var inappVM:inAppViewVM
        @State  private var showingDeleteAlert: Bool = false
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
                        Text("\(selectedPost.forClass)")
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
                                    inappVM.deletePostAndReplies(selectedPost)
                                },
                                secondaryButton: .cancel()
                            )
                        }
                        
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

