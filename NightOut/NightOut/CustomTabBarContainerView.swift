//
//  CustomTabBarContainerView.swift
//  CustomTabBar
//
//  Created by Kyle Zeller on 6/7/23.
//

import SwiftUI



struct CustomTabBarContainerView<Content:View>: View {
    let content: Content
    @Binding var selection : TabBarItem
    @State private var tabs: [TabBarItem] = []
    
    init(selection: Binding<TabBarItem>, @ViewBuilder content: () -> Content)
    {
        self._selection = selection
        self.content = content()
    }
    var body: some View {
        ZStack(alignment: .bottom){
            content
                .ignoresSafeArea()
            ContentView(selection:$selection, localSelection: selection, tabs:tabs )
            
        }
        
        .onPreferenceChange(TabBarItemsPreferenceKey.self, perform: { value in
            self.tabs = value
        })
    }
}

//struct CustomTabBarContainerView_Previews: PreviewProvider {
//    static let tabs: [TabBarItem] = [
//        .posts,.profile
//   ]
//    static var previews: some View {
//        CustomTabBarContainerView(selection: .constant(tabs.first!)) {
//            Color.red
//        }
//    }
//}
