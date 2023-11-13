import UIKit

class SignUpReminderViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func next(_ sender: Any) {
        
        // Instantiate the view controllers that will be part of the tab bar
            let firstViewController = PushStandViewController()
            
            // Create the tab bar controller and set its view controllers
            let tabBarController = RootTabBarController()
            tabBarController.viewControllers = [firstViewController]
            
        
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = tabBarController
                window.makeKeyAndVisible()
                
                // Optional: Add a transition animation
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
            }
    }
    
}
