//
//  SweepstakesViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 11/27/23.
//

import UIKit

class SweepstakesViewController: UIViewController {
    
    
    @IBOutlet weak var explainLabel: UILabel!
    @IBOutlet weak var earnLabel: UILabel!
    
    override func viewDidLoad() {
            super.viewDidLoad()
            
            // Initially set the label's alpha to 0 (completely transparent)
            explainLabel.alpha = 0
            earnLabel.alpha = 0
            
            // Animate the label's alpha property to 1 (fully visible)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(withDuration: 1.5) {
                self.explainLabel.alpha = 1
            }
        }
        
        // Animate the second label to fade in with a delay of 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            UIView.animate(withDuration: 1.5) {
                self.earnLabel.alpha = 1
            }
        }
    }
}
