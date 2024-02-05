//
//  OnboardingManager.swift
//  Push Stand
//
//  Created by Isaac Swindle on 2/1/24.
//

import Foundation

class OnboardingManager {
    static let shared = OnboardingManager()
    
    var onboardingData = OnboardingData.shared
    
    private init() {} // Private initializer to ensure singleton usage
}
