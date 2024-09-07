//
//  DailyGoalAchievedView.swift
//  Push Stand
//
//  Created by Tony Russell on 8/25/24.
//

import UIKit

class DailyGoalAchievedView: UIView {

    @IBOutlet var dailyGoalAchievedView: UIVisualEffectView!
    @IBOutlet weak var shareNowButton: UIButton!
    // after sharing, dailyGoalAchievedView should disappear after
    @IBOutlet weak var skipButton: UIButton!
    // Add a closure that allows communication with the parent view controller
    var onDismiss: (() -> Void)?

    
   
    @IBAction func shareNow(_ sender: Any) {
        
    }
    
    
    @IBAction func skip(_ sender: Any) {
        onDismiss?()
    }
    
}
