import UIKit

class SignUpUsernamePasswordViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var dataManager = OnboardingManager.shared
    private let minimumPasswordLength = 6
    
    // Activity Indicator (Spinner)
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addTextFieldTargets()
        nextButton.isUserInteractionEnabled = true
    }
    
    private func setupUI() {
        nextButton.isEnabled = false
    }
    
    private func addTextFieldTargets() {
        usernameTextField.addTarget(self, action: #selector(usernameFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordFieldDidChange(_:)), for: .editingChanged)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapDismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapDismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc private func usernameFieldDidChange(_ textField: UITextField) {
        validateForm()
    }
    
    @objc private func passwordFieldDidChange(_ textField: UITextField) {
        validateForm()
    }
    
    private func validateForm() {
        guard let username = usernameTextField.text, Validator().isValidEmail(username),
              let password = passwordTextField.text, Validator().isValidPassword(password) else {
            nextButton.isEnabled = false
            return
        }
        nextButton.isEnabled = true
    }
    
    @IBAction private func next(_ sender: Any) {
        guard let email = usernameTextField.text, Validator().isValidEmail(email) else {
            presentAlertWithTitle(title: "Invalid Email", message: "Please enter a valid email address.")
            return
        }
        showLoading(on: nextButton ,isLoading: true, loader: activityIndicator)
        checkEmailAvailability(email) { [weak self] available in
            guard available else {
                self?.presentAlertWithTitle(title: "Email Unavailable", message: "This email is already in use. Please try another one.")
                return
            }
            self?.proceedToNextScreen()
        }
    }
    
    private func checkEmailAvailability(_ email: String, completion: @escaping (Bool) -> Void) {
        self.nextButton.isUserInteractionEnabled = false
        let data = ["email": email]
        NetworkService.shared.request(endpoint: .checkEmail, method: "POST", data: data) { (result: Result<[String: Any], Error>) in
            switch result {
            case .success(let response):
                if let emailExists = response["email_exists"] as? Bool {
                    self.showLoading(on: self.nextButton ,isLoading: false, loader: self.activityIndicator)
                    completion(!emailExists)
                } else {
                    self.showLoading(on: self.nextButton ,isLoading: false, loader: self.activityIndicator)
                    completion(false) // Handle the case where email_exists is not found in the response
                }
            case .failure:
                self.showLoading(on: self.nextButton ,isLoading: false, loader: self.activityIndicator)
                completion(false)
            }
        }
    }
    
    
    
    private func proceedToNextScreen() {
        dataManager.onboardingData.username = usernameTextField.text
        dataManager.onboardingData.email = usernameTextField.text
        dataManager.onboardingData.password = passwordTextField.text
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let nextViewController = storyboard.instantiateViewController(withIdentifier: "SignupBirthdateViewController") as? SignupBirthdateViewController else {
            print("ViewController with identifier SignupBirthdateViewController not found.")
            return
        }
        navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    private func presentAlertWithTitle(title: String, message: String, options: [String] = ["OK"], completion: ((Int) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, option) in options.enumerated() {
            alertController.addAction(UIAlertAction(title: option, style: .default) { _ in
                completion?(index)
            })
        }
        present(alertController, animated: true, completion: nil)
    }
}
