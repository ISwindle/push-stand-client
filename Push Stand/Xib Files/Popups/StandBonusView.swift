//
//  StandBonusView.swift
//  Push Stand
//
//  Created by Tony Russell on 8/25/24.
//

import UIKit

class StandBonusView: UIView {

    // Add a closure that allows communication with the parent view controller
    var onDismiss: (() -> Void)?

    
    @IBAction func gotItTapped(_ sender: Any) {
        onDismiss?()
    }
    
}
