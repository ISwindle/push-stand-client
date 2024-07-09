//
//  SweepstakesViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 11/27/23.
//

import UIKit

class SweepstakesViewController: UIViewController {
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var unlockNow: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var exitView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initially hide the blurView
        blurView.isHidden = true
        blurView.layer.cornerRadius = 20
        blurView.layer.masksToBounds = true

        // Add target-action for the unlockNow button
        unlockNow.addTarget(self, action: #selector(unlockNowTapped), for: .touchUpInside)
        
        // Add tap gesture recognizer to the main view (self.view)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.view.addGestureRecognizer(tapGesture)
    }
            
    // Action method for unlockNow button
    @objc func unlockNowTapped() {
        // Unhide the blurView when the button is tapped
        blurView.isHidden = false
        
        // Hide the unlockNow button
        unlockNow.isHidden = true
        
        // Reset the scroll view to the top
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    // Action method for tap gesture recognizer
    @objc func viewTapped() {
        // Check if blurView is visible
        if !blurView.isHidden {
            // Hide the blurView when tapped outside of it
            blurView.isHidden = true
            
            // Show the unlockNow button
            unlockNow.isHidden = false
        }
    }
}
