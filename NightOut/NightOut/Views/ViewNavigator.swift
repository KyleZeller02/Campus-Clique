//
//  ViewNavigator.swift
//  NightOut
//
//  Created by Kyle Zeller on 12/20/22.
//

import SwiftUI

    
struct ViewNavigator: View {
    @State var CurrentState :ViewState = ViewState.LoginView
    @ObservedObject var viewRouter: ViewRouter
    
    
    
    var body: some View {
        switch viewRouter.CurrentViewState {
        case .LoginView:
                LoginView(viewRouter: viewRouter)
        case .CreateUserProfile:
            CreateUserProfile(viewRouter: viewRouter)
        case .UserDataAcquisition:
            UserDataAcquisition(viewRouter: viewRouter)
        case .UserBirthdayAcquistion:
            UserBirthdayAcquisition(viewRouter: viewRouter)
        case .ProfilePictureAcquisition:
            ProfilePictureAcquisition(viewRouter: viewRouter)
        case .ClassPosts:
            InAppView(viewRouter:viewRouter)
         // ClassPosts(viewRouter: viewRouter)
        case .UserProfileView: 
            InAppView(viewRouter:viewRouter)
           //UserProfileView(viewRouter: viewRouter)
        case .InAppViews:
            InAppView(viewRouter:viewRouter)
        
        }
        
       
    }
}


    
struct ViewNavigator_Previews: PreviewProvider {
    static var previews: some View {
        ViewNavigator(viewRouter: ViewRouter())
    }
}

enum ViewState{
    // onboarding views-------
    case LoginView
    case CreateUserProfile
    case UserDataAcquisition
    case UserBirthdayAcquistion
    case ProfilePictureAcquisition
    //---------
    case UserProfileView
    case ClassPosts
    case InAppViews
    
}

class ViewRouter:ObservableObject{
    @Published var CurrentViewState: ViewState = .LoginView
    @StateObject var onboardingVM: OnboardingViewModel = OnboardingViewModel()
}

