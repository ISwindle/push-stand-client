import UIKit
import Firebase

class AccountEmailViewController: UIViewController {
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var confirmationEmailButton: UIButton!
    
    @IBAction func updateEmail(_ sender: Any) {
        guard let email = emailText.text, Validator.isValidEmail(email) else {
            showAlert(title: "Invalid Email", message: "The entered email is invalid. Please try again.")
            return
        }
        
        checkEmailAvailability(email) { [weak self] available in
            guard available else {
                self?.showAlert(title: "Email Unavailable", message: "The entered email is already in use. Please try a different one.")
                return
            }
            
            // Proceed with updating the email since it's available
            self?.updateUserEmail(email)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        confirmationEmailButton.isEnabled = false
        emailText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        confirmationEmailButton.isEnabled = Validator.isValidEmail(textField.text ?? "")
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true, completion: nil)
    }
    
    private func checkEmailAvailability(_ email: String, completion: @escaping (Bool) -> Void) {
        let data = ["email": email]
        NetworkService.shared.request(endpoint: .checkEmail, method: "POST", data: data) { (result: Result<[String: Any], Error>) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    if let emailExists = response["email_exists"] as? Bool {
                        completion(!emailExists)
                    } else {
                        print("Invalid response format: \(response)")
                        completion(false)
                    }
                }
            case .failure(let error):
                print("Failed to check email availability: \(error)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    func reauthenticateUser(currentPassword: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            completion(false, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user logged in or user has no email"]))
            return
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        user.reauthenticate(with: credential) { result, error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }
    
    func updateEmail(newEmail: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user logged in"]))
            return
        }

        user.updateEmail(to: newEmail) { error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }
    
    private func updateUserEmail(_ email: String) {
        
        guard let currentPassword = currentPasswordTextField.text, !currentPassword.isEmpty,
              let newEmail = emailText.text, !newEmail.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields")
            return
        }
        
        reauthenticateUser(currentPassword: currentPassword) { [weak self] success, error in
            guard let self = self else { return }
            
            if success {
                self.updateEmail(newEmail: newEmail) { success, error in
                    if success {
                        self.showAlert(title: "Success", message: "Email updated successfully")
                        let payload: [String: Any] = [
                            "UserId": CurrentUser.shared.uid,
                            "Birthdate": CurrentUser.shared.birthdate ?? "",
                            "Email": email,
                            "PhoneNumber": CurrentUser.shared.phoneNumber ?? "",
                            "ReminderTime": CurrentUser.shared.reminderTime ?? "",
                            "FirebaseAuthToken": CurrentUser.shared.firebaseAuthToken ?? "",
                        ]
                        
                        NetworkService.shared.request(endpoint: .updateUser, method: "PUT", data: payload) { (result: Result<[String: Any], Error>) in
                            switch result {
                            case .success(let response):
                                DispatchQueue.main.async {
                                    if let success = response["success"] as? Bool, success {
                                        self.showAlert(title: "Success", message: "Email updated successfully")
                                    } else {
                                        self.showAlert(title: "Error", message: "Failed to update email: Invalid response format")
                                    }
                                }
                            case .failure(let error):
                                DispatchQueue.main.async {
                                    self.showAlert(title: "Error", message: "Failed to update email: \(error.localizedDescription)")
                                }
                            }
                        }
                    } else {
                        self.showAlert(title: "Error", message: "Failed to update email: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            } else {
                self.showAlert(title: "Incorrect Password", message: "The password you entered is incorrect.  Please try again.")
            }
        }
        
    }
    
}
