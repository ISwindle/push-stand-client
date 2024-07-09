//
//  SignUpVerificationViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 11/6/23.
//

import UIKit

class SignUpVerificationViewController: UIViewController {

// Outlets
//    @IBOutlet weak var codeLabel1: UILabel!
//    @IBOutlet weak var codeLabel2: UILabel!
//    @IBOutlet weak var codeLabel3: UILabel!
//    @IBOutlet weak var codeLabel4: UILabel!
//    @IBOutlet weak var codeLabel5: UILabel!
//    @IBOutlet weak var codeLabel6: UILabel!
//    @IBOutlet weak var resendButton: UIButton!
//    @IBOutlet weak var callMeButton: UIButton!
//
//    // This array will hold your labels
//    private var codeLabels: [UILabel]!
//
//    // Timer for resend button
//    private var countdownTimer: Timer?
//    private var remainingSeconds: Int = 60
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Initialize codeLabels array
//        codeLabels = [codeLabel1, codeLabel2, codeLabel3, codeLabel4, codeLabel5, codeLabel6]
//
//        startCountdown()
//    }
//
//    private func startCountdown() {
//        countdownTimer?.invalidate() // Stops any existing timer
//        remainingSeconds = 60 // Reset the time (1 minute)
//
//        // Update button title immediately
//        updateResendButtonTitle()
//
//        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
//    }
//
//    @objc private func updateCountdown() {
//        remainingSeconds -= 1
//        updateResendButtonTitle()
//
//        if remainingSeconds <= 0 {
//            countdownTimer?.invalidate()
//            // Update UI to indicate that the user can resend the code
//        }
//    }
//
//    private func updateResendButtonTitle() {
//        let minutes = remainingSeconds / 60
//        let seconds = remainingSeconds % 60
//        resendButton.setTitle("Resend Code in \(String(format: "%01d:%02d", minutes, seconds))", for: .normal)
//        callMeButton.setTitle("Call Me in \(String(format: "%01d:%02d", minutes, seconds))", for: .normal)
//    }
//
//    // Actions for your buttons
//    @IBAction func didTapResendButton(_ sender: UIButton) {
//        // Code to resend the verification code
//        startCountdown()
//    }
//
//    @IBAction func didTapCallMeButton(_ sender: UIButton) {
//        // Code to call the user with the verification code
//    }
//
//    // Implement a method to handle number input
//    func enterCodeDigit(digit: String) {
//        for label in codeLabels {
//            if label.text?.isEmpty ?? true {
//                label.text = digit
//                break
//            }
//        }
//    }
//
//    // You can call this method when a digit on the custom number pad is tapped
//    @IBAction func numberPadTapped(_ sender: UIButton) {
//        guard let digit = sender.titleLabel?.text else { return }
//        enterCodeDigit(digit: digit)
//    }
//
//    // Implement deletion if required
//    func deleteLastDigit() {
//        for label in codeLabels.reversed() {
//            if label.text?.isEmpty == false {
//                label.text = ""
//                break
//            }
//        }
//    }
//    
//    // If you use a button for backspace on your custom keypad
//    @IBAction func backspaceTapped(_ sender: UIButton) {
//        deleteLastDigit()
//    }

    @IBAction func next(_ sender: Any) {
        // Perform the segue with the identifier you set in the storyboard
                self.performSegue(withIdentifier: "verificationToUnpw", sender: self)
    }
    
    // This method gets called just before the segue starts
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "verificationToUnpw" {
                // You can pass data to the destination VC if needed
                if let destinationVC = segue.destination as? SignupBirthdateViewController {
                    // Set properties on destinationVC here
                    //destinationVC.someProperty = "Some Value"
                }
            }
        }
}
