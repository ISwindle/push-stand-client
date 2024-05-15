//
//  DataObjects.swift
//  Push Stand
//
//  Created by Isaac Swindle on 5/14/24.
//

import Foundation

struct DailyGoal: Decodable {
    let id: String
    let title: String
}

struct UserStreak: Decodable {
    let days: Int
}
