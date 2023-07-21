//
//  NightOutApp.swift
//  NightOut
//
//  Created by Kyle Zeller on 7/9/22.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

//this class was copied from the set up from firebase
class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
       FirebaseApp.configure()
       return true
     }

     func application(_ application: UIApplication,
                      didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
       if Auth.auth().canHandleNotification(userInfo) {
         return
       }
       // Your custom handling
     }
   }

    
@main
struct NightOutApp: App {
    //line below was also copied as instructed
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var onboardingViewModel: OnboardingViewModel  = OnboardingViewModel()
    
    
    var body: some Scene {
            WindowGroup {
                ZStack{
                    if onboardingViewModel.showlogin{
                        LoginView()
                            .environmentObject(onboardingViewModel)
                    }
                    else if onboardingViewModel.showOnboardingTab{
                        OnboardingTabView()
                            .environmentObject(onboardingViewModel)
                    }
                    else {
                        InAppView()
                    }
                }
            }
        }
}
