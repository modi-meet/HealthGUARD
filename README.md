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

# Screenshots:

### User display - 
<img width="1280" height="945" alt="image" src="https://github.com/user-attachments/assets/98f0d433-b256-454e-b9c6-ab49d53279a5" />

### Settings available - 
<img width="1280" height="709" alt="image" src="https://github.com/user-attachments/assets/8aab6a92-0ca8-4000-8c9a-32d347477fb4" />

### Emergency Contacts - 
<img width="1280" height="800" alt="image" src="https://github.com/user-attachments/assets/18386827-d9c4-4689-a4b8-353e95cd77b4" />

# Continuous Monitoring

## Dynamic UI based on User Health conditions

### case 1 : Light changes - 
<img width="1280" height="664" alt="image" src="https://github.com/user-attachments/assets/e3beefd8-3c6c-4bf9-bff2-b34294504674" />

### case 2 : Major health conditions (Sends alerts to emergency contacts) - 
<img width="1280" height="665" alt="image" src="https://github.com/user-attachments/assets/98e2200e-5afa-4635-9314-49655823c3b1" />

### case 3 : Severe Health condition
<img width="1600" height="1089" alt="image" src="https://github.com/user-attachments/assets/5fb1f6d4-ce23-41f4-b354-58c43f4e349d" />



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
