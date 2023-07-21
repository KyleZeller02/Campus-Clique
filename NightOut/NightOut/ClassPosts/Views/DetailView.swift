//
//  DetailView.swift
//  Campus Clique
//
//  Created by Kyle Zeller on 6/5/23.
//

import SwiftUI
import Kingfisher

struct DetailView: View{
    let selectedPost: ClassPost
    @EnvironmentObject var viewModel: inAppViewVM
    @State var addingReply: Bool = false
    @State var addedReply: String = ""
    @FocusState private var focused:Bool
    @Binding var isShowingDetail: Bool
    @Environment (\.presentationMode) var presentationMode
    @State private  var showingDeleteAlert: Bool = false
    @State private  var showingDeleteAlertReply: Bool = false
    let firebaseManager = FirestoreService()
    func setFocus() {
        focused = true
    }
    private func hideKeyboard() {
#if os(iOS)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
#endif
    }
    @State private var textFieldHeight: CGFloat = 0
    
    
    
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                
                
                ScrollView(showsIndicators: false) {
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
                                Text("\(selectedPost.firstName) \(selectedPost.lastName)")
                                    .padding(10)
                                    .foregroundColor(.cyan)
                                    .cornerRadius(10.0)
                                Spacer()
                                Text("\(convertEpochTimeToDate(epochTime: selectedPost.datePosted))")
                                    .foregroundColor(Color.white)
                                    .padding(10)
                            }
                            .padding(.top, 10)
                            .padding(.leading, 5)
                            
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
                                        firebaseManager.fetchPost(byId: selectedPost.id){p,error  in
                                            if let p = p{
                                                selectedPost.usersLiked = p.usersLiked
                                                selectedPost.usersDisliked = p.usersDisliked
                                                selectedPost.votes = p.votes
                                            }
                                            
                                        }
                                    }
                                }) {
                                    Image(systemName: "chevron.up")
                                }
                                .disabled(viewModel.isVotingInProgress)
                                .padding(10)
                                .buttonStyle(BorderlessButtonStyle())
                                .foregroundColor(selectedPost.usersLiked.contains(viewModel.userDoc.PhoneNumber ) ? Color.green : Color.gray)
                               
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.cyan, lineWidth: 1)
                                    
                                )
                                
                                // downvote button
                                Button(action: {
                                    DispatchQueue.main.async {
                                        viewModel.isVotingInProgress = true
                                        viewModel.handleVoteOnPost(UpOrDown: VoteType.down, onPost: selectedPost)
                                        // Custom code to execute when the downvote button is pressed
                                        // You can add your own logic here
                                        
                                        firebaseManager.fetchPost(byId: selectedPost.id){p,error  in
                                            if let p = p{
                                                selectedPost.usersLiked = p.usersLiked
                                                selectedPost.usersDisliked = p.usersDisliked
                                                selectedPost.votes = p.votes
                                                viewModel.isVotingInProgress = false
                                            }
                                            
                                        }
                                    }
                                }) {
                                    Image(systemName: "chevron.down")
                                }
                                .padding(10)
                                .buttonStyle(BorderlessButtonStyle())
                                .foregroundColor(selectedPost.usersDisliked.contains(viewModel.userDoc.PhoneNumber) ? Color.red : Color.gray)
                                .disabled(viewModel.isVotingInProgress)
                               
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.cyan, lineWidth: 1)
                                    
                                )
                                
                                
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
                                            presentationMode.wrappedValue.dismiss()
                                        },
                                        secondaryButton: .cancel()
                                    )
                                }
                                .opacity(isAuthorPost(ofPost: selectedPost) ? 1.0 : 0.0) // Adjusts the opacity based on whether the post is authored by the current user
                                .disabled(!isAuthorPost(ofPost: selectedPost)) // Disables the button for posts not authored by the current user
                            }
                            .padding(.leading, 10)
                            .padding(.trailing, 10)
                            .cornerRadius(15)
                        }
                        .background(Color.Gray)
                        
                        .padding(.top, 1)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .cornerRadius(10)
                    
                    if viewModel.curReplies.isEmpty {
                        Text("Replies will show up here")
                            .foregroundColor(.cyan)
                    } else {
                        VStack(spacing: 5) {
                            Divider()
                                .background(Color.gray)
                                .padding(.vertical, 5)
                            HStack {
                                Text("Replies")
                                    .foregroundColor(.cyan)
                                    .multilineTextAlignment(.leading)
                                    .font(.title2)
                                Spacer()
                            }
                            
                        }
                        .padding(.leading, 10)
                    }
                    
                    VStack {
                        
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.curReplies, id: \.id) { reply in
                                ReplyView(reply: .constant(reply), selectedPost: .constant(selectedPost), isAuthorReply: isAuthorReply(ofReply:))
                                    .environmentObject(viewModel)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                    .cornerRadius(10)
                            }
                        }
                        .background(Color.black)
                    }
                }
                .onTapGesture {
                    hideKeyboard()
                    self.addingReply = false
                }
                
                .navigationBarItems(trailing: Button(action: {
                    self.addingReply = true
                }) {
                    Text("Add Reply")
                        .foregroundColor(.white)
                        .font(.title2)
                })
                
                
                if addingReply {
                    
                        ZStack{
                            
                                VStack {
                                    if #available(iOS 16.0, *) {
                                        TextField("reply to \(selectedPost.firstName) \(selectedPost.lastName)", text: $addedReply,axis:.vertical)
                                            .padding([.top, .bottom, .leading])
                                            .padding(.trailing, 35)  // Increase this number if needed
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(8)
                                            .foregroundColor(.white)
                                            .accentColor(.cyan)
                                            .autocapitalization(.sentences)
                                            .disableAutocorrection(false)
                                            .focused($focused, equals: true)
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
                                                            viewModel.addReply(reply, to: selectedPost) { result in
                                                                switch result {
                                                                case .success(let reply):
                                                                    viewModel.curReplies.append(reply)
                                                                case .failure(let error):
                                                                    // handle error
                                                                    break
                                                                }
                                                            }
                                                        }
                                                        self.addedReply = ""
                                                        self.addingReply = false
                                                    }) {
                                                        Image(systemName: "arrow.up.circle")
                                                            .foregroundColor(.white)
                                                            .font(.system(size: 30))
                                                            .padding(.horizontal, 10)
                                                    }
                                                }
                                            )
                                            
                                            .padding(.top,0)


                                    } else {
                                        // Fallback on earlier versions
                                        TextField("reply to \(selectedPost.firstName) \(selectedPost.lastName)", text: $addedReply)
                                            .padding([.top, .bottom, .leading])
                                            .padding(.trailing, 70)  // Increase this number if needed
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(8)
                                            .foregroundColor(.white)
                                            .accentColor(.cyan)
                                            .autocapitalization(.sentences)
                                            .disableAutocorrection(false)
                                            .focused($focused, equals: true)
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
                                                            viewModel.addReply(reply, to: selectedPost) { result in
                                                                switch result {
                                                                case .success(let reply):
                                                                    viewModel.curReplies.append(reply)
                                                                case .failure(let error):
                                                                    // handle error
                                                                    break
                                                                }
                                                            }
                                                        }
                                                        self.addedReply = ""
                                                        self.addingReply = false
                                                    }) {
                                                        Image(systemName: "arrow.up.circle")
                                                            .foregroundColor(.white)
                                                            .font(.system(size: 30))
                                                            .padding(.horizontal, 20)
                                                    }
                                                }
                                            )
                                            
                                            .padding(.top,0)
                                    }
                                }
                                .padding(.bottom,10)
                                .padding(.top,10)
                            
                        }
                        
                       
                }
                

                
                
            }
            .padding(.top,0)
            
            .onChange(of: focused) { newValue in
                if !newValue {
                    hideKeyboard()
                }
            }
            .onAppear {
                viewModel.fetchReplies(forPost: selectedPost)
            }
            .onDisappear(){
                viewModel.curReplies.removeAll()
            }
        }
    }
    
    
}

//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView(selectedPost)
//    }
//}
struct ReplyView: View {
    @Binding var reply: Reply
    @Binding var selectedPost: ClassPost
    @EnvironmentObject var viewModel: inAppViewVM
    var isAuthorReply: (Reply) -> Bool  // assuming you have this function defined somewhere
    
    @State private var showingDeleteAlertReply = false
    
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
    
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                // post author
                HStack {
                    if let urlString = reply.profilePicURL, let url = URL(string: urlString) {
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
                    Text("\(reply.firstName) \(reply.lastName)")
                        .padding(10)
                        .foregroundColor(.cyan)
                        .cornerRadius(10.0)
                    Spacer()
                    Text("\(convertEpochTimeToDate(epochTime: reply.DatePosted))")
                        .foregroundColor(Color.white)
                        .padding(10)
                }
                .padding(.top,10)
                .padding(.leading,5)
                
                // post body with rounded background color
                Text("\(reply.replyBody)")
                    .padding(10)
                    .foregroundColor(Color.white)
                    .cornerRadius(5.0)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading) // Push text all the way to the left
                
                // vote buttons
                HStack {
                    // votes on the post
                    Text("\(reply.votes)")
                        .foregroundColor(.cyan)
                    
                    
                    // upvote button
                    Button(action: {
                        DispatchQueue.main.async {
                            viewModel.handleVoteOnReply(.up, onPost: selectedPost, onReply: reply)
                        }
                    }) {
                        Image(systemName: "chevron.up")
                    }
                    .padding(10)
                    .buttonStyle(BorderlessButtonStyle())
                    .foregroundColor(reply.UsersLiked.contains(viewModel.userDoc.PhoneNumber ) ? Color.green : Color.gray)
                    
                    .cornerRadius(10)
                    .disabled(viewModel.isVotingInProgress)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.cyan, lineWidth: 1)
                        
                    )
                    
                    // downvote button
                    Button(action: {
                        
                        DispatchQueue.main.async {
                            viewModel.handleVoteOnReply(.down, onPost: selectedPost, onReply: reply)
                        }
                    }) {
                        Image(systemName: "chevron.down")
                    }
                    .padding(10)
                    .buttonStyle(BorderlessButtonStyle())
                    .foregroundColor(reply.UserDownVotes.contains(viewModel.userDoc.PhoneNumber ) ? Color.red : Color.gray)
                    
                    .cornerRadius(10)
                    .disabled(viewModel.isVotingInProgress)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.cyan, lineWidth: 1)
                        
                    )
                    
                    
                    Spacer()
                    
                    Button(action: {
                        showingDeleteAlertReply = true
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
                    .opacity(isAuthorReply(reply) ? 1.0 : 0.0)  // Adjusts the opacity based on whether the post is authored by the current user
                    .disabled(!isAuthorReply(reply))  // Disables the button for posts not authored by the current user
                }
                .padding(.leading,10)
                .padding(.trailing,10)
            }
            .background(Color.Gray)
            
            .padding(.top,1)
        }
    }
}



