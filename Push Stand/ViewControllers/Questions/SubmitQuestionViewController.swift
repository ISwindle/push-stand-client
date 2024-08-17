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
        guard let questionText = questionSuggestionView.text, !questionText.isEmpty else {
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        let payload: [String: Any] = [
            "email": CurrentUser.shared.email!,
            "timestamp": dateString,
            "questionText": questionText
        ]
        
        NetworkService.shared.request(endpoint: .questionsSuggestions, method: "POST", data: payload) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let responseString = response["message"] as? String {
                        print("Response from the server: \(responseString)")
                    }
                    self.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    print("Error submitting suggestion: \(error.localizedDescription)")
                }
            }
        }
    }
}
