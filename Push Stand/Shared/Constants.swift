//
//  Constants.swift
//  Push Stand
//
//  Created by Isaac Swindle on 7/7/24.
//

import Foundation

class Constants {
    
    static let streakBarMin = 0
    static let streakBarMax = 10
    static let standStreakMin = 0
    static let standStreakMax = 10
    static let questionStreakMin = 0
    static let questionStreakMax = 10
    static let whiteStarImg = "White-Star"
    static let blueStarImg = "Blue-Star"
    static let redStarImg = "Red-Star"
    static let fivePoints = "5 Points"
    static let zeroAlpha = CGFloat(0)
    static let fullAlpha = CGFloat(1)
    static let mainStoryboard = "Main"
    static let standPoints = "1"
    static let standStreakHitPoints = "5"
    static let questionPoints = "2"
    static let questionStreakHitPoints = "10"
    static let questionUserDefaultsKey = "question-" + Time.getDateFormatted()
    
    class UserDefaultsKeys {
        static let userSignedIn = "usersignedin"
        static let userId = "userId"
    }
    
    class Images {
        static let yeaSelected = "yea-selected"
        static let naySelected = "nay-selected"
        static let yeaUnselected = "yea-unselected"
        static let nayUnselected = "nay-unselected"
    }
    
    class URL {
        static let privacy = "https://pushstand.com/privacy.html"
        static let termsOfService = "https://pushstand.com/terms.html"
    }
}
