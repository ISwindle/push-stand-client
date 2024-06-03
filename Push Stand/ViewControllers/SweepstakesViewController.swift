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
    @IBOutlet weak var gotIt: UIButton!
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
        
        // Add target-action for the gotIt button
        gotIt.addTarget(self, action: #selector(gotItTapped), for: .touchUpInside)
        
        // Add tap gesture recognizers to exitView and backgroundView
        let exitTapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        exitView.addGestureRecognizer(exitTapGesture)
        exitView.isUserInteractionEnabled = true
                
        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        backgroundView.addGestureRecognizer(backgroundTapGesture)
        backgroundView.isUserInteractionEnabled = true
        
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
    
    // Action method for gotIt button
    @objc func gotItTapped() {
        // Hide the blurView when the button is tapped
        blurView.isHidden = true
        
        // Show the unlockNow button
        unlockNow.isHidden = false
    }
    
    // Action method for tap gesture recognizer
    @objc func viewTapped() {
        // Call gotItTapped method when exitView or backgroundView is tapped
        gotItTapped()
    }
}
    
