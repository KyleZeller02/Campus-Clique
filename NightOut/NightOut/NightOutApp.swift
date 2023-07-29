//
//  NightOutApp.swift
//  NightOut
//
//  Created by Kyle Zeller on 7/9/22.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import UserNotifications
import UIKit
import Firebase
import UserNotifications


//this class was copied from the set up from firebase
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })

        application.registerForRemoteNotifications()
        
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications with error: \(error)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
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
    @AppStorage("showOnboarding") var showOnboarding: Bool = false
    @AppStorage("showOnboardingTab") var showOnboardingTab: Bool = false
  
    
    var body: some Scene {
            WindowGroup {
                ZStack{
                    if showOnboarding{
                        LoginView()
                            .environmentObject(onboardingViewModel)
                    }
                    else if showOnboardingTab{
                        OnboardingTabView()
                            .environmentObject(onboardingViewModel)
                            .transition(.move(edge: .bottom))
                    }
                    else {
                        InAppView()
                    }
                }
            }
        }
}
