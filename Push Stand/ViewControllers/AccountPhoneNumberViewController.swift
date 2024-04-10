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
        guard let phone = phoneText.text, isValidPhoneNumber(phone) else {
                print("Invalid email address")
                // Handle invalid email (e.g., show an alert or error message)
                return
        }
        
        let url = URL(string: "https://d516i8vkme.execute-api.us-east-1.amazonaws.com/develop/users")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // Add authorization header if needed
        // request.addValue("Bearer \(yourAuthToken)", forHTTPHeaderField: "Authorization")
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let currentUser = appDelegate.currentUser
            
            let payload: [String: Any] = [
                "UserId": currentUser.uid,
                "Birthdate": currentUser.birthdate,
                "Email": currentUser.email,
                "PhoneNumber": phoneText.text,
                "ReminderTime": currentUser.reminderTime,
                "FirebaseAuthToken": currentUser.firebaseAuthToken,
            ]
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
                request.httpBody = jsonData
            } catch {
                print("Error encoding JSON: \(error)")
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error making PUT request: \(error)")
                    return
                }
                guard let data = data, let response = response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    print("Server error or invalid response")
                    return
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response from the server: \(responseString)")
                }
            }
            
            task.resume()
            // Create the alert controller
            let alert = UIAlertController(title: "Update!", message: "Phone Number Updated Successfully", preferredStyle: .alert)
            
            // Present the alert to the user
            self.present(alert, animated: true, completion: nil)
            
            // Use DispatchQueue to dismiss the alert after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Change 2.0 to your desired number of seconds
                alert.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
