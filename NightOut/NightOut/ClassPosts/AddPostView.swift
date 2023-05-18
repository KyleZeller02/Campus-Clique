//
//  AddPostView.swift
//  NightOut
//
//  Created by Kyle Zeller on 5/17/23.
//

import SwiftUI

struct AddPostView: View {
    @State private var isShowingAddPostSheet:Bool = false
    var body: some View {
        ZStack{
            Color.Black
                .ignoresSafeArea()
            Button("ShowSheet") {
                self.isShowingAddPostSheet = true
            }
        }
        .fullScreenCover(isPresented: $isShowingAddPostSheet){
            ZStack{
               
            }
           
        }
       
    }
}

struct AddPostView_Previews: PreviewProvider {
    static var previews: some View {
        AddPostView()
    }
}
