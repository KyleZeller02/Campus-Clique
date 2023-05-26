//
//  UserProfileView.swift
//  NightOut
//
//  Created by Kyle Zeller on 12/20/22.
//
// need to finish the edit button and the edit screen

import SwiftUI
import Firebase

struct UserProfileView: View {
    
    @StateObject var viewRouter: ViewRouter
    @StateObject var profileVM: UserProfileViewModel = UserProfileViewModel()
    
    @StateObject var posts: ClassPostsViewModel = ClassPostsViewModel()
    //EditProfileView Variables
    @State private var showingEditProfile: Bool = false
    @State private var showingCover:Bool = false
    
    
    
    var body: some View {
        NavigationView{
            ZStack {
                Color.black
                    .ignoresSafeArea()

                VStack {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("\(profileVM.userDocument.College)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("Studying \(profileVM.userDocument.Major)")
                            .font(.body)
                            .foregroundColor(.white)

                        Divider()
                            .background(Color.white.opacity(0.5))
                            .padding(.vertical, 20)

                        Text("My Posts")
                            .font(.title)
                            .foregroundColor(.white)

                        if profileVM.usersPosts.isEmpty {
                            Text("Posts you have made will show up here.")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top, 10)
                        }
                    }
                    .padding(.horizontal, 20)

                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(posts.userPosts) { post in
                                NavigationLink(destination: DetailView(selectedPost: post, viewModel: posts)) {
                                    UserProfilePostCell(post: post, viewModel: posts, profileVM: profileVM)
                                }
                            }
                        }
                    }
                    .background(Color.black)
                    .refreshable {
                        posts.refresh()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("\(profileVM.userDocument.FullName)")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .accessibilityHidden(true)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingCover = true
                            
                        }) {
                            Image(systemName: "gear")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingCover) {
            SettingsView(profileVM: profileVM)
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




struct SettingsView: View {
    @State private var isShowingEditProfileView = false
    @Environment(\.presentationMode) var presentationMode
    let profileVM: UserProfileViewModel

    var body: some View {
        ZStack {
            Color.Black
                .ignoresSafeArea()

            VStack {
                HStack {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding()
                
                Text("Settings")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.bottom, 50)

                Button(action: {
                    self.isShowingEditProfileView = true
                }) {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                        Text("Edit Profile")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.Purple, lineWidth: 4)
                    )
                    .cornerRadius(10)
                }
                .padding(.horizontal, 10)
                .fullScreenCover(isPresented: $isShowingEditProfileView, content: {
                    EditProfileView(profileVM: profileVM)
                })

                Button(action: {
                    AccountActions.LogOut()
                }) {
                    HStack {
                        Image(systemName: "power")
                            .foregroundColor(.white)
                        Text("Log Out")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.Purple, lineWidth: 4)
                    )
                    .cornerRadius(10)
                }
                .padding(.horizontal, 10)

                Button(action: {
                    AccountActions.deleteAccount()
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.white)
                        Text("Delete Account")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 10)

                Spacer()
            }
        }
    }
}

  


struct EditProfileView: View {
    
    @State private var newCollege:String = ""
    @State private var newClass1:String = ""
    @State private var newClass2:String = ""
    @State private var newClass3:String = ""
    @State private var newClass4:String = ""
    @State private var newClass5:String = ""
    @State private var newClass6:String = ""
    @State private var newMajor:String = ""
    @State private var injectedClasses: [String] = []
    @StateObject var profileVM: UserProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    private func removeClass(at index: Int) {
        withAnimation {
            injectedClasses.remove(at: index)
        }
    }
    
    var body: some View {
        ZStack{
            Color.black
                .ignoresSafeArea()
            VStack{
                //College-------------------------------------------------------
                HStack(){
                    Text("College:")
                        .padding()
                        .background(Color.Purple)
                        .foregroundColor(.White)
                        .cornerRadius(5.0)
                        .padding(.bottom, 10)
                        .padding(.leading,10)
                        .font(.headline)
                    TextField("College", text: $newCollege)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(Color.Black)
                        .cornerRadius(5.0)
                        .padding(.bottom, 10)
                        .padding(.trailing,10)
                        .minimumScaleFactor(0.7)
                }
                //End College-------------------------------------------------------
                HStack(){
                    Text("Major:")
                        .padding()
                        .background(Color.Purple)
                        .foregroundColor(.White)
                        .cornerRadius(5.0)
                        .padding(.bottom, 10)
                        .padding(.leading,10)
                        .font(.headline)
                    TextField("Major", text: $newMajor)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(Color.Black)
                        .cornerRadius(5.0)
                        .padding(.bottom, 10)
                        .padding(.trailing,10)
                        .minimumScaleFactor(0.7)
                }
                //Add Class Button-------------------------------------------------------
                
                Button(action: {
                    // Handle settings action
                    if self.injectedClasses.count < 6{
                        //check if there are any blank inputs, do not allow new item if flag is true
                        
                        let hasBlankOrWhitespace = injectedClasses.contains { element in
                            let trimmedElement = element.trimmingCharacters(in: .whitespacesAndNewlines)
                            return trimmedElement.isEmpty
                        }
                        //we can add the element
                        if !hasBlankOrWhitespace{
                            self.injectedClasses.append("")
                        }
                        
                    }
                    
                    
                }) {
                    Text("Add Class")
                        .padding()
                        .background(Color.Purple)
                        .foregroundColor(.White)
                        .cornerRadius(5.0)
                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                        .font(.headline)
                }
               
               
                ScrollView {
                    VStack(spacing: 5) {
                        ForEach(injectedClasses.indices, id: \.self) { index in
                            
                            HStack {
                                Text("Class:")
                                    .padding()
                                    .background(Color.Purple)
                                    .foregroundColor(.White)
                                    .cornerRadius(5.0)
                                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                    .font(.headline)
                                
                                TextField("Class", text: Binding(
                                    get: {
                                        // Return the current value from your data source
                                        return injectedClasses[index]
                                    },
                                    set: { newValue in
                                        // Update the value in your data source
                                        // newValue is the new value entered in the text field
                                        // You may need to update the value in your 'injectedClasses' array
                                        injectedClasses[index] = newValue
                                    }
                                ))
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.black)
                                .cornerRadius(5.0)
                                .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                .minimumScaleFactor(0.7)
                                
                                // Delete class Button
                                Button(action: {
                                    if injectedClasses.count > 0{
                                        // Remove the corresponding element from the 'injectedClasses' array
                                        removeClass(at: index)
                                    }
                                    
                                    
                                }) {
                                    Image(systemName: "minus.circle")
                                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                        .foregroundColor(Color.White)
                                }
                            }
                        }
                        .background(Color.Gray)
                        .cornerRadius(15)
                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                    }
                }
                
                
                // Class Scroll View-------------------------------------------------------
                HStack{
                    Button(action: {
                        // Handle settings action
                        profileVM.handleEdit(college: newCollege, classes: injectedClasses)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Finalize Changes")
                            .padding()
                            .background(Color.Purple)
                            .foregroundColor(.White)
                            .cornerRadius(10)
                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                            .font(.headline)
                    }
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                            .padding()
                            .background(Color.Purple)
                            .foregroundColor(.White)
                            .cornerRadius(10)
                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                            .font(.headline)
                    }
                }
                
            }
        }
        .onAppear(){
            self.injectedClasses.removeAll()
            let classCount = profileVM.userDocument.Classes?.count ?? 0
            self.newCollege = profileVM.userDocument.College
            self.newMajor = profileVM.userDocument.Major
            
            for index in 0..<min(classCount, 6) {
                if let newClass = profileVM.userDocument.Classes?[index] {
                    self.injectedClasses.append(newClass)
                }
            }
            
            
        }
    }
}

struct UserProfilePostCell: View {
    let post:ClassPost
    @ObservedObject var viewModel: ClassPostsViewModel
    let profileVM: UserProfileViewModel
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
                Text("\(post.forClass)")
                    .foregroundColor(Color.White)
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            }
            // spacer to separate the post text and post voting
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
