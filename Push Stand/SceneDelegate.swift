//
//  SceneDelegate.swift
//  Push Stand
//
//  Created by Isaac Swindle on 10/17/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private let userDefaults = UserDefaults.standard
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate
    private let notificationCenter = NotificationCenter.default
    
    // Determine if the user has signed in before
    private var hasLaunchedBefore: Bool {
        userDefaults.bool(forKey: Constants.UserDefaultsKeys.userSignedIn)
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Observe the CountdownReachedZero notification
        notificationCenter.addObserver(self, selector: #selector(handleCountdownZero), name: .countdownReachedZero, object: nil)
        
        guard let windowScene = scene as? UIWindowScene else { return }
        let storyboard = UIStoryboard(name: Constants.mainStoryboard, bundle: nil)
        let window = UIWindow(windowScene: windowScene)
        
        if hasLaunchedBefore {
            window.rootViewController = storyboard.instantiateViewController(identifier: ViewControllers.rootTabBarController)
        } else {
            window.rootViewController = storyboard.instantiateViewController(identifier: ViewControllers.initialViewController)
        }
        
        self.window = window
        window.makeKeyAndVisible()
    }
    
    // MARK: - Notification Handlers
    
    /// Handles the event when the countdown reaches zero.
    @objc private func handleCountdownZero() {
        resetApp()
        // You can perform additional global actions here if needed.
    }
    
    // MARK: - Scene Lifecycle Methods
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Remove observer when the scene disconnects
        notificationCenter.removeObserver(self, name: .countdownReachedZero, object: nil)
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Restart the countdown timer when entering the foreground
        CountdownTimerManager.shared.startCountdown()
        
        if hasLaunchedBefore && !userDefaults.bool(forKey: Time.getPacificCurrentDateFormatted()) {
            resetApp()
        }
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Save changes in the application's managed object context
        appDelegate?.saveContext()
    }
    
    // MARK: - Helper Methods
    
    /// Changes the root view controller of the window with an optional animation.
    /// - Parameters:
    ///   - viewController: The new root view controller.
    ///   - animated: Indicates whether the change should be animated.
    func changeRootViewController(_ viewController: UIViewController, animated: Bool = true) {
        guard let window = window else { return }
        window.rootViewController = viewController
        
        if animated {
            UIView.transition(with: window,
                              duration: 0.5,
                              options: .transitionCrossDissolve,
                              animations: nil,
                              completion: nil)
        }
    }
    
    /// Resets the app to its initial state by recreating the root tab bar controller.
    private func resetApp() {
        appDelegate?.appStateViewModel.setAppBadgeCount(to: 2)
        
        // Dismiss any presented view controllers
        window?.rootViewController?.dismiss(animated: false, completion: nil)
        
        // Reset the app by recreating the tab bar with fresh instances of view controllers
        let storyboard = UIStoryboard(name: Constants.mainStoryboard, bundle: nil)
        
        guard let rootTabBarController = storyboard.instantiateViewController(identifier: ViewControllers.rootTabBarController) as? UITabBarController else {
            return
        }
        
        // Create fresh instances of the view controllers for each tab
        let homeStatsVC = storyboard.instantiateViewController(identifier: ViewControllers.homeStatsViewController)
        let dailyQuestionVC = storyboard.instantiateViewController(identifier: ViewControllers.dailyQuestionViewController)
        
        // Assign them to the tab bar
        rootTabBarController.viewControllers = [homeStatsVC, dailyQuestionVC]
        self.appDelegate!.appStateViewModel.setAppBadgeCount(to: 2)
        // Set the root view controller with a transition
        if let window = window {
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = rootTabBarController
            }, completion: nil)
        }
    }

    
}

// MARK: - Notification Names Extension

extension Notification.Name {
    static let countdownReachedZero = Notification.Name("CountdownReachedZero")
}
