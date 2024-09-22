import UIKit
import MessageUI

/// A view that displays when a daily goal is achieved.
/// Conforms to `DismissableView` and `ShareableView` protocols to handle dismissal and sharing actions.
class DailyGoalAchievedView: UIView, DismissableView, ShareableView {
    
    // MARK: - Properties
    
    /// Closure to be called when the view should be dismissed.
    var onDismiss: (() -> Void)?
    
    /// Closure to be called when the share action is triggered.
    var onShareNow: (() -> Void)?
    
    // MARK: - Actions
    
    /// Action triggered when the "Share Now" button is tapped.
    /// - Parameter sender: The button that triggered the action.
    @IBAction func shareNow(_ sender: Any) {
        // Invoke the share action closure if it's set.
        onShareNow?()
    }
    
    /// Action triggered when the "Skip" button is tapped.
    /// - Parameter sender: The button that triggered the action.
    @IBAction func skip(_ sender: Any) {
        // Invoke the dismissal closure if it's set.
        onDismiss?()
    }
}
