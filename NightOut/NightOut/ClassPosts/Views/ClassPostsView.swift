
import SwiftUI
import Firebase
import Kingfisher
import UIKit


/**
 The `ClassPosts` view displays a list of class posts and allows users to interact with them, including viewing post details and adding new posts.

 This view depends on the `inAppViewVM` observable object, which manages the data and logic for the posts and user interactions.

 ## Properties

 - `inAppVM`: An environment object of type `inAppViewVM` that holds the view model for this view.
 - `colorScheme`: An environment variable representing the current color scheme.
 - `isShowingDetail`: A state variable to control whether the detail view is shown.
 - `isShowingSheet`: A state variable to control whether the add post sheet is shown.
 - `selectedPost`: A state variable to hold the selected post.
 - `addedPost`: A state variable to hold the text of the added post.
 - `isShowingClassSelector`: A state variable to control whether the class selector action sheet is shown.

 ## Initialization

 In the `init` block, the appearance of the navigation bar is customized to have an opaque background with a black color.

 ## Methods

 - `classButtons() -> [ActionSheet.Button]`: This method generates an array of `ActionSheet.Button` elements representing class options to be used in the class selector action sheet.

 ## Body

 The view's body consists of a `NavigationView` containing a `ScrollView` with a list of class posts displayed using a `LazyVStack`. The `NavigationView` has a `TitleDisplayMode` of `.inline`.

 ## Interactions

 - Users can change the selected class by tapping the class name on the navigation bar.
 - Users can add a new post by tapping the "Add Post" button.
 - Users can pull down the `ScrollView` to trigger a refresh and fetch the latest posts.

 ## Note

 This code assumes that `DetailView`, `PostCellView`, and `AddPostView` are SwiftUI views that handle post details, post cell representation, and adding a new post, respectively.
 */
struct ClassPosts: View {
    
    // MARK: - Properties
    
    // An environment object of type `inAppViewVM` that holds the view model for this view.
    @EnvironmentObject var inAppVM: inAppViewVM

    
    // An environment variable representing the current color scheme.
    @Environment(\.colorScheme) var colorScheme
    
    // A state variable to control whether the detail view is shown.
    @State private var isShowingDetail = false
    
    // A state variable to control whether the add post sheet is shown.
    @State private var isShowingSheet = false
    
    // A state variable to hold the selected post.
    @State private var selectedPost: ClassPost?
    
    // A state variable to hold the text of the added post.
    @State var addedPost: String = ""
    
    // A state variable to control whether the class selector action sheet is shown.
    @State private var isShowingClassSelector = false
    
    @State var showingReportPostSheet = false
    @State var showingReportPostActionSheet = false
    
    @State var showingBlockUserAlert:Bool = false
    
    @State private var userToBlock: UserToBlock?
    
   
    
    
    // MARK: - Initialization
    //sets the navigation bar appearance
    init() {
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.black)
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    // MARK: - Methods
    
    func classButtons() -> [ActionSheet.Button] {
        var buttons = inAppVM.userDoc.classes.map { curClass in
            ActionSheet.Button.default(Text(curClass)) {
                inAppVM.selectedClass = curClass
                DispatchQueue.main.async {
                    inAppVM.fetchFirst30PostsForClass(){ _ in}
                    //inAppVM.refreshPosts() { _ in }
                }
            }
        }
        buttons.append(.cancel())
        return buttons
    }
    
    // MARK: - Body
    
    var body: some View {
        
        // NavigationView provides a container for the main content with a navigation bar.
        NavigationView {
            ZStack {
                // ZStack is used to overlay the content and navigation bar items.
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        // Main content wrapped in a VStack to arrange the elements vertically.
                        
                        LazyVStack(spacing: 8) {
                            // LazyVStack is used to efficiently handle large numbers of posts.
                            
                             
                                // Iterate through the posts using ForEach and create NavigationLinks for each post.
                                ForEach(inAppVM.postsForClass.indices, id: \.self) { index in
                                    NavigationLink(destination: DetailView(selectedPost: inAppVM.postsForClass[index], isShowingDetail: $isShowingDetail, showingReportActionSheet: showingReportPostActionSheet)
                                        .environmentObject(inAppVM)) {
                                            // Each post is wrapped in a NavigationLink to navigate to the detail view.
                                            PostCellView(selectedPost: inAppVM.postsForClass[index], showReportActionSheet: $showingReportPostActionSheet, userToBlock: self.$userToBlock )
                                                .environmentObject(inAppVM)
                                                .onAppear {
                                                   
                                                    // Fetch more posts if the user scrolls to the end of the list.
                                                    if index == inAppVM.postsForClass.count - 1  && !inAppVM.isLastPage {
                                                        
                                                        
                                                        inAppVM.fetchNext30PostsForClass() { success in
                                                            print("There are now \(inAppVM.postsForClass.count) posts")
                                                        }
                                                    }
                                                    

                                                }
                                                .sheet(isPresented: $showingReportPostSheet){
                                                    ReportSheet(id: inAppVM.postsForClass[index].id,type:"Post")
                                                        .environmentObject(inAppVM)
                                                    
                                                }
                                                .actionSheet(isPresented: $showingReportPostActionSheet) {
                                                                    ActionSheet(title: Text("What would you like to do?"),
                                                                                buttons: [
                                                                                    .default(Text("Report Content"), action: {
                                                                                        showingReportPostSheet = true
                                                                                    }),
                                                                                    .destructive(Text("Block User"), action: {
                                                                                        // Trigger the alert for blocking the user
                                                                                        showingBlockUserAlert = true
                                                                                    }),
                                                                                    .cancel()
                                                                                ])
                                                                }
                                                .alert(isPresented: $showingBlockUserAlert) {
                                                    Alert(
                                                        title: Text("Block User"),
                                                        message: Text("Are you sure you want to block \(userToBlock?.name ?? "this user")?"),

                                                        primaryButton: .destructive(Text("Block")) {
                                                            guard let phoneNumberToBlock = userToBlock else {
                                                                print("No phone number provided to block.")
                                                                return
                                                            }
                                                            let num = phoneNumberToBlock.phoneNumber
                                                            inAppVM.handleBlockUser(userToBlockPhoneNumber: num)

                                                            userToBlock = nil
                                                            showingBlockUserAlert = false
                                                        },
                                                        secondaryButton: .cancel(Text("Cancel")) {
                                                            userToBlock = nil
                                                            showingBlockUserAlert = false
                                                        }
                                                    )
                                                }



                                        }
                                
                            }
                        }
                    }
                }
                
                .background(Color.Black)
                .refreshable {
                    // Enable pull-to-refresh to update the post list.
                    withAnimation {
                        //inAppVM.refreshPosts() { success in }
                        inAppVM.postsForClass = []
                        DispatchQueue.main.asyncAfter(deadline:.now() + 0.5){
                            inAppVM.fetchFirst30PostsForClass(){ _ in}
                        }
                       
                    }
                }
                
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading:
                                        // Show a button with the currently selected class.
                                    Button(action: {
                    self.isShowingClassSelector = true
                }) {
                    Text("\(inAppVM.selectedClass)")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                }
                    .actionSheet(isPresented: $isShowingClassSelector) {
                        // Show an action sheet to allow the user to change the selected class.
                        ActionSheet(title: Text("Change Class"), buttons: classButtons())
                    }
                )
                
                .toolbar {
                    // Show a button to add a new post.
                    Button {
                        self.isShowingSheet = true
                    } label: {
                        Text("Add Post")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    .cornerRadius(10)
                    .fullScreenCover(isPresented: $isShowingSheet) {
                        // Show the AddPostView in full screen when the button is pressed.
                        AddPostView()
                            .environmentObject(inAppVM)
                    }
                }
            }
        }
        .accentColor(.cyan) // Set the accent color for the view.
    }
    
    
    
    
    
    
    
    /// A view that displays a profile image from a given URL, or a default system image if the URL is nil or invalid.
    struct ProfileImageView: View {
        /// The URL string for the profile image.
        let urlString: String?
        
        /// The body of the view that defines its content and layout.
        var body: some View {
            if let urlString = urlString, let url = URL(string: urlString) {
                // If a valid URL is provided, use Kingfisher to load and display the profile image.
                KFImage(url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                // If the URL is nil or invalid, display a default system image of a person.
                Image(systemName: "person.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
        }
    }
    
}


