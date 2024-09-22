import UIKit

/// A view that displays a bonus message related to standing activity.
/// Conforms to `DismissableView` to allow dismissal through a closure callback.
class StandBonusView: UIView, DismissableView {
    
    // MARK: - Properties
    
    /// Closure to be called when the view should be dismissed.
    var onDismiss: (() -> Void)?
    
    // MARK: - Actions
    
    /// Action triggered when the "Got It" button is tapped.
    /// - Parameter sender: The button that triggered the action.
    @IBAction func gotItTapped(_ sender: Any) {
        // Invoke the dismissal closure if it's set.
        onDismiss?()
    }
}
