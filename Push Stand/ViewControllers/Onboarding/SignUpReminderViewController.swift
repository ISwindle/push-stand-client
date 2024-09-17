import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class SignUpReminderViewController: UIViewController {
    
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var nextButton: UIButton!
    
    let usersEndpoint = "https://qik82nqrt0.execute-api.us-east-1.amazonaws.com/prod/users"
    var dataManager = OnboardingManager.shared
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
        dataManager.onboardingData.reminderTime = utcTime
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
        guard let email = dataManager.onboardingData.email,
              let password = dataManager.onboardingData.password else {
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
            "ReminderTime": dataManager.onboardingData.reminderTime ?? "",
            "Birthdate": formattedDate(date: dataManager.onboardingData.birthday),
            "PhoneNumber": dataManager.onboardingData.phoneNumber ?? ""
        ]
        
        
        NetworkService.shared.request(endpoint: .users, method: "POST", data: userData) { [self] result in
            switch result {
            case .success(let json):
                var currentUser = CurrentUser.shared
                
                // Assuming 'json' is a dictionary parsed from the Lambda response
                if let userDetails = json as? [String: Any] {
                    currentUser.uid = userDetails["UserId"] as? String ?? ""
                    currentUser.email = userDetails["Email"] as? String ?? ""
                    currentUser.reminderTime = userDetails["ReminderTime"] as? String ?? ""
                    currentUser.birthdate = userDetails["Birthdate"] as? String ?? ""
                    currentUser.phoneNumber = userDetails["PhoneNumber"] as? String ?? ""
                    
                    // Save the UserNumber as well
                    if let userNumber = userDetails["UserNumber"] as? String {
                        currentUser.userNumber = userNumber
                    }

                    // Store user details in UserDefaults
                    UserDefaults.standard.set(true, forKey: "usersignedin")
                    UserDefaults.standard.set(currentUser.uid, forKey: "userId")
                    UserDefaults.standard.set(currentUser.email, forKey: "userEmail")
                    UserDefaults.standard.set(currentUser.userNumber, forKey: "userNumber")
                    UserDefaults.standard.synchronize()
                    
                    // Additional app logic
                    appDelegate.appStateViewModel.setAppBadgeCount(to: 2)
                    self.transitionToMainApp()
                }
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
}
