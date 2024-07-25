//
//  SweepstakesViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 11/27/23.
//

import UIKit

class SweepstakesViewController: UIViewController {
    
    @IBOutlet weak var unlockNow: UIButton!
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var sweepstakesImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSweepstakes()
    }
    
    private func setupSweepstakes() {
        // Save the final position of the image
        let finalPosition = self.sweepstakesImage.frame.origin
        
        // Set the image to start above its final position
        self.sweepstakesImage.frame.origin.y -= 30
        
        // Set the image to be fully transparent initially
        self.sweepstakesImage.alpha = 0.0
        
        // Animate the image sliding down and fading in
        UIView.animate(withDuration: 2.0, delay: 0, options: [.curveEaseOut], animations: {
            self.sweepstakesImage.frame.origin = finalPosition
            self.sweepstakesImage.alpha = 1.0 // Use Constants.fullAlpha if you have defined it
        })
    }
}
