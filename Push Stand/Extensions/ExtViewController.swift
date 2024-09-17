//
//  ExtViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 9/16/24.
//

import Foundation
import UIKit

extension UIViewController {
    func showLoading(on button: UIButton, isLoading: Bool, loader: UIActivityIndicatorView) {
        if isLoading {
            // Hide the button title and show the spinner
            button.setTitle("", for: .normal)
            loader.startAnimating()
            
            // Add the spinner to the button
            button.addSubview(loader)
            
            // Set spinner constraints to center inside the button
            loader.translatesAutoresizingMaskIntoConstraints = false
            loader.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
            loader.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
            button.isUserInteractionEnabled = false
        } else {
            // Stop the spinner and show the button text again
            loader.stopAnimating()
            loader.removeFromSuperview()
            button.setTitle("Next", for: .normal)
            button.isUserInteractionEnabled = true
        }
    }
}
