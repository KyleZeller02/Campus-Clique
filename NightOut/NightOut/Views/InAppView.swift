//
//  InAppView.swift
//  NightOut
//
//  Created by Kyle Zeller on 3/10/23.
//




import SwiftUI
import UIKit

struct InAppView: View {
   
    @StateObject var inAppVM: inAppViewVM = inAppViewVM()
  
    var body: some View {
        TabView {
            ClassPosts()
                .environmentObject(inAppVM)
                .tabItem {
                    Label("Posts", systemImage: "list.bullet")
                }
            
            UserProfileView()
                .environmentObject(inAppVM)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.Black)
            
            UITabBar.appearance().standardAppearance = appearance
        }
        .accentColor(.cyan)
    }


    
}



//struct InAppView_Previews: PreviewProvider {
//    static var previews: some View {
//        InAppView(viewRouter: ViewRouter())
//    }
//}
