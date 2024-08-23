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
            if !UserDefaults.standard.bool(forKey: Time.getDateFormatted()) {
                badgeCount += 1
            }
            if !UserDefaults.standard.bool(forKey: Constants.questionUserDefaultsKey) {
                badgeCount += 1
            }
            appStateViewModel.setAppBadgeCount(to: badgeCount)
        }
        
        
        // Observe changes in badge count
        //observeBadgeCount()
        
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
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // No need to call scheduleMidnightReset() here since it's handled in AppStateViewModel
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
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Handle discarded scene sessions if necessary
    }
    
    // Receive FCM token
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        guard let fcmToken = fcmToken, !fcmToken.isEmpty else {
            print("FCM token is null or empty.")
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
        completionHandler([.alert, .badge, .sound])
    }
    
    // Custom function to handle and parse the notification payload
    private func handleNotification(userInfo: [AnyHashable: Any]) {
        if let userId = userInfo["userId"] as? String, let action = userInfo["action"] as? String {
            if userId == CurrentUser.shared.uid {
                print("Received notification with userId: \(userId) and action: \(action)")
            }
            // Add any additional handling here, such as updating the UI or processing the background task
        } else {
            print("Invalid data payload")
        }
    }
}
