import UIKit

class SignUpUsernamePasswordViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    // Activity Indicator (Spinner) for loading state
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addTextFieldTargets()
    }
    
    // MARK: - UI Setup Methods
    
    /// Configures the initial UI state of the view controller.
    private func setupUI() {
        nextButton.isEnabled = false // Initially disable the "Next" button
        nextButton.isUserInteractionEnabled = true // Enable user interaction on the button
        addDismissKeyboardTapGesture() // Dismiss keyboard when tapping outside text fields
    }
    
    /// Adds target actions for text field changes and gestures to dismiss the keyboard.
    private func addTextFieldTargets() {
        usernameTextField.addTarget(self, action: #selector(usernameFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordFieldDidChange(_:)), for: .editingChanged)
    }
    
    /// Adds a gesture recognizer to dismiss the keyboard when tapping outside the text fields.
    private func addDismissKeyboardTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapDismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - UITextField Change Handlers
    
    /// Called when the username text field changes. Validates the form.
    @objc private func usernameFieldDidChange(_ textField: UITextField) {
        validateForm()
    }
    
    /// Called when the password text field changes. Validates the form.
    @objc private func passwordFieldDidChange(_ textField: UITextField) {
        validateForm()
    }
    
    /// Dismisses the keyboard when tapping outside the text fields.
    @objc private func tapDismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Validation
    
    /// Validates the form by checking if the email and password are valid.
    private func validateForm() {
        guard let username = usernameTextField.text, Validator().isValidEmail(username),
              let password = passwordTextField.text, Validator().isValidPassword(password) else {
            nextButton.isEnabled = false
            return
        }
        nextButton.isEnabled = true
    }
    
    // MARK: - Actions
    
    /// Called when the "Next" button is tapped. It validates the email and proceeds.
    @IBAction private func next(_ sender: Any) {
        guard let email = usernameTextField.text, Validator().isValidEmail(email) else {
            presentAlertWithTitle(title: "Invalid Email", message: "Please enter a valid email address.")
            return
        }
        
        // Show loading indicator and disable the button
        showLoading(on: nextButton, isLoading: true, loader: activityIndicator)
        
        // Check email availability asynchronously
        checkEmailAvailability(email) { [weak self] available in
            guard let self = self else { return }
            self.showLoading(on: self.nextButton, isLoading: false, loader: self.activityIndicator)
            
            if available {
                self.proceedToNextScreen()
            } else {
                self.presentAlertWithTitle(title: "Email Unavailable", message: "This email is already in use. Please try another one.")
            }
        }
    }
    
    // MARK: - Email Availability Check
    
    /// Checks whether the provided email is available by making a network request.
    /// - Parameters:
    ///   - email: The email to check availability for.
    ///   - completion: A closure that returns `true` if the email is available, `false` otherwise.
    private func checkEmailAvailability(_ email: String, completion: @escaping (Bool) -> Void) {
        nextButton.isUserInteractionEnabled = false
        let data = ["email": email]
        
        NetworkService.shared.request(endpoint: .checkEmail, method: "POST", data: data) { (result: Result<[String: Any], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let emailExists = response["email_exists"] as? Bool {
                        completion(!emailExists)
                    } else {
                        completion(false)
                    }
                case .failure:
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    /// Proceeds to the next view controller in the onboarding flow.
    private func proceedToNextScreen() {
        // Update the onboarding data manager with the entered credentials
        OnboardingData.shared.setUsername(usernameTextField.text!)
        OnboardingData.shared.setEmail(usernameTextField.text!)
        OnboardingData.shared.setPassword(passwordTextField.text!)
        // Navigate to the next screen in the onboarding flow
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let nextViewController = storyboard.instantiateViewController(withIdentifier: "SignupBirthdateViewController") as? SignupBirthdateViewController {
            navigationController?.pushViewController(nextViewController, animated: true)
        } else {
            print("ViewController with identifier 'SignupBirthdateViewController' not found.")
        }
    }
    
    // MARK: - Alerts
    
    /// Presents an alert with a title and message.
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - message: The message of the alert.
    ///   - options: The list of button options. Default is ["OK"].
    ///   - completion: An optional closure to handle button tap actions.
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
