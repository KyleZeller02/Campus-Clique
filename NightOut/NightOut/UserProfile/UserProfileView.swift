//
//  UserProfileView.swift
//  NightOut
//
//  Created by Kyle Zeller on 12/20/22.
//


import SwiftUI
import Firebase
import Kingfisher



/// `UserProfileView` displays the profile of the user.
///
/// It shows the user's name, college, major, and a list of posts made by the user.
/// It also provides an option to edit the profile and access settings.
struct UserProfileView: View {
    /// ViewModel that manages the app's shared state.
    @EnvironmentObject var inAppVM: inAppViewVM
    
    /// Indicates whether the edit profile view is presented.
    @State private var showingEditProfile: Bool = false
    /// Indicates whether the cover view is presented.
    @State private var showingCover: Bool = false
    /// Indicates whether the detail view is presented.
    @State private var isShowingDetail = false
    /// Indicates whether the detail view for a post is presented.
    @State private var isShowingDetailPost = false
    /// Indicates whether the reply view is presented.
    @State private var isShowingReply = false
    /// Holds the post selected by the user.
    @State private var selectedPost: ClassPost?
    
    /// The body of the `UserProfileView`.
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color.black.ignoresSafeArea()
                
                // Main VStack for user profile elements
                VStack {
                    // HStack for profile image and name
                    HStack{
                        // Fetch and display profile image
                        if let urlString = inAppVM.userDoc.profilePictureURL, let url = URL(string: urlString) {
                            KFImage(url)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .padding(.trailing,10)
                        } else {
                            // Default image when no profile picture is available
                            Image(systemName: "person.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .padding(.trailing,10)
                        }
                        
                        // Display user's full name
                        Text("\(inAppVM.userDoc.fullName)")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .accessibilityHidden(true)
                        Spacer()
                        
                        // Button to show settings
                        Button(action: {
                            showingCover = true
                        }) {
                            Image(systemName: "gear")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // VStack for college and major details
                    VStack(alignment: .leading, spacing: 20){
                        
                        Text("\(inAppVM.userDoc.college)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Studying \(inAppVM.userDoc.major)")
                            .font(.body)
                            .foregroundColor(.white)
                        
                        Divider()
                            .background(Color.gray)
                            .padding(.vertical, 20)
                        
                        Text("My Posts")
                            .font(.title)
                            .foregroundColor(.white)
                        
                        // Placeholder text when there are no posts
                        if inAppVM.postsforUser.isEmpty {
                            Text("Posts you have made will show up here.")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top, 10)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // ScrollView to show user's posts
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 8) {
                            LazyVStack(spacing: 8) {
                                // Loop through posts
                                ForEach(inAppVM.postsforUser) { post in
                                    NavigationLink(destination: DetailView(selectedPost: post, isShowingDetail: $isShowingDetailPost)
                                        .environmentObject(inAppVM)) {
                                            PostCellView(selectedPost: post).environmentObject(inAppVM)
                                        }
                                }
                            }
                        }
                    }
                    .refreshable {
                        withAnimation {
                            inAppVM.getPostsForUser(){_ in}
                        }
                    }
                }
            }
        }
        .accentColor(.cyan)
        .fullScreenCover(isPresented: $showingCover) {
            // Show settings view when gear button is clicked
            SettingsView()
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












