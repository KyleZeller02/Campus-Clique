//
//  ContentView.swift
//  CustomTabBar
//
//  Created by Kyle Zeller on 6/7/23.
//

import SwiftUI

struct ContentView: View {
    @Namespace private var namespace
    @Binding var selection:TabBarItem
    @State var localSelection:TabBarItem
    let tabs:  [TabBarItem]
    var body: some View {
        tabBarVersion2
            .onChange(of: selection, perform: {value in
                withAnimation(.easeInOut){
                    localSelection = value
                }
            })
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static let tabs: [TabBarItem] = [
//        .home,.favorites,.profile
//    ]
//    static var previews: some View {
//        VStack{
//            Spacer()
//            ContentView(selection: .constant(tabs.first!), localSelection: tabs.first!, tabs:tabs)
//        }
//      
//    }
//}



extension ContentView{
    
    private func tabView2(tab: TabBarItem) -> some View {
        VStack {
            Image(systemName: tab.iconName)
                .font(.system(size: 24))
            Text(tab.title)
                .fontWeight(localSelection == tab ? .bold : .regular)
        }
        .foregroundColor( .Black )
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, maxHeight: 40)
        .background(
            ZStack {
                if localSelection == tab {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.accentColor.opacity(0.2))
                        .matchedGeometryEffect(id: "background_rectangle", in: namespace)
                }
            }
        )
        .contentShape(Rectangle())
    }

    private var tabBarVersion2: some View{
//        HStack{
//            ForEach(tabs, id: \.self) { tab in
//                tabView2(tab: tab)
//                    .onTapGesture {
//                        switchToTab(tab: tab)
//                    }
//            }
//
//        }
//        .padding(6)
//        .background(Color.Black.ignoresSafeArea(edges:.bottom))
//        .cornerRadius(10)
//        .shadow(color: .black.opacity(0.3), radius: 10,x: 0,y:5)
//        .padding(.horizontal)
        
        HStack {
            ForEach(tabs, id: \.self) { tab in
                tabView2(tab: tab)
                    .onTapGesture {
                        switchToTab(tab: tab)
                    }
            }
        }
        .padding(6)
        .background(Color.gray.ignoresSafeArea(edges: .bottom))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.Black.opacity(0.3), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 3)
        .padding(.horizontal)


    }
    private func switchToTab(tab:TabBarItem){
            selection = tab
       }
}


