import FirebaseMessaging
import Firebase
import FirebaseFirestore

class FirebaseTokenManager: NSObject, MessagingDelegate {
    
    // Singleton instance
    static let shared = FirebaseTokenManager()
    
    // Property to store the latest FCM token
    private(set) var fcmToken: String?

    private override init() {
        super.init()
        Messaging.messaging().delegate = self
    }

    // Function to retrieve the FCM token
    func retrieveToken() {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM token: \(error.localizedDescription)")
            } else if let token = token {
                self.fcmToken = token
                print("FCM Token retrieved: \(token)")
                // Optionally, update the token to the backend
                self.updateTokenOnBackend(token: token)
            }
        }
    }

    // MessagingDelegate function to handle token refresh
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        self.fcmToken = fcmToken
        print("New FCM Token: \(fcmToken)")
        UserDefaults.standard.set(fcmToken, forKey: "firebaseAuthToken")
        UserDefaults.standard.synchronize()
        // Optionally, update the token to the backend
        updateTokenOnBackend(token: fcmToken)
    }
    
    func clearToken() {
        self.fcmToken = nil
        print("FCM token cleared locally.")
    }

    // Optionally, send the token to your backend server
    private func updateTokenOnBackend(token: String) {
        // Check if user is signed in
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user is signed in. Token not sent to backend.")
            return
        }

        // Update Firebase token in the server
        SessionViewModel.shared.userManager.updateFirebaseToken(userId: userId, fcmToken: token) { result in
            switch result {
            case .success:
                print("Firebase token updated successfully for user: \(userId).")
            case .failure(let error):
                print("Failed to update Firebase token: \(error.localizedDescription)")
            }
        }
    }
}
