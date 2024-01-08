//
//  SweepstakesViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 11/27/23.
//

import UIKit

class SweepstakesViewController: UIViewController {
    
    @IBOutlet weak var topFill: UIView!
    @IBOutlet weak var titleFill: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyGradient(to: topFill, colors: [UIColor.red.cgColor, UIColor.white.cgColor, UIColor.blue.cgColor])
        applyGradient(to: titleFill, colors: [UIColor.red.cgColor, UIColor.white.cgColor, UIColor.blue.cgColor])
    }
    
    func applyGradient(to view: UIView, colors: [CGColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
}

//had to apply a small view called "Help Constrain Top Fill" to make it work for the Top Fill.  The problem isn't in the coding, it's something funky with constraining.  I think there's gotta be a better way for top titles to fill all the way like we want with less constraints, less work, and possibly less problems - talk to Isaac
