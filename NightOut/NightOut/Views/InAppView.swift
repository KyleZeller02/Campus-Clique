//
//  InAppView.swift
//  NightOut
//
//  Created by Kyle Zeller on 3/10/23.
//

import SwiftUI

    
struct InAppView: View {
    @StateObject var viewRouter: ViewRouter
    
    
    
    var body: some View {
        TabView() {
            UserProfileView(viewRouter: viewRouter)
                .tabItem {
                    Label("Profile", systemImage: "person")
                        .font(.title)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 5)
                }
                
            
            ClassPosts(viewRouter: viewRouter)
                .tabItem {
                    Label("Class Posts", systemImage: "list.bullet")
                        .font(.title)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 5)
                }
                
        }
        .tint(Color.Purple)
      
    }
}


    
//struct InAppView_Previews: PreviewProvider {
//    static var previews: some View {
//        InAppView(viewRouter: ViewRouter())
//    }
//}
