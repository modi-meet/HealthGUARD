import SwiftUI

struct DashboardView: View {
    @StateObject private var healthKitManager = HealthKitManager.shared
    @StateObject private var healthAnalyzer = HealthAnalyzer.shared
    @StateObject private var droneManager = DroneDispatchManager.shared
    
    @State private var showEmergencyGuide = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Status Header
                    StatusHeaderView(status: healthAnalyzer.currentStatus)
                    
                    // Vitals Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        VitalCard(title: "Heart Rate", value: String(format: "%.0f", healthKitManager.currentHeartRate), unit: "BPM", icon: "heart.fill", color: .red)
                        VitalCard(title: "SpO2", value: String(format: "%.0f", healthKitManager.currentSpO2), unit: "%", icon: "lungs.fill", color: .blue)
                        VitalCard(title: "Blood Pressure", value: healthKitManager.currentBP, unit: "mmHg", icon: "waveform.path.ecg", color: .purple)
                    }
                    .padding()
                    
                    // Emergency Actions
                    if healthAnalyzer.currentStatus == .critical {
                        VStack(spacing: 16) {
                            Text("CRITICAL EMERGENCY DETECTED")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            Button(action: {
                                showEmergencyGuide = true
                            }) {
                                Label("View Emergency Guide", systemImage: "exclamationmark.triangle.fill")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .cornerRadius(10)
                            }
                            
                            if droneManager.isDroneEnRoute {
                                VStack {
                                    Text(droneManager.dispatchStatus)
                                        .font(.headline)
                                    Text("ETA: \(Int(droneManager.droneETA / 60)) min \(Int(droneManager.droneETA.truncatingRemainder(dividingBy: 60))) sec")
                                        .font(.subheadline)
                                        .monospacedDigit()
                                }
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).stroke(Color.red, lineWidth: 2))
                        .padding()
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("HealthGuard")
            .sheet(isPresented: $showEmergencyGuide) {
                EmergencyGuideView()
            }
            .onAppear {
                Task {
                    await healthKitManager.requestAuthorization()
                }
            }
        }
    }
}

struct StatusHeaderView: View {
    let status: HealthStatus
    
    var body: some View {
        VStack {
            Image(systemName: statusIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(status.color)
            
            Text(status.rawValue.uppercased())
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(status.color)
            
            Text(status.description)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(status.color.opacity(0.1))
        .cornerRadius(15)
        .padding()
    }
    
    var statusIcon: String {
        switch status {
        case .normal: return "checkmark.circle.fill"
        case .light: return "exclamationmark.circle.fill"
        case .major: return "exclamationmark.triangle.fill"
        case .critical: return "cross.circle.fill"
        }
    }
}

struct VitalCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(alignment: .lastTextBaseline) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}
