import Network
import UIKit

class NetworkMonitor {
    
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    
    var isConnected: Bool = true
    var isNetworkPresented = false // Track if the NetworkErrorViewController is presented
    
    private init() {
        // Start monitoring network changes
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.updateNetworkStatus(path)
            }
        }
        monitor.start(queue: queue)
    }
    
    /// Handle network status changes
    private func updateNetworkStatus(_ path: NWPath) {
        isConnected = path.status == .satisfied
        
        if isConnected {
            dismissNoConnectionVC()
        } else {
            presentNoConnectionVC()
        }
    }
    
    /// Present the NetworkErrorViewController when no connection is available
    private func presentNoConnectionVC() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first,
              let rootVC = window.rootViewController,
              !isNetworkPresented else {
            return
        }
        
        let noConnectionVC = NetworkErrorViewController()
        noConnectionVC.modalPresentationStyle = .fullScreen
        
        // Present the no connection view controller
        rootVC.present(noConnectionVC, animated: true, completion: nil)
        isNetworkPresented = true
    }
    
    /// Dismiss the NetworkErrorViewController when the network is restored
    private func dismissNoConnectionVC() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first,
              let rootVC = window.rootViewController else {
            return
        }
        
        // Dismiss the NetworkErrorViewController if it was presented
        if isNetworkPresented {
            rootVC.dismiss(animated: true, completion: nil)
            isNetworkPresented = false
        }
    }
}
