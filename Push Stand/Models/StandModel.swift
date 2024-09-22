import SwiftUI
import Combine

class StandModel: ObservableObject {
    
    // Singleton instance
    static let shared = StandModel()
    
    // Properties that change every day
    @Published var dailyGoal: Int = 0
    @Published var americansStandingToday: Int = 0
    @Published var yesterdaysStanding: Int = 0
    @Published var myPoints: Int = 0
    
    // Aggregate stats
    @Published var myStandStreak: Int = 0
    @Published var myAnswerStreak: Int = 0
    @Published var myTotalStands: Int = 0
    @Published var usaTotalStands: Int = 0
    
    // Private initializer to ensure only one instance is created
    private init() {}
    
    
}
