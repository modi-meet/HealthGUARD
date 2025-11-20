import Foundation
import Combine

class DroneDispatchManager: ObservableObject {
    static let shared = DroneDispatchManager()
    
    @Published var dispatchStatus: String = "Ready"
    @Published var isDroneEnRoute: Bool = false
    @Published var droneETA: TimeInterval = 0
    
    func triggerDroneDispatch() {
        guard !isDroneEnRoute else { return }
        
        print("Initiating Drone Dispatch...")
        dispatchStatus = "Contacting Drone Dispatch Service..."
        
        // Simulate API Call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.handleDispatchSuccess()
        }
    }
    
    private func handleDispatchSuccess() {
        isDroneEnRoute = true
        droneETA = 480 // 8 minutes
        dispatchStatus = "Drone Dispatched! ETA: 8 mins"
        print("Drone Dispatched successfully.")
        
        // Simulate ETA countdown
        startCountdown()
    }
    
    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if self.droneETA > 0 {
                self.droneETA -= 1
            } else {
                timer.invalidate()
                self.dispatchStatus = "Drone Arrived"
                self.isDroneEnRoute = false
            }
        }
    }
}
