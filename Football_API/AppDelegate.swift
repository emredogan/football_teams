//
//  AppDelegate.swift
//  Football_API
//
//  Created by Emre Dogan on 21/04/2022.
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import IQKeyboardManager

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Library setup
        IQKeyboardManager.shared().isEnabled = true
        FirebaseApp.configure()
        
        // Delegate
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        requestNotificationAccess(application)
        return true
    }
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        messaging.token { token, _ in
            guard let token = token else {
                return
            }
            print("Token \(token)")
        }
    }
    
    func requestNotificationAccess(_ application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, _ in
            guard success else {
                return
            }
            print("Success for notification permission")
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
}

