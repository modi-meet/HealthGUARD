import SwiftUI
internal import _LocationEssentials

struct DashboardView: View {
    @StateObject private var healthAnalyzer = HealthAnalyzer.shared
    @StateObject private var healthKitManager = HealthKitManager.shared
    @State private var showEmergencyGuide = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // BRANDED HEADER
                        HStack(spacing: 12) {
                            Image(systemName: "shield.lefthalf.filled.badge.checkmark")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(AppColors.primary)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("HealthGuard")
                                    .font(AppFonts.largeTitle)
                                    .fontWeight(.bold)
                                
                                Text("Your Life, Monitored. Your Safety, Assured.")
                                    .font(AppFonts.subheadline)
                                    .foregroundColor(AppColors.secondaryText)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // STATUS CARD
                        VStack(spacing: 16) {
                            Text("Current Status")
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.secondaryText)
                            
                            Text(healthAnalyzer.currentStatus.description.uppercased())
                                .font(AppFonts.title1)
                                .fontWeight(.black)
                                .foregroundColor(statusColor)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(statusColor.opacity(0.1))
                                )
                            
                            if healthAnalyzer.currentStatus == .critical {
                                Button(action: { showEmergencyGuide = true }) {
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                        Text("VIEW EMERGENCY GUIDE")
                                    }
                                    .font(AppFonts.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(AppColors.critical)
                                    .cornerRadius(16)
                                    .shadow(color: AppColors.critical.opacity(0.4), radius: 10, x: 0, y: 5)
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(AppColors.secondaryBackground)
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                        )
                        .padding(.horizontal, 20)
                        
                        // VITALS GRID
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            VitalCard(
                                title: "Heart Rate",
                                value: "\(Int(healthKitManager.currentHeartRate)) BPM",
                                icon: "heart.fill",
                                severity: healthAnalyzer.currentStatus
                            )
                            
                            VitalCard(
                                title: "Blood Oxygen",
                                value: "\(Int(healthKitManager.currentSpO2))%",
                                icon: "lungs.fill",
                                severity: healthAnalyzer.currentStatus
                            )
                            
                            VitalCard(
                                title: "Blood Pressure",
                                value: "120/80",
                                icon: "waveform.path.ecg",
                                severity: .normal
                            )
                            
                            VitalCard(
                                title: "Stress Level",
                                value: "Low",
                                icon: "brain.head.profile",
                                severity: .normal
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Recent Activity / Map Placeholder
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Live Location Tracking")
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.text)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(AppColors.secondaryBackground)
                                    .frame(height: 150)
                                
                                if let location = LocationManager.shared.currentLocation {
                                    VStack {
                                        Image(systemName: "location.fill")
                                            .font(.title)
                                            .foregroundColor(AppColors.primary)
                                        Text("Lat: \(location.coordinate.latitude, specifier: "%.4f")")
                                        Text("Lon: \(location.coordinate.longitude, specifier: "%.4f")")
                                    }
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.secondaryText)
                                } else {
                                    Text("Locating...")
                                        .font(AppFonts.body)
                                        .foregroundColor(AppColors.secondaryText)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showEmergencyGuide) {
                EmergencyGuideView()
            }
        }
    }
    
    var statusColor: Color {
        switch healthAnalyzer.currentStatus {
        case .critical: return AppColors.critical
        case .major: return AppColors.warning
        case .light: return AppColors.success
        case .normal: return AppColors.primary
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
