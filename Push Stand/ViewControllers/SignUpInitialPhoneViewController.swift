//
//  TestViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 10/30/23.
//

import Foundation
import UIKit

class SignUpInitialPhoneViewController: UIViewController {
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var hyperlinkLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        hyperlinkLabel.isUserInteractionEnabled = true
        hyperlinkLabel.addGestureRecognizer(tapGesture)
        
        // Underline both "Terms of Service" and "Privacy Policy" text within the existing label
        if let attributedText = hyperlinkLabel.attributedText {
            let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
            
            // Underline "Terms of Service"
            let termsRange = (attributedText.string as NSString).range(of: "Terms of Service")
            mutableAttributedText.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: termsRange)
            
            // Underline "Privacy Policy"
            let privacyRange = (attributedText.string as NSString).range(of: "Privacy Policy")
            mutableAttributedText.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: privacyRange)
            
            // Apply modified attributed text to the label
            hyperlinkLabel.attributedText = mutableAttributedText
        }
    }

    @objc func labelTapped(sender: UITapGestureRecognizer) {
        if let label = sender.view as? UILabel {
            let termsRange = (label.text! as NSString).range(of: "Terms of Service")
            let privacyRange = (label.text! as NSString).range(of: "Privacy Policy")

            if sender.didTapAttributedTextInLabel(label: label, inRange: termsRange) {
                // Handle Terms of Service tap
                let termsVC = TermsOfServiceViewController()
                navigationController?.pushViewController(termsVC, animated: true)
            } else if sender.didTapAttributedTextInLabel(label: label, inRange: privacyRange) {
                // Handle Privacy Policy tap
                let privacyVC = PrivacyPolicyViewController()
                navigationController?.pushViewController(privacyVC, animated: true)
            }
        }
    }
    
    
    @IBAction func signInWithPhone(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "SignUpPhoneViewController") as! SignUpPhoneViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }

}

extension UITapGestureRecognizer {
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        guard let attributedText = label.attributedText else { return false }
        
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: .zero)
        let textStorage = NSTextStorage(attributedString: attributedText)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.size = label.bounds.size
        
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (label.bounds.size.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (label.bounds.size.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}
