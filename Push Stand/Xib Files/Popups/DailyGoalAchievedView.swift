//
//  DailyGoalAchievedView.swift
//  Push Stand
//
//  Created by Tony Russell on 8/25/24.
//

import UIKit

class DailyGoalAchievedView: UIView, DismissableView {


    // Add a closure that allows communication with the parent view controller
    var onDismiss: (() -> Void)?
   
    @IBAction func shareNow(_ sender: Any) {
        
    }
    
    
    @IBAction func skip(_ sender: Any) {
        onDismiss?()
    }
    
}
