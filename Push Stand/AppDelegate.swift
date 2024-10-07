import UIKit
import CoreData
import Foundation
import Combine
import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    // MARK: - Properties
    
    var currentUser = CurrentUser.shared
    let userDefault = UserDefaults.standard
    var sessionViewModel: SessionViewModel!
    var appStateViewModel: AppStateViewModel!
    var window: UIWindow?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Application Lifecycle
    
    /// Called when the app has finished launching.
    /// - Parameters:
    ///   - application: The singleton app object.
    ///   - launchOptions: A dictionary containing information about the launch.
    /// - Returns: A boolean indicating if the app was launched successfully.
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Initialize user manager, session view model, and app state view model
        let userManager = UserManager()
        sessionViewModel = SessionViewModel(userManager: userManager)
        appStateViewModel = AppStateViewModel()
        
        // Load current user ID from UserDefaults
        currentUser.uid = userDefault.string(forKey: Constants.UserDefaultsKeys.userId)
        
        // Set badge count if the user is signed in
        if isUserSignedIn() {
            setInitialBadgeCount()
        }
        
        // Set up notification handling and Firebase Messaging
        setupNotifications(application)
        
        return true
    }
    
    /// Determines if a user is signed in by checking UserDefaults.
    /// - Returns: A boolean indicating if the user is signed in.
    func isUserSignedIn() -> Bool {
        return userDefault.string(forKey: Constants.UserDefaultsKeys.userId) != nil
    }
    
    /// Sets the initial app badge count based on the current state.
    private func setInitialBadgeCount() {
        var badgeCount = 0
        
        // Check if the actions for today are incomplete and increase the badge count
        if !userDefault.bool(forKey: Time.getPacificDateFormatted()) {
            badgeCount += 1
        }
        if !userDefault.bool(forKey: "question-" + Time.getPacificDateFormatted()) {
            badgeCount += 1
        }
        appStateViewModel.setAppBadgeCount(to: badgeCount)
    }
    
    /// Sets up the notification handling and Firebase Messaging.
    /// - Parameter application: The singleton app object.
    private func setupNotifications(_ application: UIApplication) {
        // Set UNUserNotificationCenter delegate
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        
        // Request authorization for notifications
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        notificationCenter.requestAuthorization(options: authOptions) { _, _ in }
        
        // Register for remote notifications
        application.registerForRemoteNotifications()
        
        // Set up Firebase Messaging delegate
        Messaging.messaging().delegate = self
    }
    
    // MARK: - Remote Notifications
    
    /// Called when the app successfully registers for remote notifications.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    /// Called when the app fails to register for remote notifications.
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    // MARK: - UISceneSession Lifecycle
    
    /// Creates a new scene configuration for connecting a scene session.
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // MARK: - Notification Handling
    
    /// Handles a received remote notification.
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        handleNotification(userInfo: userInfo)
        completionHandler(.newData)
    }

    /// Determines how to present notifications when the app is in the foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // Get the stored userId from UserDefaults
        if let storedUserId = userDefault.string(forKey: Constants.UserDefaultsKeys.userId),
           let userId = userInfo["userId"] as? String, userId == storedUserId {
            // Present notification if userId matches
            completionHandler([.alert, .badge, .sound])
        } else {
            // Do not present notification if userId doesn't match
            completionHandler([])
        }
    }

    /// Custom function to handle and parse the notification payload.
    private func handleNotification(userInfo: [AnyHashable: Any]) {
        // Get the stored userId from UserDefaults
        if let storedUserId = userDefault.string(forKey: Constants.UserDefaultsKeys.userId),
           let userId = userInfo["userId"] as? String, let action = userInfo["action"] as? String {
            
            if userId == storedUserId && action == "new_day" {
                // Set badge count for a new day
                appStateViewModel.setAppBadgeCount(to: 2)
            }
            
            if userId == storedUserId && action == "stand_reminder" {
                // Handle stand reminder action
            }
            
        } else {
            print("Invalid data payload")
        }
    }
}
