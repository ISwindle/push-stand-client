import UIKit

class AccountEmailViewController: UIViewController {
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var confirmationEmailButton: UIButton!

    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @IBAction func updateEmail(_ sender: Any) {
        guard let email = emailText.text, isValidEmail(email) else {
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
        confirmationEmailButton.isEnabled = isValidEmail(textField.text ?? "")
    }

    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true, completion: nil)
    }

    private func checkEmailAvailability(_ email: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://d516i8vkme.execute-api.us-east-1.amazonaws.com/develop/users/checkEmail") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload = ["email": email]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            print("Error encoding JSON: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("Error during the network request or invalid status code")
                return completion(false)
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let emailExists = json["email_exists"] as? Bool {
                    DispatchQueue.main.async {
                        completion(!emailExists)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            } catch {
                print("Error parsing the JSON response: \(error)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }.resume()
    }

    private func updateUserEmail(_ email: String) {
        // Assume currentUser and other dependencies are correctly configured and available
        let url = URL(string: "https://d516i8vkme.execute-api.us-east-1.amazonaws.com/develop/users")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "UserId": CurrentUser.shared.uid,
            "Birthdate": CurrentUser.shared.birthdate,
            "Email": email,
            "PhoneNumber": CurrentUser.shared.phoneNumber,
            "ReminderTime": CurrentUser.shared.reminderTime,
            "FirebaseAuthToken": CurrentUser.shared.firebaseAuthToken,
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            print("Error encoding JSON: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making PUT request: \(error)")
                return
            }
            guard let data = data, let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode) else {
                print("Server error or invalid response")
                return
            }

            DispatchQueue.main.async {
                self.showAlert(title: "Success", message: "Email updated successfully")
            }
        }.resume()
    }
}
