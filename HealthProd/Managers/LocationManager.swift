import Foundation
internal import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private var locationCompletionHandlers: [(CLLocation?) -> Void] = []
    private var locationRequestTimer: Timer?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Battery optimization
        authorizationStatus = locationManager.authorizationStatus
        
        // Request Always authorization for background access
        if authorizationStatus == .notDetermined {
            print("📍 Requesting Always location authorization...")
            locationManager.requestAlwaysAuthorization()
        } else if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            print("✅ Location authorization granted, starting monitoring")
            locationManager.startUpdatingLocation()
        }
    }
    
    // MARK: - Public Methods
    
    /// Request current location with async callback and 5-second timeout
    func requestCurrentLocation(completion: @escaping (CLLocation?) -> Void) {
        print("📍 Requesting current location...")
        
        // If we already have a recent location (within last 30 seconds), return it immediately
        if let location = currentLocation, location.timestamp.timeIntervalSinceNow > -30 {
            print("✅ Using cached location: (\(location.coordinate.latitude), \(location.coordinate.longitude))")
            completion(location)
            return
        }
        
        // Add completion handler to queue
        locationCompletionHandlers.append(completion)
        
        // Start location updates if not already running
        locationManager.startUpdatingLocation()
        
        // Set 5-second timeout
        locationRequestTimer?.invalidate()
        locationRequestTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            print("⚠️ Location request timed out after 5 seconds")
            self.completeLocationRequests(with: self.currentLocation)
        }
    }
    
    private func completeLocationRequests(with location: CLLocation?) {
        locationRequestTimer?.invalidate()
        locationRequestTimer = nil
        
        let handlers = locationCompletionHandlers
        locationCompletionHandlers.removeAll()
        
        for handler in handlers {
            handler(location)
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.currentLocation = location
            print("📍 Location updated: (\(location.coordinate.latitude), \(location.coordinate.longitude))")
            
            // Complete any pending location requests
            if let self = self, !self.locationCompletionHandlers.isEmpty {
                self.completeLocationRequests(with: location)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error.localizedDescription)")
        
        // Complete pending requests with nil
        if !locationCompletionHandlers.isEmpty {
            completeLocationRequests(with: nil)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        DispatchQueue.main.async { [weak self] in
            self?.authorizationStatus = status
            
            switch status {
            case .notDetermined:
                print("📍 Location authorization: Not Determined")
            case .restricted:
                print("⚠️ Location authorization: Restricted")
            case .denied:
                print("❌ Location authorization: Denied")
            case .authorizedAlways:
                print("✅ Location authorization: Always")
                manager.startUpdatingLocation()
            case .authorizedWhenInUse:
                print("⚠️ Location authorization: When In Use (Always recommended for background access)")
                manager.startUpdatingLocation()
            @unknown default:
                print("⚠️ Location authorization: Unknown status")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    func authorizationStatusString() -> String {
        switch authorizationStatus {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorizedAlways: return "Always"
        case .authorizedWhenInUse: return "When In Use"
        @unknown default: return "Unknown"
        }
    }
    
    func authorizationStatusColor() -> String {
        switch authorizationStatus {
        case .authorizedAlways: return "green"
        case .authorizedWhenInUse: return "orange"
        case .denied, .restricted: return "red"
        case .notDetermined: return "gray"
        @unknown default: return "gray"
        }
    }
}
