//
//  OnboardingTabView.swift
//  Campus Clique
//
//  Created by Kyle Zeller on 7/21/23.
//

import SwiftUI

struct OnboardingTabView: View {
    @State private var selection: Int = 0
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel
    var body: some View {
        TabView(selection: $selection){
            CreateUserProfile(selection: $selection)
                .tag(0)
                .environmentObject(onboardingViewModel)
                .edgesIgnoringSafeArea(.all)
            UserDataAcquisition(selection: $selection)
            
                .tag(1)
                .environmentObject(onboardingViewModel)
                .edgesIgnoringSafeArea(.all)
            ProfilePictureAcquisition(selection: $selection)
                .tag(2)
                .environmentObject(onboardingViewModel)
                .edgesIgnoringSafeArea(.all)
        }
#if os(iOS)
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
#endif
        
        .background(Color.gray.edgesIgnoringSafeArea(.all))
    }
}

struct OnboardingTabView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingTabView()
    }
}
