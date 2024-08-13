//
//  AppDelegate.swift
//  jjapp2
//
//  Created by Forest Lim on 7/30/24.
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // UIWindow 인스턴스 생성
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    print("Permission granted: \(granted)")
                }
                application.registerForRemoteNotifications()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // ViewController 인스턴스 생성
        let viewController = ViewController()
        
        // window의 rootViewController 설정
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        // 토큰을 서버로 전송
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
