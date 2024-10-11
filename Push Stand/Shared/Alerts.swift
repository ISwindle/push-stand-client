import UIKit

class Alerts {
    static func showNotificationsDeniedAlert() {
        let alertController = UIAlertController(
            title: "Are You Sure?",
            message: "Without notifications, you'll miss daily reminders to STAND!",
            preferredStyle: .alert
        )

        let settingsAction = UIAlertAction(title: "Open Settings", style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)

        // Present the alert on the topmost view controller
        if let topController = UIApplication.shared.keyWindow?.rootViewController {
            topController.present(alertController, animated: true, completion: nil)
        }
    }
}
