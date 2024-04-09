import UIKit

class SignUpUsernamePasswordViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var dataManager = OnboardingManager.shared
    
    @IBAction func enterUnAndPw(_ sender: Any) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.isEnabled = false
        passwordTextField.addTarget(self, action: #selector(passwordFieldDidChange(_:)), for: .editingChanged)

    }
    
    @objc func passwordFieldDidChange(_ textField: UITextField) {
        if let username = usernameTextField.text, isValidEmail(username), let password = passwordTextField.text, isValidPassword(password) {
                // Handle valid username, e.g., enable a button or change a label color
                nextButton.isEnabled = true
            } else {
                // Handle invalid username
                nextButton.isEnabled = false
            }
    }
    
    func isValidPassword(_ password: String) -> Bool {
        return password.count > 7
    }
    
    @IBAction func next(_ sender: Any) {
        
        guard let username = usernameTextField.text, username.count > 3 else {
            presentAlertWithTitle(title: "Invalid Username", message: "Username must be at least 3 characters long.", options: "OK") { (option) in
                print("Option selected: \(option)")
            }
            return
        }
        
        guard let password = passwordTextField.text, password.count >= 6 else {
            presentAlertWithTitle(title: "Invalid Password", message: "Password must be at least 6 characters long.", options: "OK") { (option) in
                print("Option selected: \(option)")
            }
            return
        }
        
        // If the password meets the requirement, proceed with saving data and performing segue
        dataManager.onboardingData.username = usernameTextField.text
        dataManager.onboardingData.email = usernameTextField.text
        dataManager.onboardingData.password = passwordTextField.text
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "SignupBirthdateViewController") as! SignupBirthdateViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func presentAlertWithTitle(title: String, message: String, options: String..., completion: @escaping (Int) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, option) in options.enumerated() {
            alertController.addAction(UIAlertAction.init(title: option, style: .default, handler: { (action) in
                completion(index)
            }))
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
}
