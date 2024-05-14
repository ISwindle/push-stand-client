import UIKit

class SignUpUsernamePasswordViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var dataManager = OnboardingManager.shared
    
    @IBAction func enterUnAndPw(_ sender: Any) {
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.isEnabled = false
        usernameTextField.addTarget(self, action: #selector(usernameFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func usernameFieldDidChange(_ textField: UITextField) {
        validateForm()
    }
    
    @objc func passwordFieldDidChange(_ textField: UITextField) {
        validateForm()
    }
    
    func validateForm() {
        if let username = usernameTextField.text, isValidEmail(username),
           let password = passwordTextField.text, isValidPassword(password) {
            nextButton.isEnabled = true
        } else {
            nextButton.isEnabled = false
        }
    }
    
    func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
    
    @IBAction func next(_ sender: Any) {
        guard let email = usernameTextField.text, isValidEmail(email) else {
            presentAlertWithTitle(title: "Invalid Email", message: "Please enter a valid email address.", options: "OK") { _ in }
            return
        }
        
        checkEmailAvailability(email) { [weak self] available in
            guard available else {
                self?.presentAlertWithTitle(title: "Email Unavailable", message: "This email is already in use. Please try another one.", options: "OK") { _ in }
                return
            }
            
            // If email is available and valid, proceed with next steps
            self?.proceedToNextScreen()
        }
    }
    
    private func checkEmailAvailability(_ email: String, completion: @escaping (Bool) -> Void) {
        let data = ["email": email]
        NetworkService.shared.request(endpoint: .checkEmail, method: "POST", data: data) { (result: Result<EmailCheckResponse, Error>) in
            switch result {
            case .success(let response):
                completion(!response.email_exists)
            case .failure:
                completion(false)
            }
        }
    }
    
    private func proceedToNextScreen() {
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
            alertController.addAction(UIAlertAction(title: option, style: .default) { _ in
                completion(index)
            })
        }
        self.present(alertController, animated: true, completion: nil)
    }
}
