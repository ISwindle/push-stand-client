//
//  AccountPhoneNumberViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 4/9/24.
//

import UIKit

class AccountPhoneNumberViewController: UIViewController {
    
    @IBOutlet weak var phoneText: UITextField!
    @IBOutlet weak var confirmationButton: UIButton!
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func changePhoneNumber(_ sender: Any) {
        // Validate the entered phone number
        guard let phone = phoneText.text, Validator().isValidPhoneNumber(phone) else {
            print("Invalid phone number")
            self.showAlert(title: "Invalid Phone #", message: "The entered phone number is invalid. Please try again.")
            return
        }
        
        // Fetch user data from UserDefaults
        guard let userId = UserDefaults.standard.string(forKey: "userId")
        else {
            print("User information is incomplete")
            self.showAlert(title: "Error", message: "Unable to fetch user information. Please try again.")
            return
        }
        
        // Prepare payload with the updated phone number and other user details
        let payload: [String: Any] = [
            "UserId": userId,
            "PhoneNumber": phone,
        ]
        
        // Make a network request to update the phone number
        NetworkService.shared.request(endpoint: .users, method: "PUT", data: payload) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Update phone number in UserDefaults after a successful response
                    UserDefaults.standard.set(phone, forKey: "phoneNumber")
                    UserDefaults.standard.synchronize()
                    
                    // Show success alert
                    self.showAlert(title: "Update!", message: "Phone number updated successfully", dismissViewController: true)
                case .failure(let error):
                    print("Error updating phone number: \(error)")
                    self.showAlert(title: "Error", message: "Failed to update phone number. Please try again.")
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        confirmationButton.isEnabled = false
        phoneText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, Validator().isValidPhoneNumber(text) {
            confirmationButton.isEnabled = true
        } else {
            confirmationButton.isEnabled = false
        }
    }
    
    func showAlert(title: String, message: String, dismissViewController: Bool = false) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            if dismissViewController {
                if let navigationController = self.navigationController {
                    if let accountSettingsViewController = navigationController.viewControllers.first(where: { $0 is AccountSettingsViewController }) {
                        navigationController.popToViewController(accountSettingsViewController, animated: true)
                    }
                }
            }
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
}
