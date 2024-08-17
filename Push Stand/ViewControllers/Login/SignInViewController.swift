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
    
    
    @IBAction func forgotPasswordEmailSend(_ sender: Any) {
        
        guard let email = userNameTextField.text, !email.isEmpty else {
            print("Error: Email field is empty")
            self.showAlert(title: "Enter Email", message: "Please enter your account's email first")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                // Handle errors
                print("Error sending password reset email: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: "Password reset email unsuccessful")
            } else {
                // Successfully sent password reset email
                print("Password reset email sent successfully")
                self.showAlert(title: "Password Reset", message: "If your login exists, we will send a password reset email to \(self.userNameTextField!)")
            }
        }
        
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    @IBAction func login(_ sender: Any) {
        
        // Create cleaned versions of the text field
        let email = userNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Signing in the user
        Auth.auth().signIn(withEmail: email, password: password) { [self] _, error in
            
            if error != nil {
                // Add Error Handling
                let ac = UIAlertController(title: "Login Failed", message: "Invalid username or password", preferredStyle: .alert)
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
                let dailyQuestionsQueryParams = ["userId": CurrentUser.shared.uid!, "Date": Time.getDateFormatted()]
                NetworkService.shared.request(endpoint: .questions, method: "GET", queryParams: dailyQuestionsQueryParams) { (result: Result<[String: Any], Error>) in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let json):
                            if let answer = json["UserAnswer"] as? String,
                               let question = json["Question"] as? String {
                                appDelegate.appStateViewModel.setAppBadgeCount(to: 2)
                                if !answer.isEmpty {
                                    UserDefaults.standard.set(true, forKey: "question-" + Time.getDateFormatted())
                                    self.appDelegate.userDefault.set(true, forKey: "question-" + Time.getDateFormatted())
                                    self.appDelegate.userDefault.synchronize()
                                    //If you have have answered the question, you have stood
                                    appDelegate.appStateViewModel.setAppBadgeCount(to: 0)
                                }
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
                            } else {
                                print("error setting up user")
                            }
                        case .failure(let error):
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                }
                
                
                func setRootViewController(window: UIWindow, with viewController: UIViewController) {
                    window.rootViewController = viewController
                    window.makeKeyAndVisible()
                    
                    // Optional: Add a transition animation
                    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
                }
//                let queryParams = ["user_id": CurrentUser.shared.uid!]
//                NetworkService.shared.request(endpoint: .stand, method: "GET", queryParams: queryParams) { result in
//
//                    switch result {
//                    case .success(let json):
//                        if let hasTakenAction = json["has_taken_action"] as? Bool {
//                            let dateFormatter = DateFormatter()
//                            dateFormatter.dateFormat = "yyyy-MM-dd"
//                            let dateString = dateFormatter.string(from: Date())
//                            UserDefaults.standard.set(true, forKey: dateString)
//                            appDelegate.userDefault.set(true, forKey: dateString)
//                            appDelegate.userDefault.synchronize()
//                            
//                        } else {
//                            print("Invalid response format")
//                        }
//                    case .failure(let error):
//                        print("Error: \(error.localizedDescription)")
//                        // Handle the error appropriately
//                    }
//                    
//                }
                

            }
        }
        
    }
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
}
