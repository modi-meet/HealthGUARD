# HealthGuard iOS App

Health monitoring app with GPS location tracking and Firebase integration.

## Setup Instructions

### 1. Configure Firebase URL

The Firebase URL is stored in a separate configuration file that is **not committed to version control** for security.

**Steps:**
1. Copy the template file:
   ```bash
   cp HealthProd/Config.template.swift HealthProd/Config.swift
   ```

2. Open `HealthProd/Config.swift` and replace the placeholder with your actual Firebase URL:
   ```swift
   static let firebaseURL = "https://your-actual-project-id.firebaseio.com"
   ```

3. **IMPORTANT**: Never commit `Config.swift` to git. It's already in `.gitignore`.

### 2. Build and Run

Open `HelloWorld.xcodeproj` in Xcode and build the project.

## Security Notes

- `Config.swift` contains sensitive data and is excluded from git
- `Config.template.swift` is the template file that IS committed
- Always use `Config.firebaseURL` instead of hardcoding URLs
- Add other secrets to `Config.swift` as needed

## Features

- ✅ Real-time health monitoring (Heart Rate, SpO2, Blood Pressure)
- ✅ GPS location tracking for emergency alerts
- ✅ Firebase Realtime Database integration
- ✅ CoreData persistence for alert history
- ✅ Critical alert detection with drone dispatch
- ✅ Professional iOS 17 design
