import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class SignUpReminderViewController: UIViewController {
    
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var nextButton: UIButton!
    
    private let notificationsDeniedKey = "notificationsDenied"
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // Activity Indicator (Spinner)
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        // Set up notification handling and Firebase Messaging
        setupNotifications()
    }
    
    private func configureUI() {
        // Style the time picker
        timePicker.backgroundColor = .black
        if #available(iOS 13.4, *) {
            timePicker.preferredDatePickerStyle = .wheels
            timePicker.setValue(UIColor.white, forKey: "textColor")
            timePicker.overrideUserInterfaceStyle = .dark
        }
    }
    
    @IBAction func next(_ sender: Any) {
        let utcTime = convertToUTCTime(date: timePicker.date)
        OnboardingData.shared.reminderTime = utcTime
        self.showLoading(on: self.nextButton ,isLoading: true, loader: self.activityIndicator)
        createUser()
    }
    
    private func convertToUTCTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Set formatter time zone to UTC
        return formatter.string(from: date)
    }
    
    func createUser() {
        guard let email = OnboardingData.shared.email,
              let password = OnboardingData.shared.password else {
            print("Email or password not provided")
            self.showLoading(on: self.nextButton ,isLoading: false, loader: self.activityIndicator)
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                self.presentAlert(title: "Error", message: error.localizedDescription)
                self.showLoading(on: self.nextButton ,isLoading: false, loader: self.activityIndicator)
                return
            }
            
            self.saveUserDataToFirestore()
        }
    }
    
    private func saveUserDataToFirestore() {
        guard let user = Auth.auth().currentUser else {
            print("Failed to get authenticated user")
            self.showLoading(on: self.nextButton ,isLoading: false, loader: self.activityIndicator)
            return
        }
        
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "UserId": user.uid,
            "Email": user.email ?? "",
            "ReminderTime": OnboardingData.shared.reminderTime ?? "",
            "Birthdate": formattedDate(date: OnboardingData.shared.birthday),
            "PhoneNumber": OnboardingData.shared.phoneNumber ?? ""
        ]
        
        NetworkService.shared.request(endpoint: .users, method: "POST", data: userData) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let json):
                guard let bodyString = json["body"] as? String,
                      let bodyData = bodyString.data(using: .utf8),
                      let userDetails = try? JSONSerialization.jsonObject(with: bodyData, options: []) as? [String: Any] else {
                    print("Error parsing user details from the response")
                    return
                }
                
                let currentUser = CurrentUser.shared
                
                currentUser.uid = userDetails["UserId"] as? String ?? ""
                currentUser.email = userDetails["Email"] as? String ?? ""
                currentUser.reminderTime = userDetails["ReminderTime"] as? String ?? ""
                currentUser.birthdate = userDetails["Birthdate"] as? String ?? ""
                currentUser.phoneNumber = userDetails["PhoneNumber"] as? String ?? ""
                
                if let userNumber = userDetails["UserNumber"] as? String {
                    currentUser.userNumber = String(userNumber) // Ensure proper casting
                }
                
                // Store user details in UserDefaults
                UserDefaults.standard.set(true, forKey: "usersignedin")
                UserDefaults.standard.set(currentUser.uid, forKey: "userId")
                UserDefaults.standard.set(currentUser.email, forKey: "userEmail")
                UserDefaults.standard.set(currentUser.userNumber, forKey: "userNumber")
                UserDefaults.standard.set(currentUser.reminderTime, forKey: "reminderTime")
                UserDefaults.standard.set(currentUser.birthdate, forKey: "birthDate")
                UserDefaults.standard.set(currentUser.phoneNumber, forKey: "phoneNumber")
                UserDefaults.standard.synchronize()
                
                FirebaseTokenManager.shared.retrieveToken()
                
                // Additional app logic
                self.appDelegate.appStateViewModel.setAppBadgeCount(to: 2)
                self.transitionToMainApp()
                
            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription)
                self.showLoading(on: self.nextButton ,isLoading: false, loader: self.activityIndicator)
            }
        }
    }
    
    
    private func formattedDate(date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func transitionToMainApp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "RootTabBarController") as? UITabBarController else { return }
        
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
            
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
    
    private func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    private func setupNotifications() {
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        // Check if the user has already been asked and denied twice
        let hasDeniedBefore = UserDefaults.standard.bool(forKey: notificationsDeniedKey)
        
        if !hasDeniedBefore {
            // Request authorization for notifications
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            notificationCenter.requestAuthorization(options: authOptions) { granted, error in
                DispatchQueue.main.async {
                    if granted {
                        // User granted notifications
                        UIApplication.shared.registerForRemoteNotifications()
                    } else {
                        // User denied notifications
                        self.handleNotificationDenied()
                    }
                }
            }
            
            // Register for remote notifications
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            print("User denied notifications twice, won't ask again.")
        }
    }
    
    private func handleNotificationDenied() {
        // Check if it's the second time denial happens
        let hasDeniedBefore = UserDefaults.standard.bool(forKey: notificationsDeniedKey)
        
        if hasDeniedBefore {
            // User has denied twice, so don't show alert again
            return
        } else {
            // First denial, show alert and set flag to true
            Alerts.showNotificationsDeniedAlert()
            UserDefaults.standard.set(true, forKey: notificationsDeniedKey)
        }
    }
}
