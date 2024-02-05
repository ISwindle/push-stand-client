//
//  OnboardingData.swift
//  Push Stand
//
//  Created by Isaac Swindle on 2/1/24.
//

import Foundation

class OnboardingData {
    static let shared = OnboardingData()
    
    var username: String?
    var email: String?
    var password: String?
    var phoneNumber: String?
    var rememberMe: Bool = false
    var birthday: Date?
    var isAgeConfirmed: Bool = false
    var reminderTime: Date?
    
    private init() {}
}
