import Foundation
import UIKit

class SignUpInitialPhoneViewController: UIViewController {
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var hyperlinkLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHyperlinkLabel()
    }
    
    private func setupHyperlinkLabel() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        hyperlinkLabel.isUserInteractionEnabled = true
        hyperlinkLabel.addGestureRecognizer(tapGesture)
        
        underlineText(in: hyperlinkLabel, textToUnderline: "Terms of Service")
        underlineText(in: hyperlinkLabel, textToUnderline: "Privacy Policy")
    }
    
    private func underlineText(in label: UILabel, textToUnderline: String) {
        guard let attributedText = label.attributedText else { return }
        
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
        let range = (attributedText.string as NSString).range(of: textToUnderline)
        
        if range.location != NSNotFound {
            mutableAttributedText.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            label.attributedText = mutableAttributedText
        }
    }

    @objc private func labelTapped(sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel else { return }
        
        let termsRange = (label.text! as NSString).range(of: "Terms of Service")
        let privacyRange = (label.text! as NSString).range(of: "Privacy Policy")

        if sender.didTapAttributedTextInLabel(label: label, inRange: termsRange) {
            navigateToViewController(TermsOfServiceViewController())
        } else if sender.didTapAttributedTextInLabel(label: label, inRange: privacyRange) {
            navigateToViewController(PrivacyPolicyViewController())
        }
    }
    
    private func navigateToViewController(_ viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func signInWithPhone(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let nextViewController = storyboard.instantiateViewController(withIdentifier: "SignUpPhoneViewController") as? SignUpPhoneViewController else { return }
        navigationController?.pushViewController(nextViewController, animated: true)
    }
}

