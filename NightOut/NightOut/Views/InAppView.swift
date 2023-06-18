//
//  InAppView.swift
//  NightOut
//
//  Created by Kyle Zeller on 3/10/23.
//




import SwiftUI
import UIKit

struct InAppView: View {
    @StateObject var viewRouter: ViewRouter
    @StateObject var inAppVM: inAppViewVM = inAppViewVM()
    @State private var tabSelection: TabBarItem = .posts
    
  


    

    var body: some View {
        CustomTabBarContainerView(selection: $tabSelection) {
            ClassPosts(viewRouter: viewRouter)
                .environmentObject(inAppVM)
                .tabBarItem(tab: .posts, selection: $tabSelection)
                .tag(1)
            UserProfileView(viewRouter: viewRouter)
                .environmentObject(inAppVM)
                .tabBarItem(tab: .profile, selection: $tabSelection)
                .tag(0)
        }
    }
}



//struct InAppView_Previews: PreviewProvider {
//    static var previews: some View {
//        InAppView(viewRouter: ViewRouter())
//    }
//}
