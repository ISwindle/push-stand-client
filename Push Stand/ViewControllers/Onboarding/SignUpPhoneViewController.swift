import UIKit

class SignUpPhoneViewController: UIViewController, UITextFieldDelegate {

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
        phoneNumberTextField.delegate = self
        phoneNumberTextField.text = "+1 " // Always start with +1
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
        guard let currentText = textField.text else {
            nextButton.isEnabled = false
            return
        }

        // Remove the +1 prefix from the text to focus on formatting the numbers the user entered.
        var strippedText = currentText.replacingOccurrences(of: "+1 ", with: "")
        strippedText = stripPhoneNumberFormatting(strippedText)

        // Limit input to 10 digits (area code + phone number)
        if strippedText.count > 10 {
            strippedText = String(strippedText.prefix(10))
        }

        // Format the number as (XXX) XXX-XXXX
        let formattedText = format(with: "(XXX) XXX-XXXX", phone: strippedText)

        // Reapply the +1 prefix
        textField.text = "+1 " + formattedText

        // Enable the next button only if the phone number is valid (10 digits after +1)
        nextButton.isEnabled = Validator().isValidPhoneNumber(strippedText)
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

        // Save the stripped phone number (only numbers) in the shared OnboardingManager.
        let strippedPhoneNumber = stripPhoneNumberFormatting(phoneNumber)
        OnboardingData.shared.setPhoneNumber(strippedPhoneNumber)

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

    // MARK: - Formatting Methods

    /// Formats the phone number according to the desired pattern.
    private func format(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator

        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                result.append(numbers[index])
                index = numbers.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }

    /// Strips non-numeric characters from the phone number.
    private func stripPhoneNumberFormatting(_ phone: String?) -> String {
        return phone?.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression) ?? ""
    }
}
