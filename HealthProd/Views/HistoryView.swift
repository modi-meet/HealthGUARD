import SwiftUI
import CoreData

struct HistoryView: View {
    @State private var logs: [NSManagedObject] = []
    
    var body: some View {
        List {
            if logs.isEmpty {
                Text("No recent alerts.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(logs, id: \.self) { log in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(log.value(forKey: "severity") as? String ?? "Unknown")
                                .font(.headline)
                                .foregroundColor(colorForSeverity(log.value(forKey: "severity") as? String))
                            Spacer()
                            if let date = log.value(forKey: "timestamp") as? Date {
                                Text(date, style: .time)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        if let reason = log.value(forKey: "triggeredReason") as? String {
                            Text(reason)
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
        .navigationTitle("Alert History")
        .onAppear {
            logs = DataManager.shared.fetchRecentLogs()
        }
    }
    
    private func colorForSeverity(_ severity: String?) -> Color {
        switch severity {
        case "critical": return .red
        case "major": return .orange
        case "light": return .yellow
        default: return .primary
        }
    }
}
