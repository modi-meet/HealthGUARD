import Foundation
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
        
        let alertTimestampAttr = NSAttributeDescription()
        alertTimestampAttr.name = "timestamp"
        alertTimestampAttr.attributeType = .dateAttributeType
        
        let severityAttr = NSAttributeDescription()
        severityAttr.name = "severity"
        severityAttr.attributeType = .stringAttributeType
        
        let reasonAttr = NSAttributeDescription()
        reasonAttr.name = "triggeredReason"
        reasonAttr.attributeType = .stringAttributeType
        
        alertLogEntity.properties = [alertTimestampAttr, severityAttr, reasonAttr]
        
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
    
    func logAlert(severity: String, reason: String) {
        let context = container.viewContext
        let log = NSManagedObject(entity: container.managedObjectModel.entitiesByName["AlertLog"]!, insertInto: context)
        log.setValue(Date(), forKey: "timestamp")
        log.setValue(severity, forKey: "severity")
        log.setValue(reason, forKey: "triggeredReason")
        
        saveContext()
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
}
