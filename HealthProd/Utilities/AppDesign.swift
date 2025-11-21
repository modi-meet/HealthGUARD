import SwiftUI

struct AppFonts {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title1 = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
}

struct AppColors {
    // Primary colors
    static let primary = Color(red: 0/255, green: 122/255, blue: 255/255) // iOS Blue
    static let critical = Color(red: 255/255, green: 59/255, blue: 48/255) // Emergency Red
    static let warning = Color(red: 255/255, green: 149/255, blue: 0/255) // Warning Orange
    static let success = Color(red: 52/255, green: 199/255, blue: 89/255) // Success Green
    
    // Backgrounds
    static let background = Color(uiColor: .systemBackground)
    static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
    static let tertiaryBackground = Color(uiColor: .tertiarySystemBackground)
    
    // Text
    static let text = Color(uiColor: .label)
    static let secondaryText = Color(uiColor: .secondaryLabel)
    static let tertiaryText = Color(uiColor: .tertiaryLabel)
}
