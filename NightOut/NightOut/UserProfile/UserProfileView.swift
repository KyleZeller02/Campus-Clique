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
    @EnvironmentObject var profileVM: UserProfileViewModel
    @EnvironmentObject var posts: ClassPostsViewModel
    @StateObject var userManager = UserManager.shared
    
    //EditProfileView Variables
    @State private var showingEditProfile: Bool = false
    @State private var showingCover:Bool = false
    
    
    
    var body: some View {
        NavigationView{
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack {
                    VStack(alignment: .leading, spacing: 20){
                        
                        Text("\(userManager.currentUser?.College ?? "")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Studying \(userManager.currentUser?.Major ?? "")")
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
                            ForEach(profileVM.usersPosts) { post in
                                NavigationLink(destination: DetailView(selectedPost: post, viewModel: posts)) {
                                    UserProfilePostCell(post: post, profileVM: profileVM)
                                }
                            }
                        }
                    }
                    .background(Color.black)
                    
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Group {
                            if let uiImage = UserManager.shared.currentUser?.profilePicture {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(Circle())
                                    .frame(width: 100, height: 100)
                            } else {
                                // Default image in case profilePicture is nil
                                Image("defaultProfile")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(Circle())
                                    .frame(width: 40, height: 40)
                            }
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        Text("\(UserManager.shared.currentUser?.FullName ?? "")")
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
            SettingsView(viewRouter: viewRouter, profileVM: profileVM)
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
    @StateObject var viewRouter: ViewRouter
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
                    viewRouter.CurrentViewState = .LoginView
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
                    viewRouter.CurrentViewState = .LoginView
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
            Color.Black
                .ignoresSafeArea()
            VStack{
                //College-------------------------------------------------------
                HStack(){
                    Text("College:")
                        .font(.headline)
                        .foregroundColor(Color.white)
                        .padding(.horizontal)
                    Spacer()
                    TextField("College", text: $newCollege)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.Purple, lineWidth: 1))
                }
                .padding(.vertical)
                .background(Color.Purple)
                .cornerRadius(10)
                .padding(.horizontal)
                
                //End College-------------------------------------------------------
                //Major-------------------------------------------------------
                HStack(){
                    Text("Major:")
                        .font(.headline)
                        .foregroundColor(Color.white)
                        .padding(.horizontal)
                    Spacer()
                    TextField("Major", text: $newMajor)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                    
                }
                .padding(.vertical)
                .background(Color.Purple)
                .cornerRadius(10)
                .padding(.horizontal)
                //End Major-------------------------------------------------------
                
                //Add Class Button-------------------------------------------------------
                Button(action: {
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
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.Purple)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(injectedClasses.indices, id: \.self) { index in
                            HStack {
                                TextField("Class", text: Binding(
                                    get: {
                                        return injectedClasses[index]
                                    },
                                    set: { newValue in
                                        injectedClasses[index] = newValue
                                    }
                                ))
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .foregroundColor(.black)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.Purple, lineWidth: 1))
                                
                                // Delete class Button
                                Button(action: {
                                    if injectedClasses.count > 0{
                                        removeClass(at: index)
                                    }
                                }) {
                                    Image(systemName: "minus.circle")
                                        .foregroundColor(Color.Purple)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
                
                // Buttons-------------------------------------------------------
                HStack{
                    Button(action: {
                        let injectedClasses = injectedClasses.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                        UserManager.shared.handleEdit(college: newCollege, classes: injectedClasses)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Finalize Changes")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.Purple)
                            .cornerRadius(10)
                    }
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.Purple)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                
            }
            .padding(.top)
        }
        .onAppear(){
            self.injectedClasses.removeAll()
            let classCount = UserManager.shared.currentUser?.Classes.count ?? 0
            self.newCollege = UserManager.shared.currentUser?.College ?? ""
            self.newMajor = UserManager.shared.currentUser?.Major ?? ""
            
            for index in 0..<min(classCount, 6) {
                
                if let newClass = UserManager.shared.currentUser?.Classes[index] {
                    self.injectedClasses.append(newClass)
                }
            }
            
            
        }
    }
}

struct UserProfilePostCell: View {
    let post:ClassPost
    
    
    @ObservedObject var profileVM: UserProfileViewModel
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
                            profileVM.deletePostAndReplies(post)
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
