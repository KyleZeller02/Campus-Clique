//  InAppView.swift
//  NightOut
//
//  Created by Kyle Zeller on 3/10/23.
//
// This SwiftUI view represents the main user interface after the app launch.

import SwiftUI
import UIKit

// The InAppView is the main view that holds the tabbed view interface.
struct InAppView: View {
    // We declare inAppVM as a StateObject since it's a reference type and we're
    // initializing it here, which means this view owns this object.
    @StateObject var inAppVM = inAppViewVM()
  
    var body: some View {
        // TabView represents the main app navigation.
        TabView {
            // ClassPosts view to display class-related posts.
            ClassPosts()
                .environmentObject(inAppVM)
                .tabItem {
                    Label("Posts", systemImage: "list.bullet")
                }

            // UserProfileView to display the user's profile.
            UserProfileView()
                .environmentObject(inAppVM)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .onAppear {
            // Customize the UITabBar appearance when the view appears.
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.Black)
            
            UITabBar.appearance().standardAppearance = appearance
        }
        .accentColor(.cyan)
    }
}

 //Preview is commented out since ViewRouter object is not provided.
struct InAppView_Previews: PreviewProvider {
    static var previews: some View {
        InAppView()
    }
}
