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
    @StateObject var posts: ClassPostsViewModel
    //EditProfileView Variables
    @State private var showingEditProfile: Bool = false
    
    
    
    var body: some View {
        NavigationView{
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack {
                    
                    VStack(spacing: 0) {
                        HStack {
                            
                            //User Name---------------------------------------------------------------------
                            Text("\(profileVM.userDocument.FullName)")
                                .font(.headline)
                                .padding(10)
                                .background(Color.indigo)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                            //-------------------------------------------------------------------------------
                            Spacer()
                            //Settings-----------------------------------------------------------------------
                            HStack {
                                Button(action: {
                                    //                                    // Handle settings action
                                    //                                    let firebaseAuth = Auth.auth()
                                    //                                    do{
                                    //                                        try firebaseAuth.signOut()
                                    //
                                    //                                    }
                                    //                                    catch let singoutError as NSError{
                                    //                                        print("Error Signing out: \(singoutError)")
                                    //                                    }
                                    //                                    viewRouter.CurrentViewState = .LoginView
                                }) {
                                    Text("Settings")
                                        .font(.headline)
                                        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                                        .background(Color.indigo)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                
                                Button(action: {
                                    // Handle edit profile action
                                    self.showingEditProfile = true
                                }) {
                                    Text("Edit Profile")
                                        .font(.headline)
                                        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                                        .background(Color.indigo)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                //EDIT PROFILEVIEW-----------------------------------------------------------------
                                .fullScreenCover(isPresented: $showingEditProfile){
                                    
                                    EditProfileView(profileVM: profileVM)
                                }
                                //END EDIT PROFILEVIEW-----------------------------------------------------------------
                            }
                            
                            
                            
                        }
                        .frame(minHeight: 70)
                        .background(Color.Gray)
                        
                        //College ----------------------------------------------------------------------------
                        HStack {
                            
                            Text("My College:")
                                .font(.headline)
                                .padding(10)
                                .background(Color.indigo)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                            
                            
                            Spacer()
                            Text("\(profileVM.userDocument.College)")
                                .font(.headline)
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(Color.white)
                                .cornerRadius(10)
                                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                            
                        }
                        .frame(minHeight: 70)
                        .background(Color.Gray)
                        //----------------------------------------------------------------------------
                        
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    
                    
                    //----------------------------------------------------------------------Classes
                    HStack {
                        Text("My Classes")
                            .font(.headline)
                            .padding(10)
                            .background(Color.indigo)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        
                        VStack(spacing: 0) {
                            let classesCount = profileVM.userDocument.Classes?.count ?? 0
                            
                            VStack(spacing: 0) {
                                HStack(spacing: 0) {
                                    if classesCount > 0 {
                                        Text("\(profileVM.userDocument.Classes?[0] ?? "")")
                                            .modifier(ClassTextModifier())
                                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10))
                                    }
                                    if classesCount > 1 {
                                        Text("\(profileVM.userDocument.Classes?[1] ?? "")")
                                            .modifier(ClassTextModifier())
                                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10))
                                    }
                                    if classesCount > 2 {
                                        Text("\(profileVM.userDocument.Classes?[2] ?? "")")
                                            .modifier(ClassTextModifier())
                                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10))
                                    }
                                }
                                .padding(5)
                                
                                VStack(spacing: 0) {
                                    HStack(spacing: 0) {
                                        if classesCount > 3 {
                                            Text("\(profileVM.userDocument.Classes?[3] ?? "")")
                                                .modifier(ClassTextModifier())
                                                .padding(EdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10))
                                        }
                                        if classesCount > 4 {
                                            Text("\(profileVM.userDocument.Classes?[4] ?? "")")
                                                .modifier(ClassTextModifier())
                                                .padding(EdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10))
                                        }
                                        if classesCount > 5 {
                                            Text("\(profileVM.userDocument.Classes?[5] ?? "")")
                                                .modifier(ClassTextModifier())
                                                .padding(EdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10))
                                        }
                                    }
                                    .padding(5)
                                }
                            }
                        }
                        
                        
                        
                        Spacer()
                    }
                    .frame(minHeight: 70)
                    .background(Color.Gray)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Text("My Posts")
                        .font(.headline)
                        .padding(10)
                        .background(Color.gray)
                        .foregroundColor(Color.White)
                        .cornerRadius(10)
                    
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(posts.userPosts) { post in
                                NavigationLink(destination: DetailView(selectedPost: post, viewModel: posts)) {
                                    
                                    UserProfilePostCell(post: post, viewModel: posts, profileVM: profileVM)
                                    
                                }
                                .simultaneousGesture(TapGesture().onEnded{
                                    profileVM.getReplies(forPost: post, inClass: post.forClass) { returnedReplies in
                                        post.replies = returnedReplies
                                    }
                                })
                            }
                        }
                        
                        
                        
                    }
                    .background(Color.Black)
                    .refreshable {
                        profileVM.refresh()
                        
                    }
                }
                
            }
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
            .foregroundColor(Color.white)
            .cornerRadius(10)
        
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
                        .background(Color.indigo)
                        .foregroundColor(.white)
                        .cornerRadius(5.0)
                        .padding(.bottom, 10)
                        .padding(.leading,10)
                        .font(.headline)
                    TextField("College", text: $newCollege)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(Color.black)
                        .cornerRadius(5.0)
                        .padding(.bottom, 10)
                        .padding(.trailing,10)
                        .minimumScaleFactor(0.7)
                }
                //End College-------------------------------------------------------
                
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
                        .background(Color.indigo)
                        .foregroundColor(.white)
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
                                    .background(Color.indigo)
                                    .foregroundColor(.white)
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
                                        .foregroundColor(Color.white)
                                }
                            }
                        }
                        .background(Color.gray)
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
                            .background(Color.indigo)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                            .font(.headline)
                    }
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                            .padding()
                            .background(Color.indigo)
                            .foregroundColor(.white)
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
    var body: some View {
        VStack(alignment: .leading) {
            // post author
            HStack {
                Text("\(post.postAuthor)")
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                    .background(Color.Purple)
                    .foregroundColor(Color.White)
                    .font(.headline)
                    .cornerRadius(10.0)
                Spacer()
                Text("\(post.forClass)")
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
            
            HStack() {
                // votes on the post
                Text("\(post.votes)")
                // upvote button
                Button(action: {
                    DispatchQueue.main.async {
                        viewModel.handleVoteOnPost(UpOrDown: "up", onPost: post)
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
                        viewModel.handleVoteOnPost(UpOrDown: "down", onPost: post)
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
