//
//  SubmitQuestionViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 2/17/24.
//

import UIKit

class SubmitQuestionViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var questionSuggestionView: UITextView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    
    let dailyQuestionSuggestionsEndpoint = "https://d516i8vkme.execute-api.us-east-1.amazonaws.com/develop/questions/suggestions"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        questionSuggestionView.delegate = self
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Check if the textView is being edited for the first time or based on your condition
        // You can also check for specific text to be cleared, like placeholder text
        if textView.text == "Max 150 Characters" || textView.text.isEmpty {
            textView.text = "" // Clear the text
        }
    }

    @IBAction func submitSuggestion(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        let submitQuestionQueryParams = ["email": CurrentUser.shared.uid!, "timestamp": dateString, "questionText": questionSuggestionView.text] as [String : String]
        let urlString = dailyQuestionSuggestionsEndpoint
        let url = NSURL(string: urlString)!
        let paramString = submitQuestionQueryParams
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, _, _ in
            do {
                if let jsonData = data {
                    if let jsonDataDict = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                        //                        self.log.mpUpdate("CLIENT_PUSH_NOTIFICATION", "status", "success")
                    }
                }
            } catch let err as NSError {
                // print(err.debugDescription)
                //                self.log.mpUpdate("CLIENT_PUSH_NOTIFICATION_FAILED", "status", "failed", "error", err.localizedDescription)
            }
        }
        task.resume()
        dismiss(animated: true, completion: nil)
    }
}
