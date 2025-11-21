import Foundation
import UIKit
import CoreData
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    let container: NSPersistentContainer
    
    init() {
        // Create the model programmatically
        let model = NSManagedObjectModel()
        
        // Define HealthLog Entity
        let healthLogEntity = NSEntityDescription()
        healthLogEntity.name = "HealthLog"
        healthLogEntity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        
        let timestampAttr = NSAttributeDescription()
        timestampAttr.name = "timestamp"
        timestampAttr.attributeType = .dateAttributeType
        timestampAttr.isOptional = false
        
        let hrAttr = NSAttributeDescription()
        hrAttr.name = "heartRate"
        hrAttr.attributeType = .doubleAttributeType
        
        let spo2Attr = NSAttributeDescription()
        spo2Attr.name = "spO2"
        spo2Attr.attributeType = .doubleAttributeType
        
        let bpAttr = NSAttributeDescription()
        bpAttr.name = "bloodPressure"
        bpAttr.attributeType = .stringAttributeType
        
        healthLogEntity.properties = [timestampAttr, hrAttr, spo2Attr, bpAttr]
        
        // Define AlertLog Entity
        let alertLogEntity = NSEntityDescription()
        alertLogEntity.name = "AlertLog"
        alertLogEntity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        
        let alertIdAttr = NSAttributeDescription()
        alertIdAttr.name = "id"
        alertIdAttr.attributeType = .UUIDAttributeType
        
        let alertTimestampAttr = NSAttributeDescription()
        alertTimestampAttr.name = "timestamp"
        alertTimestampAttr.attributeType = .dateAttributeType
        
        let severityAttr = NSAttributeDescription()
        severityAttr.name = "severity"
        severityAttr.attributeType = .stringAttributeType
        
        let alertHrAttr = NSAttributeDescription()
        alertHrAttr.name = "heartRate"
        alertHrAttr.attributeType = .doubleAttributeType
        
        let alertSpo2Attr = NSAttributeDescription()
        alertSpo2Attr.name = "spO2"
        alertSpo2Attr.attributeType = .doubleAttributeType
        
        let alertBpAttr = NSAttributeDescription()
        alertBpAttr.name = "bloodPressure"
        alertBpAttr.attributeType = .stringAttributeType
        
        let latAttr = NSAttributeDescription()
        latAttr.name = "locationLat"
        latAttr.attributeType = .doubleAttributeType
        
        let lonAttr = NSAttributeDescription()
        lonAttr.name = "locationLon"
        lonAttr.attributeType = .doubleAttributeType
        
        let droneAttr = NSAttributeDescription()
        droneAttr.name = "droneDispatched"
        droneAttr.attributeType = .booleanAttributeType
        
        let deviceIdAttr = NSAttributeDescription()
        deviceIdAttr.name = "deviceID"
        deviceIdAttr.attributeType = .stringAttributeType
        
        let statusAttr = NSAttributeDescription()
        statusAttr.name = "status"
        statusAttr.attributeType = .stringAttributeType
        
        alertLogEntity.properties = [alertIdAttr, alertTimestampAttr, severityAttr, alertHrAttr, alertSpo2Attr, alertBpAttr, latAttr, lonAttr, droneAttr, deviceIdAttr, statusAttr]
        
        model.entities = [healthLogEntity, alertLogEntity]
        
        // Initialize Container
        container = NSPersistentContainer(name: "HealthGuard", managedObjectModel: model)
        
        // Setup In-Memory Store for Prototype (or Persistent Store)
        // Using in-memory for simplicity in this environment, but can be file-based.
        // To make it persistent, we'd need to ensure the store URL is valid.
        // Let's try standard persistence.
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Core Data save error: \(error.localizedDescription)")
            }
        }
    }
    
    func logVital(heartRate: Double, spO2: Double, bp: String) {
        let context = container.viewContext
        let log = NSManagedObject(entity: container.managedObjectModel.entitiesByName["HealthLog"]!, insertInto: context)
        log.setValue(Date(), forKey: "timestamp")
        log.setValue(heartRate, forKey: "heartRate")
        log.setValue(spO2, forKey: "spO2")
        log.setValue(bp, forKey: "bloodPressure")
        
        saveContext()
    }
    
    func saveAlert(severity: String, heartRate: Double, spO2: Double, bloodPressure: String, latitude: Double, longitude: Double, droneDispatched: Bool) {
        let context = container.viewContext
        context.performAndWait {
            let log = NSManagedObject(entity: container.managedObjectModel.entitiesByName["AlertLog"]!, insertInto: context)
            log.setValue(UUID(), forKey: "id")
            log.setValue(Date(), forKey: "timestamp")
            log.setValue(severity, forKey: "severity")
            log.setValue(heartRate, forKey: "heartRate")
            log.setValue(spO2, forKey: "spO2")
            log.setValue(bloodPressure, forKey: "bloodPressure")
            log.setValue(latitude, forKey: "locationLat")
            log.setValue(longitude, forKey: "locationLon")
            log.setValue(droneDispatched, forKey: "droneDispatched")
            log.setValue(UIDevice.current.identifierForVendor?.uuidString ?? "unknown", forKey: "deviceID")
            log.setValue("active", forKey: "status")
            
            do {
                try context.save()
                print("✅ Alert saved to CoreData successfully: \(severity)")
            } catch {
                print("❌ Failed to save alert to CoreData: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchRecentLogs() -> [NSManagedObject] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "HealthLog")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = 50
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Fetch error: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchCriticalAlerts() -> [NSManagedObject] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "AlertLog")
        request.predicate = NSPredicate(format: "severity == %@", "critical")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Fetch error: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchAllAlerts() -> [NSManagedObject] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "AlertLog")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Fetch error: \(error.localizedDescription)")
            return []
        }
    }
    
    func clearAllAlerts() {
        let context = container.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AlertLog")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            print("🗑️ All alerts cleared")
        } catch {
            print("❌ Failed to clear alerts: \(error.localizedDescription)")
        }
    }
}
