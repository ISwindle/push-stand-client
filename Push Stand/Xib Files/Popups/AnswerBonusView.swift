//
//  AnswerBonusView.swift
//  Push Stand
//
//  Created by Tony Russell on 8/25/24.
//

import UIKit

class AnswerBonusView: UIView, DismissableView {
   
    var onDismiss: (() -> Void)?
    
    @IBAction func gotIt(_ sender: Any) {
        onDismiss?()
    }
    
}
