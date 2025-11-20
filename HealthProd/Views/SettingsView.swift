import SwiftUI
import Foundation
import Combine

struct SettingsView: View {
    @AppStorage("isMonitoringEnabled") private var isMonitoringEnabled = true
    @AppStorage("userName") private var userName = "User"
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Monitoring")) {
                    Toggle("Enable Health Monitoring", isOn: $isMonitoringEnabled)
                        .onChange(of: isMonitoringEnabled) { newValue in
                            if newValue {
                                HealthKitManager.shared.startMonitoring()
                            } else {
                                HealthKitManager.shared.stopMonitoring()
                            }
                        }
                }
                
                Section(header: Text("Profile")) {
                    TextField("Your Name", text: $userName)
                }
                
                Section(header: Text("Emergency")) {
                    NavigationLink(destination: ContactManagementView()) {
                        Text("Manage Emergency Contacts")
                    }
                    NavigationLink(destination: HistoryView()) {
                        Text("Alert History")
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (Hackathon Build)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
