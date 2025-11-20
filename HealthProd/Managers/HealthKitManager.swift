import Foundation
import HealthKit
import Combine

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    
    // Published properties for UI updates
    @Published var currentHeartRate: Double = 0
    @Published var currentSpO2: Double = 0
    @Published var currentBP: String = "--/--"
    @Published var isAuthorized: Bool = false
    @Published var errorMessage: String?
    
    private var activeQueries: [HKQuery] = []
    
    init() {
        checkHealthKitAvailability()
    }
    
    private func checkHealthKitAvailability() {
        if !HKHealthStore.isHealthDataAvailable() {
            errorMessage = "HealthKit is not available on this device."
        }
    }
    
    // MARK: - Permissions
    
    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!
        ]
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            await MainActor.run {
                self.isAuthorized = true
                self.startMonitoring()
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "HealthKit authorization failed: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Monitoring
    
    func startMonitoring() {
        guard isAuthorized else { return }
        
        startHeartRateQuery()
        startSpO2Query()
        startBloodPressureQuery()
    }
    
    func stopMonitoring() {
        for query in activeQueries {
            healthStore.stop(query)
        }
        activeQueries.removeAll()
    }
    
    // MARK: - Queries
    
    private func startHeartRateQuery() {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        
        let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { [weak self] _, completionHandler, error in
            if let error = error {
                print("Heart Rate query error: \(error.localizedDescription)")
                return
            }
            self?.fetchLatestHeartRate()
            completionHandler()
        }
        
        healthStore.execute(query)
        activeQueries.append(query)
        healthStore.enableBackgroundDelivery(for: heartRateType, frequency: .immediate) { _, error in
            if let error = error {
                print("Failed to enable background delivery for HR: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchLatestHeartRate() {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { [weak self] _, samples, error in
            guard let self = self, let sample = samples?.first as? HKQuantitySample else { return }
            
            let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            
            DispatchQueue.main.async {
                self.currentHeartRate = heartRate
            }
        }
        
        healthStore.execute(query)
    }
    
    private func startSpO2Query() {
        guard let spo2Type = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation) else { return }
        
        let query = HKObserverQuery(sampleType: spo2Type, predicate: nil) { [weak self] _, completionHandler, error in
            if let error = error {
                print("SpO2 query error: \(error.localizedDescription)")
                return
            }
            self?.fetchLatestSpO2()
            completionHandler()
        }
        
        healthStore.execute(query)
        activeQueries.append(query)
        healthStore.enableBackgroundDelivery(for: spo2Type, frequency: .immediate) { _, error in
            if let error = error {
                print("Failed to enable background delivery for SpO2: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchLatestSpO2() {
        guard let spo2Type = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation) else { return }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: spo2Type, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { [weak self] _, samples, error in
            guard let self = self, let sample = samples?.first as? HKQuantitySample else { return }
            
            let spo2 = sample.quantity.doubleValue(for: HKUnit.percent()) * 100
            
            DispatchQueue.main.async {
                self.currentSpO2 = spo2
            }
        }
        
        healthStore.execute(query)
    }
    
    private func startBloodPressureQuery() {
        guard let systolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic),
              let diastolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic) else { return }
        
        // Observing systolic as a proxy for BP updates
        let query = HKObserverQuery(sampleType: systolicType, predicate: nil) { [weak self] _, completionHandler, error in
            if let error = error {
                print("BP query error: \(error.localizedDescription)")
                return
            }
            self?.fetchLatestBloodPressure()
            completionHandler()
        }
        
        healthStore.execute(query)
        activeQueries.append(query)
    }
    
    private func fetchLatestBloodPressure() {
        guard let systolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic),
              let diastolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic) else { return }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        // Fetch Systolic
        let systolicQuery = HKSampleQuery(sampleType: systolicType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { [weak self] _, samples, _ in
            guard let self = self, let systolicSample = samples?.first as? HKQuantitySample else { return }
            
            // Fetch Diastolic
            let diastolicQuery = HKSampleQuery(sampleType: diastolicType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, _ in
                guard let diastolicSample = samples?.first as? HKQuantitySample else { return }
                
                let systolic = systolicSample.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
                let diastolic = diastolicSample.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
                
                DispatchQueue.main.async {
                    self.currentBP = "\(Int(systolic))/\(Int(diastolic))"
                }
            }
            self.healthStore.execute(diastolicQuery)
        }
        
        healthStore.execute(systolicQuery)
    }
}
