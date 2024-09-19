import UIKit
import CoreData
import Foundation
import Combine
import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    
    var currentUser = CurrentUser.shared
    let userDefault = UserDefaults.standard
    let launchedBefore = UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.userSignedIn)
    var sessionViewModel: SessionViewModel!
    var appStateViewModel: AppStateViewModel!
    var window: UIWindow?
    private var cancellables = Set<AnyCancellable>()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Initialize user manager, session view model, and app state view model
        let userManager = UserManager()
        sessionViewModel = SessionViewModel(userManager: userManager)
        appStateViewModel = AppStateViewModel()
        
        // Set current user UID from user defaults
        currentUser.uid = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.userId)
        
        // Set badge if user is signed in
        if isUserSignedIn() {
            var badgeCount = 0
            if !UserDefaults.standard.bool(forKey: Time.getPacificDateFormatted()) {
                badgeCount += 1
            }
            if !UserDefaults.standard.bool(forKey: Constants.questionUserDefaultsKey) {
                badgeCount += 1
            }
            appStateViewModel.setAppBadgeCount(to: badgeCount)
        }
        
        // Set UNUserNotificationCenter delegate
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        
        // Set up Firebase messaging delegate
        Messaging.messaging().delegate = self
        
        // Request authorization for notifications
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        notificationCenter.requestAuthorization(options: authOptions) { _, _ in }
        
        // Register for remote notifications
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func isUserSignedIn() -> Bool {
        return currentUser.uid != nil
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    // Receive FCM token
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken, !fcmToken.isEmpty else {
            return
        }
        
        SessionViewModel.shared.userManager.updateFirebaseToken(fcmToken: fcmToken) { result in
            switch result {
            case .success:
                print("Firebase token updated successfully.")
            case .failure(let error):
                print("Failed to update Firebase token: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Push_Stand")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        handleNotification(userInfo: userInfo)
        
        completionHandler(.newData)
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        if let userId = userInfo["userId"] as? String, userId == CurrentUser.shared.uid {
            //If the userId in the notification matches the current user, present the notification
            completionHandler([.alert, .badge, .sound])
        } else {
            // Otherwise, don't present the notification
            completionHandler([])
        }
    }
    
    
    // Custom function to handle and parse the notification payload
    private func handleNotification(userInfo: [AnyHashable: Any]) {
        if let userId = userInfo["userId"] as? String, let action = userInfo["action"] as? String {
            if userId == CurrentUser.shared.uid && action == "new_day" {
                appStateViewModel.setAppBadgeCount(to: 2)
            }
            if userId == CurrentUser.shared.uid && action == "stand_reminder" {
            }
        } else {
            print("Invalid data payload")
        }
    }
}
