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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    @objc private func pushStand(_ sender: UITapGestureRecognizer) {
        Haptic.heavyTap()
        
        self.tabBarController?.tabBar.isHidden = false
        
        // Perform the action when the image view is tapped
        guard let tabBarController = self.tabBarController else {
            print("Tab bar controller is nil")
            return
        }
        
        tabBarController.replaceViewController(atIndex: 0, withViewControllerIdentifier: "HomeStatsViewController")
    }
}
