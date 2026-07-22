//
//  CoreDataManager.swift
//  ChuckNorrisApp
//
//  Created by Gemini on 12/02/26.
//

import Foundation
import CoreData

class CoreDataManager {
    nonisolated(unsafe) static let shared = CoreDataManager()
    
    let container: NSPersistentContainer
    
    private init() {
        // Create the model programmatically
        let model = NSManagedObjectModel()
        
        // Define AlarmEntity
        let alarmEntity = NSEntityDescription()
        alarmEntity.name = "AlarmEntity"
        alarmEntity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        
        // Attributes
        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .UUIDAttributeType
        idAttr.isOptional = false
        
        let hourAttr = NSAttributeDescription()
        hourAttr.name = "hour"
        hourAttr.attributeType = .integer16AttributeType
        hourAttr.isOptional = false
        
        let minuteAttr = NSAttributeDescription()
        minuteAttr.name = "minute"
        minuteAttr.attributeType = .integer16AttributeType
        minuteAttr.isOptional = false
        
        let daysAttr = NSAttributeDescription()
        daysAttr.name = "days"
        daysAttr.attributeType = .stringAttributeType // Storing as comma-separated string
        daysAttr.isOptional = true
        
        let isEnabledAttr = NSAttributeDescription()
        isEnabledAttr.name = "isEnabled"
        isEnabledAttr.attributeType = .booleanAttributeType
        isEnabledAttr.isOptional = false
        isEnabledAttr.defaultValue = true
        
        alarmEntity.properties = [idAttr, hourAttr, minuteAttr, daysAttr, isEnabledAttr]
        
        model.entities = [alarmEntity]
        
        // Initialize container with the programmatic model
        container = NSPersistentContainer(name: "ChuckNorrisApp", managedObjectModel: model)
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
    }
    
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}
