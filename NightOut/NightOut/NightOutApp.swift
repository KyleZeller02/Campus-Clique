//
//  NightOutApp.swift
//  NightOut
//
//  Created by Kyle Zeller on 7/9/22.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

//this class was copied from the set up from firebase
class AppDelegate: NSObject, UIApplicationDelegate {
    
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      
     
      
    return true
  }
}
    
@main
struct NightOutApp: App {
    //line below was also copied as instructed
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @AppStorage("showOnboarding") var showOnboarding: Bool = true
    
        var body: some Scene {
        WindowGroup {
            ZStack{
                if showOnboarding{
                    LoginView()
                }
                else{
                    InAppView()
                }
            }
            
            
        }
    }
}
