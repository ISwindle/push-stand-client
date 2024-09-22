import UIKit

/// A view displayed to indicate that points have been accumulated.
/// Conforms to `DismissableView` protocol to handle dismissal actions.
class BuildUpPointsView: UIView, DismissableView {
    
    // MARK: - Properties
    
    /// Closure to be called when the view should be dismissed.
    var onDismiss: (() -> Void)?
    
    // MARK: - Actions
    
    /// Action triggered when the "Got It" button is tapped.
    /// - Parameter sender: The button that triggered the action.
    @IBAction func gotIt(_ sender: Any) {
        // Invoke the dismissal closure if it's set.
        onDismiss?()
    }
}
