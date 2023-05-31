import SwiftUI
import Firebase

struct Settings: View {
    @Binding var isPresented: Bool
    @State var name: String = ""
    @State var college: String = ""
    @State var major: String = ""
    @State var classes: [String] = Array(repeating: "", count: 6)
    let backgroundColor = Color.black
    let primaryColor = Color.purple
    let textFieldColor = Color.white.opacity(0.1)
    @StateObject var viewRouter: ViewRouter

    var body: some View {
        ZStack{
            backgroundColor
                .ignoresSafeArea()
            
            VStack{
                VStack {
                    Text("Edit Profile")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(primaryColor)
                        .cornerRadius(5.0)
                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                    
                    TextField("Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                    
                    TextField("College", text: $college)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)

                    TextField("Major", text: $major)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Classes")
                            .font(.headline)
                            .foregroundColor(primaryColor)

                        ForEach(0..<classes.count, id: \.self) { index in
                            TextField("Class \(index + 1)", text: $classes[index])
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 10)
                }
                Spacer()

                //Logout and Delete account Buttons
                HStack{
                    Button(action: {
                        
                    }) {
                        Text("Log Out")
                            .font(.headline)
                            .padding()
                            .background(primaryColor)
                            .foregroundColor(.white)
                            .cornerRadius(5.0)
                    }
                    .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))

                    Button(action: {
                        AccountActions.deleteAccount()
                    }) {
                        Text("Delete My Account")
                            .font(.headline)
                            .padding()
                            .background(primaryColor)
                            .foregroundColor(.white)
                            .cornerRadius(5.0)
                    }
                    .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                }
            }
        }
        .navigationBarItems(leading: Button("Close") {
            self.isPresented = false
        })
        .navigationBarTitle("Edit Profile", displayMode: .inline)
    }
}

struct AccountActions{
    static func LogOut(){
        do {
            try Auth.auth().signOut()
            UserManager.shared.currentUser = nil
            
           
            // User has been successfully logged out
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
        
    }
    
    static func deleteAccount(){
        //first signout
        LogOut()
        //delete account
        let user = Auth.auth().currentUser
        user?.delete { error in
            if let error = error {
                print("Error deleting account: \(error.localizedDescription)")
            } else {
                // Account has been successfully deleted
            }
        }
    }
}
