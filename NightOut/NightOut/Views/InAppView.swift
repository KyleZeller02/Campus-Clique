//
//  InAppView.swift
//  NightOut
//
//  Created by Kyle Zeller on 3/10/23.
//

import SwiftUI

    
import SwiftUI

struct InAppView: View {
    @StateObject var viewRouter: ViewRouter
    @StateObject  var userProfile:UserProfileViewModel = UserProfileViewModel()
    @StateObject var posts: ClassPostsViewModel = ClassPostsViewModel()

    // Define your custom accent color
    let customAccentColor = Color(red: 75 / 255, green: 175 / 255, blue: 210 / 255)

    var body: some View {
        TabView() {
            UserProfileView(viewRouter: viewRouter)
                .environmentObject(userProfile)
                .environmentObject(posts)
                .tabItem {
                    VStack {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                }
                .tag(0)

            ClassPosts(viewRouter: viewRouter)
                .environmentObject(userProfile)
                .environmentObject(posts)
                .tabItem {
                    VStack {
                        Image(systemName: "list.bullet")
                        Text("Posts")
                    }
                }
                .tag(1)
        }
        .accentColor(customAccentColor) // use your custom accent color
        .onAppear {
            // UIColor can also be customized
            let uiColor = UIColor(red: 75 / 255, green: 175 / 255, blue: 210 / 255, alpha: 1.0)
            UITabBar.appearance().isTranslucent = true
            UITabBar.appearance().backgroundImage = UIImage()
            UITabBar.appearance().shadowImage = UIImage()
            UITabBar.appearance().unselectedItemTintColor = UIColor.systemGray3
            UITabBar.appearance().tintColor = uiColor
        }
    }
}

//struct InAppView_Previews: PreviewProvider {
//    static var previews: some View {
//        InAppView(viewRouter: ViewRouter())
//    }
//}
