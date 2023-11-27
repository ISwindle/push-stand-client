import UIKit

class SignUpReminderViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func next(_ sender: Any) {
        
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
