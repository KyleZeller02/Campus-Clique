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
        TabView{
            UserProfileView(viewRouter: viewRouter)
                .tabItem(){
                    
                    Button {
                        viewRouter.CurrentViewState = .UserProfileView
                    } label: {
                        Image(systemName: "person")
                        Text("profile")
                    }

                }
            ClassPosts(viewRouter: viewRouter)
                .tabItem(){
                    
                    Button {
                        viewRouter.CurrentViewState = .ClassPosts
                    } label: {
                        Image(systemName: "list.bullet")
                        Text("Class Posts")
                    }

                }
        }
    }
}

    
struct InAppView_Previews: PreviewProvider {
    static var previews: some View {
        InAppView(viewRouter: ViewRouter())
    }
}
