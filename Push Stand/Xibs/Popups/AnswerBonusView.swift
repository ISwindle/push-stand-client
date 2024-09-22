import UIKit

/// A view displayed when a bonus is awarded for answering a question.
/// Conforms to `DismissableView` protocol to handle dismissal actions.
class AnswerBonusView: UIView, DismissableView {
    
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
