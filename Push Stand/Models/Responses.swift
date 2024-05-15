//
//  Responses.swift
//  Push Stand
//
//  Created by Isaac Swindle on 5/14/24.
//

import Foundation


struct EmailCheckResponse: Decodable {
    let email_exists: Bool
}

struct DailyQuestionResponse: Codable {
    let question: String
    let truePercentage: Int
    let falsePercentage: Int
}

struct StreakResponse: Codable {
    let streak_count: Int
}

