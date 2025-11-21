import SwiftUI
import CoreData

// MARK: - Vital Card
struct VitalCard: View {
    let title: String
    let value: String
    let icon: String
    let severity: HealthStatus
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(severityColor)
                
                Spacer()
                
                // Severity badge
                Text(severity.rawValue.uppercased())
                    .font(AppFonts.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(severityColor)
                    .cornerRadius(12)
            }
            
            Text(title)
                .font(AppFonts.footnote)
                .foregroundColor(AppColors.secondaryText)
            
            Text(value)
                .font(AppFonts.title1)
                .fontWeight(.bold)
                .foregroundColor(AppColors.text)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.secondaryBackground)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
    }
    
    var severityColor: Color {
        switch severity {
        case .critical: return AppColors.critical
        case .major: return AppColors.warning
        case .light: return AppColors.success
        case .normal: return AppColors.primary
        }
    }
}

// MARK: - Vital Snapshot (for history cards)
struct VitalSnapshot: View {
    let icon: String
    let value: String
    let unit: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(AppColors.secondaryText)
            
            Text(value)
                .font(AppFonts.subheadline)
                .fontWeight(.semibold)
            
            Text(unit)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.secondaryText)
        }
    }
}

// MARK: - Instruction Row (for Emergency Guide)
struct InstructionRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppColors.critical.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Text("\(number)")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.critical)
            }
            
            Text(text)
                .font(AppFonts.body)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}
