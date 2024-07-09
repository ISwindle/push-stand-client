//
//  Haptic.swift
//  Push Stand
//
//  Created by Isaac Swindle on 7/7/24.
//

import UIKit

class Haptic {
    
    static func heavyTap() {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
    
}
