
//
import UIKit

class HomeStatsViewController: UIViewController {
    
    @IBOutlet weak var pushStandButton: UIImageView!
    @IBOutlet weak var landingViewWithButton: UIView!
    @IBOutlet weak var pushStandTitle: UIView!
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
        self.tabBarController?.tabBar.alpha = 0
    }
    @IBAction func pushStand(_ sender: UITapGestureRecognizer) {
        self.tabBarController?.tabBar.isHidden = false
        UIView.animate(withDuration: 1.5, animations: {
            // This will start the animation to fade out the view
            self.landingViewWithButton.alpha = 0
            self.pushStandTitle.alpha = 0
            self.tabBarController?.tabBar.alpha = 1
      
        }) { (finished) in
            // Once the animation is finished, hide the view
            if finished {
                self.landingViewWithButton.isHidden = true
                self.pushStandTitle.isHidden = true
            }
            
        }
    }


}
