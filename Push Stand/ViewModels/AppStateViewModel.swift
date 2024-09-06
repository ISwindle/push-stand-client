import Foundation
import UIKit
import Combine

class AppStateViewModel: ObservableObject {
    @Published var currentDay: Date = Date()
    var newDay: Bool = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        scheduleMidnightReset()
    }

    private func scheduleMidnightReset() {
        let timeInterval = timeUntilNextMidnight()
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            self?.resetAppState()
            self?.scheduleMidnightReset()  // Schedule the next reset
        }
    }

    private func timeUntilNextMidnight() -> TimeInterval {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let pacificTimeZone = TimeZone(identifier: "America/Los_Angeles")!

        // Get current date components in Pacific Time
        var components = calendar.dateComponents(in: pacificTimeZone, from: now)
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.nanosecond = 0

        // Calculate the next midnight
        let todayMidnight = calendar.date(from: components)!
        let nextMidnight = calendar.date(byAdding: .day, value: 1, to: todayMidnight)!
        return nextMidnight.timeIntervalSince(now)
    }

    private func resetAppState() {
        // Reset your app's state here
        currentDay = Date()
    }
    
    public func setAppBadgeCount(to count: Int) {
        UIApplication.shared.applicationIconBadgeNumber = count
    }
}
