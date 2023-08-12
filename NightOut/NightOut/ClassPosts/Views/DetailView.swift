//
//  DetailView.swift
//  Campus Clique
//
//  Created by Kyle Zeller on 6/5/23.
//

import SwiftUI
import Kingfisher

/// `DetailView` represents a detailed view of a specific post and its replies within an application.
/// This SwiftUI `View` displays a detailed version of a `ClassPost` object and allows users to add, view, or delete replies to the post.
struct DetailView: View {
    
    // MARK: - Properties
    
    /// Selected post to display in detail.
    let selectedPost: ClassPost

    /// View model used to fetch and handle data throughout the application.
    @EnvironmentObject var viewModel: inAppViewVM

    /// State variable controlling visibility of the reply text field.
    @State var addingReply: Bool = false

    /// State variable holding the text of the reply being added.
    @State var addedReply: String = ""

    /// Controls focus on the reply text field.
    @FocusState private var focused: Bool

    /// Controls the presentation of the detail view.
    @Binding var isShowingDetail: Bool
    
    @State var showingReportAlertReply: Bool = false

    /// Accesses the presentation mode of the view.
    @Environment(\.presentationMode) var presentationMode

    /// Manages the visibility of the delete post alert.
    @State private var showingDeleteAlert: Bool = false

    /// Manages the visibility of the delete reply alert.
    @State private var showingDeleteAlertReply: Bool = false

    /// Handles Firebase Firestore database interactions.
    let firebaseManager = FirestoreService()

    /// Stores the height of the reply text field.
    @State private var textFieldHeight: CGFloat = 0
    
    @State var showingReportReplyActionSheet:Bool = false
    
    @State var showingReportPostActionSheet: Bool
    @State var showingReportPostSheet:Bool = false

    // MARK: - Methods

    /// Sets focus on the reply text field.
    func setFocus() {
        focused = true
    }

    /// Hides the keyboard.
    private func hideKeyboard() {
        #if os(iOS)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }

    // MARK: - Body

    /// The main body of the DetailView.
    var body: some View {
        ZStack {
            // Full-screen background color
            Color.black.ignoresSafeArea(.all)

            // Main content area
            VStack(spacing: 0) {
                // The scroll view shows all the post and replies
                ScrollView(showsIndicators: false) {
                    // Post cell for the selected post
                    PostCellView(selectedPost:selectedPost,showingReportPostSheet: $showingReportPostSheet, showingReportPostActionSheet: $showingReportPostActionSheet )
                        .environmentObject(viewModel)

                    // Area for showing replies
                    if viewModel.curReplies.isEmpty {
                        Text("Replies will show up here")
                            .foregroundColor(.cyan)
                    } else {
                        // Reply headers and separators
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

                        // Area for displaying each reply
                        VStack {
                            LazyVStack(spacing: 8) {
                                ForEach(viewModel.curReplies, id: \.id) { reply in
                                    ReplyView(reply: .constant(reply), selectedPost: .constant(selectedPost), isAuthorReply: isAuthorReply(ofReply:), showingReportReplySheet: $showingReportAlertReply, showingReportReplyActionSheet: $showingReportReplyActionSheet)
                                        .environmentObject(viewModel)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                        .cornerRadius(10)
                                }
                            }
                            .background(Color.black)
                        }
                    }
                }
                // Handling taps outside the reply area
                .onTapGesture {
                    hideKeyboard()
                    self.addingReply = false
                }
                // Navigation bar for adding replies
                .navigationBarItems(trailing: Button(action: {
                    self.addingReply = true
                }) {
                    Text("Add Reply")
                        .foregroundColor(.white)
                        .font(.title2)
                })

                // Reply text field area
                /// This block of code is responsible for creating and managing the TextField used for adding replies to a post.
                /// It gets rendered if `addingReply` is set to `true`.
                if addingReply {
                    // We use a ZStack here to allow us to layer our TextField over any other views.
                    ZStack{
                        VStack {
                            // This is the TextField where users will input their replies.
                            TextField("reply to \(selectedPost.firstName) \(selectedPost.lastName)", text: $addedReply, axis:.vertical)
                                // The padding around the TextField. It's set to be larger on the trailing side for aesthetic balance.
                                .padding([.top, .bottom, .leading])
                                .padding(.trailing, 70)
                                // The background of the TextField. We set an opacity to allow underlying views to be slightly visible.
                                .background(Color.gray.opacity(0.2))
                                // The TextField's corners are rounded for aesthetic purposes.
                                .cornerRadius(8)
                                // The color of the text that the user types.
                                .foregroundColor(.white)
                                // The color of the TextField's cursor and selection highlight.
                                .accentColor(.cyan)
                                // The capitalization of the TextField's text. Here, the start of each sentence is capitalized.
                                .autocapitalization(.sentences)
                                // We disable autocorrection in this TextField.
                                .disableAutocorrection(false)
                                // We focus this TextField when the reply button is pressed.
                                .focused($focused, equals: true)
                                .onAppear {
                                    // As soon as this TextField appears, we set the focus to it.
                                    setFocus()
                                }
                                .onChange(of: addedReply) { newValue in
                                    // We limit the character count of the reply to 300. If a user types more than this, we truncate the text.
                                    if newValue.count > 300 {
                                        addedReply = String(newValue.prefix(300))
                                    }
                                }
                                // An overlay is added to the TextField which includes a button for submitting the reply.
                                .overlay(
                                    HStack {
                                        Spacer()
                                        // The action of this button is to add the reply to the post and then clear the TextField.
                                        Button(action: {
                                            let reply = addedReply.trimmingCharacters(in: .whitespacesAndNewlines)
                                            // We check if the reply is not empty before attempting to add it.
                                            if !reply.isEmpty {
                                                viewModel.addReply(reply, to: selectedPost)
                                            }
                                            // The TextField is cleared and closed after a reply is added.
                                            self.addedReply = ""
                                            self.addingReply = false
                                        }) {
                                            // The button is represented by an image of an upward-pointing circle.
                                            Image(systemName: "arrow.up.circle")
                                                .foregroundColor(.white)
                                                .font(.system(size: 30))
                                                .padding(.horizontal, 20)
                                        }
                                    }
                                )
                                .padding(.top,0)
                        }
                        .padding(.bottom,10)
                        .padding(.top,10)
                    }
                }

            }
            .padding(.top,0)
            // Handle focus changes for reply text field
            .onChange(of: focused) { newValue in
                if !newValue {
                    hideKeyboard()
                }
            }
            // Fetch replies when the view appears
            .onAppear {
                viewModel.fetchReplies(forPost: selectedPost)
            }
            // Clear replies when the view disappears
            .onDisappear() {
                viewModel.curReplies.removeAll()
            }
        }
    }
}





