import SwiftUI

struct EmergencyGuideView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Blurred background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            // Pulsing Background Effect
            Circle()
                .fill(AppColors.critical.opacity(0.2))
                .scaleEffect(isAnimating ? 1.5 : 1.0)
                .opacity(isAnimating ? 0.0 : 1.0)
                .animation(
                    Animation.easeOut(duration: 2.0)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
                .frame(width: 300, height: 300)
            
            VStack(spacing: 32) {
                // Pulsing critical indicator
                ZStack {
                    Circle()
                        .fill(AppColors.critical)
                        .frame(width: 100, height: 100)
                        .shadow(color: AppColors.critical.opacity(0.6), radius: 20, x: 0, y: 0)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.white)
                }
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)
                
                VStack(spacing: 8) {
                    Text("CRITICAL HEALTH EVENT")
                        .font(AppFonts.title1)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Stay calm. Help is on the way.")
                        .font(AppFonts.headline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Emergency instructions (large, clear, numbered)
                VStack(alignment: .leading, spacing: 20) {
                    InstructionRow(number: 1, text: "Sit down immediately")
                    InstructionRow(number: 2, text: "Take slow, deep breaths")
                    InstructionRow(number: 3, text: "Emergency contacts have been notified")
                    InstructionRow(number: 4, text: "Drone dispatched - ETA 8 minutes")
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.15))
                        .background(.ultraThinMaterial)
                )
                .padding(.horizontal, 20)
                
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("I AM SAFE - DISMISS")
                        .font(AppFonts.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .padding(.top, 40)
        }
        .onAppear {
            isAnimating = true
        }
    }
}
