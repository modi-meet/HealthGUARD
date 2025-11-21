import SwiftUI
internal import _LocationEssentials
internal import CoreLocation


struct SettingsView: View {
    @State private var debugMode = false
    @State private var firebaseConnected = true // Mock status for now
    @StateObject private var locationManager = LocationManager.shared
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("General")) {
                    NavigationLink("User Profile") { Text("Profile Settings") }
                    NavigationLink("Notifications") { Text("Notification Settings") }
                    NavigationLink("Privacy & Security") { Text("Privacy Settings") }
                }
                
                Section(header: Text("Devices")) {
                    HStack {
                        Text("Apple Watch")
                        Spacer()
                        Text("Connected")
                            .foregroundColor(.green)
                    }
                    HStack {
                        Text("HealthGuard Drone")
                        Spacer()
                        Text("Standby")
                            .foregroundColor(.orange)
                    }
                }
                
                Section(header: Text("Debug & Testing")) {
                    Toggle("Debug Mode", isOn: $debugMode)
                    
                    if debugMode {
                        // Test alert button
                        Button(action: {
                            HealthAnalyzer.shared.triggerCriticalAlert(
                                heartRate: 165,
                                spO2: 82,
                                bloodPressure: "160/100"
                            )
                        }) {
                            HStack {
                                Text("🚨 Trigger Test Critical Alert")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                        }
                        .foregroundColor(.red)
                        
                        Button(action: {
                            HealthAnalyzer.shared.saveAlertToHistory(
                                severity: .light,
                                heartRate: 85,
                                spO2: 98,
                                bloodPressure: "120/80"
                            )
                        }) {
                            Text("Trigger Light Alert")
                        }
                        
                        // Firebase status
                        HStack {
                            Text("Firebase")
                            Spacer()
                            Circle()
                                .fill(firebaseConnected ? Color.green : Color.red)
                                .frame(width: 8, height: 8)
                            Text(firebaseConnected ? "Connected" : "Offline")
                                .font(AppFonts.caption)
                        }
                        
                        // CoreData status
                        Button("View CoreData Alerts Count") {
                            let count = DataManager.shared.fetchAllAlerts().count
                            print("📊 Total alerts in CoreData: \(count)")
                        }
                        
                        // Clear data
                        Button("🗑️ Clear All History") {
                            DataManager.shared.clearAllAlerts()
                        }
                        .foregroundColor(.red)
                        
                        Divider()
                        
                        // GPS Testing Section
                        Text("GPS Testing")
                            .font(AppFonts.headline)
                            .padding(.top, 8)
                        
                        // Current Location Display
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Current Location")
                                    .font(AppFonts.subheadline)
                                Spacer()
                                Button("Refresh") {
                                    LocationManager.shared.requestCurrentLocation { location in
                                        if let loc = location {
                                            print("📍 Refreshed location: (\(loc.coordinate.latitude), \(loc.coordinate.longitude))")
                                        } else {
                                            print("❌ Failed to refresh location")
                                        }
                                    }
                                }
                                .font(AppFonts.caption)
                            }
                            
                            if let location = locationManager.currentLocation {
                                Text("Lat: \(location.coordinate.latitude, specifier: "%.4f")")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(AppColors.secondaryText)
                                Text("Lon: \(location.coordinate.longitude, specifier: "%.4f")")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(AppColors.secondaryText)
                            } else {
                                Text("Not available")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.tertiaryText)
                            }
                        }
                        .padding(.vertical, 4)
                        
                        // Permission Status Indicator
                        HStack {
                            Text("Location Permission")
                                .font(AppFonts.subheadline)
                            Spacer()
                            Circle()
                                .fill(statusColor)
                                .frame(width: 8, height: 8)
                            Text(locationManager.authorizationStatusString())
                                .font(AppFonts.caption)
                                .foregroundColor(statusColor)
                        }
                    }
                }
                
                Section {
                    Text("Version 1.0.0 (Build 1)")
                        .font(AppFonts.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    private var statusColor: Color {
        switch locationManager.authorizationStatus {
        case .authorizedAlways:
            return .green
        case .authorizedWhenInUse:
            return .orange
        case .denied, .restricted:
            return .red
        case .notDetermined:
            return .gray
        @unknown default:
            return .gray
        }
    }
}
