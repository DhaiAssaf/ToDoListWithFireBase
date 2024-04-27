//
//  ToDoListWithFireBaseApp.swift
//  ToDoListWithFireBase
//
//  Created by Dhai Alassaf on 27/04/2024.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct ToDoListWithFireBaseApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  @StateObject var firebaseManager = FirebaseManager()

  var body: some Scene {
    WindowGroup {
    
        ContentView()
            .environmentObject(firebaseManager)
      
    }
  }
}
