//
//  DailyGoalAchievedView.swift
//  Push Stand
//
//  Created by Tony Russell on 8/25/24.
//

import UIKit
import MessageUI

class DailyGoalAchievedView: UIView, DismissableView, ShareableView {
    
    // Add a closure that allows communication with the parent view controller
    var onDismiss: (() -> Void)?
    // Closure to handle the share action
    var onShareNow: (() -> Void)?
    
    @IBAction func shareNow(_ sender: Any) {
        onShareNow?()
    }
    
    @IBAction func skip(_ sender: Any) {
        onDismiss?()
    }
}
