//
//  InAppView.swift
//  NightOut
//
//  Created by Kyle Zeller on 3/10/23.
//

import SwiftUI

    
struct InAppView: View {
    @StateObject var viewRouter: ViewRouter
    
    @State private var selectedTab: Tab = .profile

        enum Tab {
            case profile
            case classPosts
        }

        var body: some View {
            TabView(selection: $selectedTab) {
                UserProfileView(viewRouter: viewRouter)
                    .tabItem() {
                        Image(systemName: "person")
                        Text("Profile")
                            .font(.title)
                            .lineLimit(1) // Set maximum number of lines
                            .minimumScaleFactor(0.5) // Set minimum scale factor for text
                            .padding(.horizontal, 5)
                    }
                    .tag(Tab.profile)
                
                ClassPosts(viewRouter: viewRouter)
                    .tabItem() {
                        Image(systemName: "list.bullet")
                        Text("Class Posts")
                            .font(.title)
                            .lineLimit(1) // Set maximum number of lines
                            .minimumScaleFactor(0.5) // Set minimum scale factor for text
                            .padding(.horizontal, 5)
                    }
                    .tag(Tab.classPosts)
            }
            .accentColor(Color.Purple) // Set accent color to clear color
            .onAppear {
                // Set the tab bar background color
                UITabBar.appearance().backgroundColor = UIColor(Color.gray)
            }
            // Set foreground color of non-selected items
            .foregroundColor(selectedTab == .profile ? .white : .black)
        }
}

    
struct InAppView_Previews: PreviewProvider {
    static var previews: some View {
        InAppView(viewRouter: ViewRouter())
    }
}
