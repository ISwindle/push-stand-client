import UIKit
import CoreTelephony

/// Handles the app's scene lifecycle events and manages app-wide behavior such as root view controller transitions and notifications.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: - Properties
    
    var window: UIWindow?
    private let userDefaults = UserDefaults.standard
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate
    private let notificationCenter = NotificationCenter.default
    
    /// Determines if the user has signed in before by checking the 'userSignedIn' flag in UserDefaults.
    private var isSignedIn: Bool {
        userDefaults.bool(forKey: Constants.UserDefaultsKeys.userSignedIn)
    }
    
    // MARK: - Scene Lifecycle Methods
    
    /// Called when the scene is being connected to a session.
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        _ = NetworkMonitor.shared
        
        // Observe the CountdownReachedZero notification to handle app resets.
        notificationCenter.addObserver(self, selector: #selector(handleCountdownZero), name: .countdownReachedZero, object: nil)
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let storyboard = UIStoryboard(name: Constants.mainStoryboard, bundle: nil)
        let window = UIWindow(windowScene: windowScene)
        
        // Check if the user has launched the app before to determine which screen to show
        if isSignedIn {
            // Show the main app if the user has already signed in
            window.rootViewController = storyboard.instantiateViewController(identifier: ViewControllers.rootTabBarController)
        } else {
            // Show the initial onboarding or sign-in screen for first-time users
            window.rootViewController = storyboard.instantiateViewController(identifier: ViewControllers.initialViewController)
        }
        
        self.window = window
        window.makeKeyAndVisible()
    }
    
    /// Called when the scene is about to enter the foreground (become active).
    func sceneWillEnterForeground(_ scene: UIScene) {
        
        // Step 1: Retrieve userId from UserDefaults
        let userId = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.userId) ?? "newUser"
        
        if userId != "newUser" {
            
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
            let systemVersion = UIDevice.current.systemVersion
            let deviceModel = UIDevice.current.model
            let deviceName = UIDevice.current.name
            let screenSize = UIScreen.main.bounds
            let screenResolution = "\(Int(screenSize.width))x\(Int(screenSize.height))"
            let locale = Locale.current.identifier
            let timeZone = TimeZone.current.identifier
            let networkInfo = CTTelephonyNetworkInfo()
            let carrierName = networkInfo.serviceSubscriberCellularProviders?.first?.value.carrierName ?? "Unknown"
            
            // Step 10: Construct the request body
            let deviceInfo: [String: Any] = [
                "userId": userId,
                "appVersion": appVersion,
                "systemVersion": systemVersion,
                "deviceModel": deviceModel,
                "deviceName": deviceName,
                "screenResolution": screenResolution,
                "locale": locale,
                "timeZone": timeZone,
                "carrierName": carrierName
            ]
            
            NetworkService.shared.request(endpoint: .usersEnvironment, method: HTTPVerbs.post.rawValue, data: deviceInfo) {result in
                
                
            }
        }
        
        // Restart the countdown timer whenever the app returns to the foreground
        CountdownTimerManager.shared.startCountdown()
        
        if isSignedIn {
            var badgeCount = 0
            if !UserDefaults.standard.bool(forKey: Time.getPacificDateFormatted()) {
                badgeCount += 1
            }
            if !UserDefaults.standard.bool(forKey: "question-" + Time.getPacificDateFormatted()) {
                badgeCount += 1
            }
            appDelegate!.appStateViewModel.setAppBadgeCount(to: badgeCount)
        }
        
        // If the user has signed in and hasn't performed their daily actions, reset the app
        if isSignedIn && !userDefaults.bool(forKey: Time.getPacificCurrentDateFormatted()) {
            resetApp()
        }
    }
    
    /// Called when the scene enters the background (no longer active).
    func sceneDidEnterBackground(_ scene: UIScene) {
    }
    
    /// Called when the scene disconnects (e.g., the app is no longer in use).
    func sceneDidDisconnect(_ scene: UIScene) {
        // Remove the observer for CountdownReachedZero to avoid memory leaks
        notificationCenter.removeObserver(self, name: .countdownReachedZero, object: nil)
    }
    
    // MARK: - Notification Handlers
    
    /// Handles the event when the countdown timer reaches zero.
    @objc private func handleCountdownZero() {
        resetApp()
        // Additional global actions can be triggered here if necessary.
    }
    
    // MARK: - Helper Methods
    
    /// Changes the root view controller of the app's window, with an optional transition animation.
    /// - Parameters:
    ///   - viewController: The new view controller to set as the root.
    ///   - animated: If true, the transition will be animated (default is true).
    func changeRootViewController(_ viewController: UIViewController, animated: Bool = true) {
        guard let window = window else { return }
        window.rootViewController = viewController
        
        if animated {
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
    
    /// Resets the app to its initial state by recreating the root tab bar controller and refreshing view controllers.
    private func resetApp() {
        // Set the badge count back to 2 (e.g., indicating two actions need to be taken)
        appDelegate?.appStateViewModel.setAppBadgeCount(to: 2)
        
        // Remove all view controllers by setting an empty root view controller
        window?.rootViewController = nil
        
        // Recreate the root tab bar with fresh instances of view controllers
        let storyboard = UIStoryboard(name: Constants.mainStoryboard, bundle: nil)
        guard let rootTabBarController = storyboard.instantiateViewController(identifier: ViewControllers.rootTabBarController) as? UITabBarController else {
            return
        }
        
        // Initialize new instances of the tab bar's view controllers
        let homeStatsVC = storyboard.instantiateViewController(identifier: ViewControllers.homeStatsViewController)
        let dailyQuestionVC = storyboard.instantiateViewController(identifier: ViewControllers.dailyQuestionViewController)
        
        // Set the new view controllers in the tab bar
        rootTabBarController.viewControllers = [homeStatsVC, dailyQuestionVC]
        
        // Transition to the new tab bar controller with a fade animation
        if let window = window {
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = rootTabBarController
            }, completion: nil)
        }
    }
    
}

// MARK: - Notification Names Extension

extension Notification.Name {
    /// Custom notification for when the countdown timer reaches zero.
    static let countdownReachedZero = Notification.Name("CountdownReachedZero")
}
