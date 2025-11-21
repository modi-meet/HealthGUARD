import SwiftUI
import CoreData

struct HistoryView: View {
    @FetchRequest(
        entity: NSEntityDescription.entity(forEntityName: "AlertLog", in: DataManager.shared.container.viewContext)!,
        sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: false)],
        animation: .default
    ) private var alerts: FetchedResults<NSManagedObject>
    
    var criticalAlerts: [NSManagedObject] {
        alerts.filter { ($0.value(forKey: "severity") as? String) == "critical" }
    }
    
    var otherAlerts: [NSManagedObject] {
        alerts.filter { ($0.value(forKey: "severity") as? String) != "critical" }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                if alerts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 48))
                            .foregroundColor(AppColors.secondaryText)
                        Text("No History Yet")
                            .font(AppFonts.title2)
                            .foregroundColor(AppColors.secondaryText)
                        Text("Alerts and critical events will appear here.")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.tertiaryText)
                    }
                } else {
                    List {
                        // Critical alerts section (RED background, prominent)
                        if !criticalAlerts.isEmpty {
                            Section(header: Text("⚠️ CRITICAL ALERTS")
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.critical)
                                .padding(.vertical, 8)
                            ) {
                                ForEach(criticalAlerts, id: \.self) { alert in
                                    CriticalAlertCardView(alert: alert)
                                        .listRowInsets(EdgeInsets())
                                        .listRowBackground(Color.clear)
                                        .padding(.vertical, 8)
                                }
                                .onDelete(perform: deleteCriticalAlerts)
                            }
                        }
                        
                        // All alerts section
                        if !otherAlerts.isEmpty {
                            Section(header: Text("Recent Alerts")
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.text)
                                .padding(.vertical, 8)
                            ) {
                                ForEach(otherAlerts, id: \.self) { alert in
                                    AlertCardView(alert: alert)
                                        .listRowInsets(EdgeInsets())
                                        .listRowBackground(Color.clear)
                                        .padding(.vertical, 4)
                                }
                                .onDelete(perform: deleteOtherAlerts)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !alerts.isEmpty {
                        Button("Clear All") {
                            DataManager.shared.clearAllAlerts()
                        }
                        .foregroundColor(AppColors.critical)
                    }
                }
            }
        }
    }
    
    private func deleteCriticalAlerts(offsets: IndexSet) {
        withAnimation {
            offsets.map { criticalAlerts[$0] }.forEach(DataManager.shared.container.viewContext.delete)
            DataManager.shared.saveContext()
        }
    }
    
    private func deleteOtherAlerts(offsets: IndexSet) {
        withAnimation {
            offsets.map { otherAlerts[$0] }.forEach(DataManager.shared.container.viewContext.delete)
            DataManager.shared.saveContext()
        }
    }
}

// Helper view for displaying alert cards
struct AlertCardView: View {
    let alert: NSManagedObject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Severity Badge
                Text((alert.value(forKey: "severity") as? String ?? "Unknown").uppercased())
                    .font(AppFonts.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(colorForSeverity(alert.value(forKey: "severity") as? String))
                    .cornerRadius(8)
                
                Spacer()
                
                if let date = alert.value(forKey: "timestamp") as? Date {
                    Text(date, style: .time)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.secondaryText)
                }
            }
            
            HStack(spacing: 16) {
                VitalSnapshot(icon: "heart.fill", value: String(format: "%.0f", alert.value(forKey: "heartRate") as? Double ?? 0), unit: "BPM")
                VitalSnapshot(icon: "lungs.fill", value: String(format: "%.0f", alert.value(forKey: "spO2") as? Double ?? 0), unit: "%")
                VitalSnapshot(icon: "waveform.path.ecg", value: alert.value(forKey: "bloodPressure") as? String ?? "--/--", unit: "mmHg")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.secondaryBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(colorForSeverity(alert.value(forKey: "severity") as? String).opacity(0.3), lineWidth: 1)
        )
    }
    
    private func colorForSeverity(_ severity: String?) -> Color {
        switch severity {
        case "critical": return AppColors.critical
        case "major": return AppColors.warning
        case "light": return AppColors.success
        default: return AppColors.primary
        }
    }
}

struct CriticalAlertCardView: View {
    let alert: NSManagedObject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundColor(AppColors.critical)
                
                Text("CRITICAL ALERT")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.critical)
                
                Spacer()
                
                if let date = alert.value(forKey: "timestamp") as? Date {
                    Text(date, style: .date)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.secondaryText)
                }
            }
            
            Divider()
            
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Heart Rate")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.secondaryText)
                    Text("\(Int(alert.value(forKey: "heartRate") as? Double ?? 0)) BPM")
                        .font(AppFonts.title2)
                        .fontWeight(.bold)
                }
                
                VStack(alignment: .leading) {
                    Text("SpO2")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.secondaryText)
                    Text("\(Int(alert.value(forKey: "spO2") as? Double ?? 0))%")
                        .font(AppFonts.title2)
                        .fontWeight(.bold)
                }
                
                VStack(alignment: .leading) {
                    Text("BP")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.secondaryText)
                    Text(alert.value(forKey: "bloodPressure") as? String ?? "--")
                        .font(AppFonts.title2)
                        .fontWeight(.bold)
                }
            }
            
            if let droneDispatched = alert.value(forKey: "droneDispatched") as? Bool, droneDispatched {
                HStack {
                    Image(systemName: "airplane.departure")
                    Text("Drone Dispatched")
                }
                .font(AppFonts.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppColors.critical)
                .cornerRadius(20)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: AppColors.critical.opacity(0.25), radius: 16, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.critical, lineWidth: 2)
        )
    }
}
