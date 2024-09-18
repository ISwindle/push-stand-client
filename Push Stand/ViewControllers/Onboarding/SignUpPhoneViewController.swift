import UIKit

class SignUpPhoneViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup Methods
    
    /// Sets up the UI components such as the phone number text field and next button.
    private func setupUI() {
        setupPhoneNumberTextField()
        setupNextButton()
        addDismissKeyboardTapGesture()
    }

    /// Configures the phone number text field to use a number pad and observe text changes.
    private func setupPhoneNumberTextField() {
        phoneNumberTextField.keyboardType = .numberPad
        phoneNumberTextField.addTarget(self, action: #selector(phoneNumberChanged(_:)), for: .editingChanged)
    }
    
    /// Initially disables the "Next" button until a valid phone number is entered.
    private func setupNextButton() {
        nextButton.isEnabled = false
    }
    
    /// Adds a gesture recognizer to dismiss the keyboard when tapping outside the text field.
    private func addDismissKeyboardTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    /// Triggered when the phone number text field changes. Enables the "Next" button if valid.
    @objc private func phoneNumberChanged(_ textField: UITextField) {
        guard let text = textField.text else {
            nextButton.isEnabled = false
            return
        }
        // Enable the next button only if the phone number is valid.
        nextButton.isEnabled = Validator().isValidPhoneNumber(text)
    }
    
    /// Dismisses the keyboard when tapping outside the text field.
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /// Proceeds to the next view controller after saving the phone number in the onboarding data.
    @IBAction private func next(_ sender: UIButton) {
        guard let phoneNumber = phoneNumberTextField.text, !phoneNumber.isEmpty else {
            // Handle case where phone number is empty, although this is unlikely since button would be disabled.
            print("Phone number is empty.")
            return
        }

        // Save the phone number in the shared OnboardingManager.
        OnboardingData.shared.setPhoneNumber(phoneNumber)

        // Navigate to the next screen in the onboarding flow.
        navigateToNextViewController()
    }
    
    // MARK: - Navigation
    
    /// Navigates to the next view controller in the onboarding flow.
    private func navigateToNextViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let nextViewController = storyboard.instantiateViewController(withIdentifier: "SignUpUsernamePasswordViewController") as? SignUpUsernamePasswordViewController {
            navigationController?.pushViewController(nextViewController, animated: true)
        } else {
            print("ViewController with identifier 'SignUpUsernamePasswordViewController' not found.")
        }
    }
}
