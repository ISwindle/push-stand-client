import UIKit

class AccountEmailViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var confirmationEmailButton: UIButton!

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        confirmationEmailButton.isEnabled = false
        emailText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    // MARK: - Actions
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @IBAction func updateEmail(_ sender: Any) {
        validateAndProcessEmail()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        confirmationEmailButton.isEnabled = isValidEmail(textField.text ?? "")
    }

    // MARK: - Email Validation and Update
    private func validateAndProcessEmail() {
        guard let email = emailText.text, isValidEmail(email) else {
            showAlert(title: "Invalid Email", message: "The entered email is invalid. Please try again.")
            return
        }
        
        checkEmailAvailability(email) { [weak self] available in
            guard available else {
                self?.showAlert(title: "Email Unavailable", message: "The entered email is already in use. Please try a different one.")
                return
            }
            self?.updateUserEmail(email)
        }
    }

    // MARK: - Network Calls
    private func checkEmailAvailability(_ email: String, completion: @escaping (Bool) -> Void) {
        let data = ["email": email]
        NetworkService.shared.request(endpoint: .checkEmail, method: "POST", data: data) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    completion(!response.email_exists)
                }
            case .failure(let error):
                print("Failed to check email availability: \(error)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }

    private func updateUserEmail(_ email: String) {
        let payload: [String: Any] = [
            "UserId": CurrentUser.shared.uid,
            "Birthdate": CurrentUser.shared.birthdate ?? "",
            "Email": email,
            "PhoneNumber": CurrentUser.shared.phoneNumber ?? "",
            "ReminderTime": CurrentUser.shared.reminderTime ?? "",
            "FirebaseAuthToken": CurrentUser.shared.firebaseAuthToken ?? "",
        ]

        NetworkService.shared.request(endpoint: .updateUser, method: "PUT", data: payload) { (result: Result<Bool, Error>) in
            switch result {
            case .success:
                self.showAlert(title: "Success", message: "Email updated successfully")
            case .failure(let error):
                self.showAlert(title: "Error", message: "Failed to update email: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Utilities
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true, completion: nil)
    }
    
}
