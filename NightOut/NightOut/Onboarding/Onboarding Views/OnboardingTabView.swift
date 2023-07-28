//  OnboardingTabView.swift
//  Campus Clique
//
//  Created by Kyle Zeller on 7/21/23.
//
//  This SwiftUI View represents the onboarding process for a new user.
//  The onboarding process is split into three stages - user profile creation, data acquisition, and profile picture acquisition.
//  These stages are presented using a TabView.

import SwiftUI

struct OnboardingTabView: View {
    @State private var selection: Int = 0 // The state variable for tracking the selected tab
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel // The ViewModel for handling onboarding data and logic

    var body: some View {
        TabView(selection: $selection){
            // User profile creation tab
            CreateUserProfile(selection: $selection)
                .tag(0) // Tag associated with the tab
                .environmentObject(onboardingViewModel) // OnboardingViewModel injected into environment
                .edgesIgnoringSafeArea(.all) // Makes the view take up the entire screen

            // User data acquisition tab
            UserDataAcquisition(selection: $selection)
                .tag(1)
                .environmentObject(onboardingViewModel)
                .edgesIgnoringSafeArea(.all)

            // Profile picture acquisition tab
            ProfilePictureAcquisition(selection: $selection)
                .tag(2)
                .environmentObject(onboardingViewModel)
                .edgesIgnoringSafeArea(.all)
        }
        // Specific properties for the TabView when running on iOS
#if os(iOS)
        .tabViewStyle(.page(indexDisplayMode: .always)) // Sets the TabView to a paging style, with index always shown
        .indexViewStyle(.page(backgroundDisplayMode: .always)) // Sets the background display mode of the index view to always
#endif
        .background(Color.gray.edgesIgnoringSafeArea(.all)) // Sets the background color for the entire view
    }
}

// Preview provider for Xcode
struct OnboardingTabView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingTabView()
    }
}
