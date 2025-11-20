import SwiftUI

struct EmergencyGuideView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var droneManager = DroneDispatchManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        Image(systemName: "cross.case.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                        Text("EMERGENCY GUIDE")
                            .font(.largeTitle)
                            .fontWeight(.black)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    
                    // Drone Status
                    if droneManager.isDroneEnRoute {
                        HStack {
                            Image(systemName: "airplane.circle.fill") // Drone icon proxy
                                .font(.largeTitle)
                            VStack(alignment: .leading) {
                                Text("Rescue Drone En Route")
                                    .font(.headline)
                                Text("ETA: \(Int(droneManager.droneETA / 60)) min")
                                    .font(.subheadline)
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    // Instructions
                    Group {
                        InstructionStep(number: 1, title: "Check Responsiveness", description: "Tap shoulders and shout 'Are you okay?'. If no response, proceed.")
                        InstructionStep(number: 2, title: "Call 911", description: "If not already done, call emergency services immediately.")
                        InstructionStep(number: 3, title: "Check Breathing", description: "Look for chest rise. Listen for breath sounds.")
                        InstructionStep(number: 4, title: "Start CPR", description: "If not breathing, push hard and fast in center of chest (100-120 bpm).")
                        InstructionStep(number: 5, title: "Wait for Drone", description: "Drone contains AED and Epipen. Follow audio instructions upon arrival.")
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct InstructionStep: View {
    let number: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text("\(number)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Circle().fill(Color.red))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}
