import UIKit

class SubmitQuestionViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var questionSuggestionView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var exitIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        questionSuggestionView.delegate = self
        
        // Add tap gesture recognizer to the exit icon
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(exitIconTapped))
        exitIcon.isUserInteractionEnabled = true
        exitIcon.addGestureRecognizer(tapGesture)
    }
    
    private func setupUI() {
        questionSuggestionView.layer.cornerRadius = 10
        questionSuggestionView.layer.masksToBounds = true
        submitButton.isEnabled = false
    }
    
    @objc func exitIconTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Max 150 Characters" || textView.text.isEmpty {
            textView.text = "" // Clear the text
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        submitButton.isEnabled = !textView.text.isEmpty
    }

    @IBAction func submitSuggestion(_ sender: Any) {
        // Check if the suggestion text is not empty
        guard let questionText = questionSuggestionView.text, !questionText.isEmpty else {
            return
        }
        
        // Get the email from UserDefaults
        guard let email = UserDefaults.standard.string(forKey: "userEmail") else {
            print("Error: User email not found in UserDefaults")
            return
        }
        
        // Format the current date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        // Prepare the payload
        let payload: [String: Any] = [
            "email": email,
            "timestamp": dateString,
            "questionText": questionText
        ]
        
        // Send the suggestion to the server
        NetworkService.shared.request(endpoint: .questionsSuggestions, method: "POST", data: payload) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    // Handle success, if there's a response message
                    if let responseString = response["message"] as? String {
                        print("Response from the server: \(responseString)")
                    }
                    // Dismiss the view after successful submission
                    self.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    // Handle error
                    print("Error submitting suggestion: \(error.localizedDescription)")
                }
            }
        }
    }

}
