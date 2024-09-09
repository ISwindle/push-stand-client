//
//  SceneDelegate.swift
//  Push Stand
//
//  Created by Isaac Swindle on 10/17/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    let userDefault = UserDefaults.standard
    let launchedBefore = UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.userSignedIn)
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        // guard let _ = (scene as? UIWindowScene) else { return }
        
        // Observe the CountdownReachedZero notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleCountdownZero), name: Notification.Name("CountdownReachedZero"), object: nil)
        
        let storyboard = UIStoryboard(name: Constants.mainStoryboard, bundle: nil)
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            if launchedBefore {
                window.rootViewController = storyboard.instantiateViewController(identifier: ViewControllers.rootTabBarController)
            } else {
                window.rootViewController = storyboard.instantiateViewController(identifier: ViewControllers.initialViewController)
            }
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    // Handle the countdown reaching zero
    @objc func handleCountdownZero() {
        // This will trigger when the countdown hits zero
        print("Countdown reached zero in SceneDelegate. Perform global actions.")
        resetApp()
        
        // You can perform global actions here like updating app-wide UI, resetting the app state, etc.
        // Example: Change the root view controller or update user defaults, etc.
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        // Remove observer when the scene disconnects
        NotificationCenter.default.removeObserver(self, name: Notification.Name("CountdownReachedZero"), object: nil)
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        CountdownTimerManager.shared.startCountdown()
        if launchedBefore && !UserDefaults.standard.bool(forKey: Time.getPacificCurrentDateFormatted()) {
            resetApp()
        }
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    func changeRootViewController(_ vc: UIViewController, animated _: Bool = true) {
        guard let window = window else {
            return
        }
        
        window.rootViewController = vc
        
        // add animation
        UIView.transition(with: window,
                          duration: 0.5,
                          options: [UIView.AnimationOptions.curveLinear],
                          animations: nil,
                          completion: nil)
    }
    
    func resetApp() {
        appDelegate.appStateViewModel.setAppBadgeCount(to: 2)
        
        // Reset the app by recreating the tab bar with fresh instances of view controllers
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let rootTabBarController = storyboard.instantiateViewController(identifier: ViewControllers.rootTabBarController) as? UITabBarController else {
            return
        }
        
        // Create fresh instances of the view controllers for each tab
        let indexZero = storyboard.instantiateViewController(identifier: "HomeStatsViewController")
        let indexOne = storyboard.instantiateViewController(identifier: "DailyQuestionViewController")
        
        // Assign them to the tab bar
        rootTabBarController.viewControllers = [indexZero, indexOne]
        
        // Set the root view controller and display the window
        window?.rootViewController = rootTabBarController
        window?.makeKeyAndVisible()
        
        // Optionally, you can add a transition for smoother experience
        let transition = CATransition()
        transition.type = .fade
        transition.duration = 0.5
        window?.layer.add(transition, forKey: kCATransition)
        
    }
    
}

