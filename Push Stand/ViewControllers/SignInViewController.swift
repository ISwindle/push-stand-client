import UIKit
import Firebase
import FirebaseFirestore

class SignInViewController: UIViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func login(_ sender: Any) {
        
        // Create cleaned versions of the text field
        let email = userNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        // Signing in the user
        Auth.auth().signIn(withEmail: email, password: password) { [self] _, error in

            if error != nil {
                // Add Error Handling
                let ac = UIAlertController(title: "Login Failed", message: "Username/Password Not Found", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Try Again", style: .default))
                self.present(ac, animated: true)
                print("Error in Signin")
            } else {
                self.appDelegate.currentUser.email = Auth.auth().currentUser?.email
                self.appDelegate.currentUser.uid = Auth.auth().currentUser?.uid
                
                UserDefaults.standard.set(true, forKey: "usersignedin")
                UserDefaults.standard.set(Auth.auth().currentUser?.uid, forKey: "userId")
                UserDefaults.standard.set(Auth.auth().currentUser?.email, forKey: "userEmail")
                UserDefaults.standard.synchronize()
                
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
                // was here
            }
        }
        
    }
    
    
}
