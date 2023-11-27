import UIKit

class PushStandViewController: UIViewController {

    @IBOutlet weak var pushStandButton: UIImageView!
        @IBOutlet var pushStandGesture: UITapGestureRecognizer!

        override func viewDidLoad() {
            super.viewDidLoad()

            // Ensure the image view can receive touch events
            pushStandButton.isUserInteractionEnabled = true

            // Connect the tap gesture recognizer action
            pushStandGesture.addTarget(self, action: #selector(pushStand(_:)))
            pushStandButton.addGestureRecognizer(pushStandGesture)
        }

        @IBAction func pushStand(_ sender: UITapGestureRecognizer) {
            // Perform the action when the image view is tapped
            tabBarController?.replaceViewController(atIndex: 0, withViewControllerIdentifier: "HomeStatsViewController")
        }

    
}
