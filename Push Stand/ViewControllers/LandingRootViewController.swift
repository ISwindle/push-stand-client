//
//  LandingRootViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 11/5/23.
//
import UIKit

class LandingRootViewController: UIViewController {
    
    //@IBOutlet weak var pushLabel: UILabel!
   // @IBOutlet weak var standLabel: UILabel!
    @IBOutlet weak var joinNowButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        //standLabel.alpha = 0
        //standLabel.textColor = .white
        joinNowButton.alpha = 0
        joinNowButton.setTitle("Join Now", for: .normal)
        joinNowButton.titleLabel?.adjustsFontForContentSizeCategory = true
        
        UIView.animate(withDuration: 1.0, animations: {
            // First animation
            //self.pushLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 1.0, delay: 1.0, options: [], animations: {
                // Second animation
                //self.standLabel.alpha = 1
            }) { _ in
                UIView.animate(withDuration: 0.0, delay: 0.0, options: [], animations: {
                    // Second animation
                    self.joinNowButton.alpha = 1
                }, completion: nil)
            }
        }}
    
    @IBAction func joinNow(_ sender: Any) {
        // Perform the segue with the identifier you set in the storyboard
                self.performSegue(withIdentifier: "joinToPhone", sender: self)
    }
    
    // This method gets called just before the segue starts
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "joinToPhone" {
                // You can pass data to the destination VC if needed
                if let destinationVC = segue.destination as? SignUpInitialPhoneViewController {
                    // Set properties on destinationVC here
                    //destinationVC.someProperty = "Some Value"
                }
            }
        }
    
    // Remove eventually
    @IBAction func skipOnboarding(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "RootTabBarController") as? UITabBarController else { return }
        
        if #available(iOS 15, *) {
            // iOS 15 and later: Use UIWindowScene.windows
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                setRootViewController(window: window, with: tabBarController)
            }
        } else {
            // Earlier iOS versions: Use UIApplication.shared.windows
            if let window = UIApplication.shared.windows.first {
                setRootViewController(window: window, with: tabBarController)
            }
        }

        func setRootViewController(window: UIWindow, with viewController: UIViewController) {
            window.rootViewController = viewController
            window.makeKeyAndVisible()
            
            // Optional: Add a transition animation
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
    
    
}
