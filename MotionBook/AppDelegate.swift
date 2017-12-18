//
//  AppDelegate.swift
//  animator
//
//  Created by YiSeungyoun on 2017. 2. 7..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import SwiftyStoreKit
import Firebase
import FirebaseMessaging
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    lazy var navigationController: NTNavigationController = { [unowned self] in
        let controller = NTNavigationController(rootViewController: self.presentationController)
        
        return controller
        }()
    
    lazy var presentationController: IntroViewController = {
        return IntroViewController(pages: [])
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        DataManager.realmMigrationCheck()

        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            self.handleShortcutItem(shortcutItem: shortcutItem)
        }

        let settings = Settings()
        settings.setOpenSourceIntroViewShown(value: false)
        FirebaseOptions.defaultOptions()?.deepLinkURLScheme = "motionbook"
        
        FirebaseApp.configure()
        Fabric.with([Crashlytics.self])
        self.completeIAPTransactions()
        self.registerPush(application: application)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        self.handleShortcutItem(shortcutItem: shortcutItem)
    }
    
    func handleShortcutItem(shortcutItem: UIApplicationShortcutItem) {
        let settings = Settings()
        switch shortcutItem.type {
        case "com.seungyounyi.MotionBook.Main":
            settings.setShortCutKey(value: 0)
        case "com.seungyounyi.MotionBook.Search":
            settings.setShortCutKey(value: 1)
        case "com.seungyounyi.MotionBook.Bookmark":
            settings.setShortCutKey(value: 2)
        case "com.seungyounyi.MotionBook.Setting":
            settings.setShortCutKey(value: 3)
        default:
            break
        }
    }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let dynamicLink = DynamicLinks.dynamicLinks()?.dynamicLink(fromCustomSchemeURL: url)
        if let url = dynamicLink?.url {
            if let title = self.getQueryStringParameter(url: "\(url)", param: "title") {
                let libData = LibraryData()
                let data = libData.getDataWith(title: title)
                if data != nil {
                    let deepLinkViewController = DetailDeepLinkViewController()
                    deepLinkViewController.data = data
                    
                    if let nc = window?.rootViewController as? NTNavigationController {
                        nc.present(deepLinkViewController, animated: true, completion: nil)
                    }
                    return true
                } else {
                }
            }
            
            let paths = url.pathComponents
            if  paths.count > 1 {
                let libData = LibraryData()
                let data = libData.getDataWith(title: paths[1])
                if data != nil {
                    let deepLinkViewController = DetailDeepLinkViewController()
                    deepLinkViewController.data = data
                    
                    if let nc = window?.rootViewController as? NTNavigationController {
                        nc.present(deepLinkViewController, animated: true, completion: nil)
                    }
                    return true
                }
            }
        } else {
//            Toast.showToast(title: "Library not found", subtitle: "Please refresh all data in Setting tab")
        }
        return false
    }
    
    func pageViewControllerLayout () -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        let itemSize  = CGSize(width: screenWidth, height: screenHeight)
        flowLayout.itemSize = itemSize
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        return flowLayout
    }

    
    func registerPush(application: UIApplication) {
        if #available(iOS 10.0, *) {
            let authOptions : UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_,_ in })
            
            UNUserNotificationCenter.current().delegate = self
            
        }
        
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        InstanceID.instanceID().setAPNSToken(deviceToken, type: InstanceIDAPNSTokenType.prod)
        Messaging.messaging().setAPNSToken(deviceToken, type: MessagingAPNSTokenType.prod)
    }
    
    func completeIAPTransactions() {
        SwiftyStoreKit.completeTransactions(atomically: true) { products in
            for product in products {
                // swiftlint:disable:next for_where
                if product.transaction.transactionState == .purchased || product.transaction.transactionState == .restored {
                    
                    if product.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(product.transaction)
                    }

                    if product.productId == "com.seungyounyi.MotionBook.unlockExamples" {
                        let settings = Settings()
                        settings.setInappPurchased(value: true)
                    }
                }
            }
        }
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        let notificationName = Notification.Name("did-enter-foreground")
        NotificationCenter.default.post(name: notificationName, object: nil)

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print("%@", userInfo)
        
    }
    
}

