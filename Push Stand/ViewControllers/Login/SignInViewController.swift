import UIKit
import Firebase
import FirebaseFirestore

class SignInViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    // Activity Indicator (Spinner)
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()
    
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
        showLoading(on: self.loginButton, isLoading: true, loader: self.activityIndicator)
        // Create cleaned versions of the text fields
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
                self.showLoading(on: self.loginButton, isLoading: false, loader: self.activityIndicator)
            } else {
                guard let currentUser = Auth.auth().currentUser else { return }
                self.appDelegate.currentUser.email = currentUser.email
                self.appDelegate.currentUser.uid = currentUser.uid
                
                // Fetch user details from DynamoDB or backend
                let userId = currentUser.uid
                let userDetailsQueryParams = ["userId": userId]
                
                NetworkService.shared.request(endpoint: .users, method: "GET", queryParams: userDetailsQueryParams) { (result: Result<[String: Any], Error>) in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let json):
                            // Parse and set user details
                            var currentUser = CurrentUser.shared
                            currentUser.uid = userId
                            currentUser.email = currentUser.email
                            currentUser.reminderTime = json["ReminderTime"] as? String ?? ""
                            currentUser.birthdate = json["Birthdate"] as? String ?? ""
                            currentUser.phoneNumber = json["PhoneNumber"] as? String ?? ""
                            currentUser.firebaseAuthToken = json["FirebaseAuthToken"] as? String ?? ""
                            
                            // Set the UserNumber
                            if let userNumber = json["UserNumber"] as? String {
                                currentUser.userNumber = userNumber
                            }
                            
                            // Store data in UserDefaults
                            UserDefaults.standard.set(true, forKey: "usersignedin")
                            UserDefaults.standard.set(currentUser.uid, forKey: "userId")
                            UserDefaults.standard.set(currentUser.email, forKey: "userEmail")
                            UserDefaults.standard.set(currentUser.reminderTime, forKey: "userReminderTime")
                            UserDefaults.standard.set(currentUser.birthdate, forKey: "userBirthdate")
                            UserDefaults.standard.set(currentUser.phoneNumber, forKey: "userPhoneNumber")
                            UserDefaults.standard.set(currentUser.userNumber, forKey: "userNumber")
                            UserDefaults.standard.synchronize()
                            
                            // Call checkStandToday after fetching user details
                            self.checkStandToday {
                                // Fetch daily questions after retrieving user details and checking the stand today status
                                let dailyQuestionsQueryParams = ["userId": CurrentUser.shared.uid!, "Date": Time.getDateFormatted()]
                                NetworkService.shared.request(endpoint: .questions, method: "GET", queryParams: dailyQuestionsQueryParams) { (result: Result<[String: Any], Error>) in
                                    DispatchQueue.main.async {
                                        switch result {
                                        case .success(let json):
                                            if let answer = json["UserAnswer"] as? String,
                                               let question = json["Question"] as? String {
                                                appDelegate.appStateViewModel.setAppBadgeCount(to: 2)
                                                if !answer.isEmpty {
                                                    UserDefaults.standard.set(true, forKey: "question-" + Time.getPacificDateFormatted())
                                                    self.appDelegate.userDefault.set(true, forKey: "question-" + Time.getPacificDateFormatted())
                                                    self.appDelegate.userDefault.synchronize()
                                                    // If you have answered the question, you have stood
                                                    appDelegate.appStateViewModel.setAppBadgeCount(to: 0)
                                                }
                                                
                                                // Proceed to the main app after fetching daily questions
                                                transitionToMainApp()
                                            } else {
                                                print("Error parsing daily question")
                                            }
                                        case .failure(let error):
                                            print("Error fetching daily questions: \(error.localizedDescription)")
                                            self.showLoading(on: self.loginButton, isLoading: false, loader: self.activityIndicator)
                                        }
                                    }
                                }
                            }
                            
                        case .failure(let error):
                            // Handle failure, display an error message or perform other error handling
                            print("Error fetching user details: \(error.localizedDescription)")
                            self.showLoading(on: self.loginButton, isLoading: false, loader: self.activityIndicator)
                        }
                    }
                }
            }
        }
    }
    
    // Helper function to check if the user has taken action today
    private func checkStandToday(completion: @escaping () -> Void) {
        // Safely unwrap the user ID from UserDefaults
        guard let userId = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.userId) else {
            print("Error: User ID not found in UserDefaults")
            return
        }
        var currentUser = CurrentUser.shared
        // Update the current user's UID
        currentUser.uid = userId
        
        // Prepare query parameters
        let queryParams = ["user_id": userId]
        
        // Make the network request
        NetworkService.shared.request(endpoint: .stand, method: HTTPVerbs.get.rawValue, queryParams: queryParams) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let json):
                if let hasTakenAction = json["has_taken_action"] as? Int {
                    let hasTakenActionBool = hasTakenAction == 1
                    
                    if hasTakenActionBool {
                        let dateString = Time.getPacificDateFormatted()
                        UserDefaults.standard.set(true, forKey: dateString)
                        self.appDelegate.appStateViewModel.setAppBadgeCount(to: 1)
                    }
                }
                completion()
            case .failure(let error):
                print("Error checking stand today: \(error.localizedDescription)")
                completion()
            }
        }
    }
    
    // Helper function to transition to the main app
    private func transitionToMainApp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "RootTabBarController") as? UITabBarController else { return }
        
        if #available(iOS 15, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                setRootViewController(window: window, with: tabBarController)
            }
        } else {
            if let window = UIApplication.shared.windows.first {
                setRootViewController(window: window, with: tabBarController)
            }
        }
    }
    
    // Helper function to set the root view controller
    private func setRootViewController(window: UIWindow, with viewController: UIViewController) {
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
}
