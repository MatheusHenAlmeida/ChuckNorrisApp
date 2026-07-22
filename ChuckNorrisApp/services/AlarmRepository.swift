//
//  AlarmRepository.swift
//  ChuckNorrisApp
//
//  Created by Gemini on 12/02/26.
//

import Foundation
import CoreData

protocol AlarmRepository {
    func getAll() -> [Alarm]
    func save(alarm: Alarm)
    func delete(id: UUID)
}

class AlarmRepositoryImpl: AlarmRepository {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getAll() -> [Alarm] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "AlarmEntity")
        
        do {
            let results = try context.fetch(request)
            return results.compactMap { mapToDomain(entity: $0) }
        } catch {
            print("Error fetching alarms: \(error)")
            return []
        }
    }
    
    func save(alarm: Alarm) {
        // Check if exists update, otherwise create
        let request = NSFetchRequest<NSManagedObject>(entityName: "AlarmEntity")
        request.predicate = NSPredicate(format: "id == %@", alarm.id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            let entity: NSManagedObject
            
            if let existing = results.first {
                entity = existing
            } else {
                guard let entityDescription = NSEntityDescription.entity(forEntityName: "AlarmEntity", in: context) else { return }
                entity = NSManagedObject(entity: entityDescription, insertInto: context)
                entity.setValue(alarm.id, forKey: "id")
            }
            
            entity.setValue(Int16(alarm.hour), forKey: "hour")
            entity.setValue(Int16(alarm.minute), forKey: "minute")
            entity.setValue(alarm.isEnabled, forKey: "isEnabled")
            
            // Convert array to comma separated string
            let daysString = alarm.days.map { String($0) }.joined(separator: ",")
            entity.setValue(daysString, forKey: "days")
            
            CoreDataManager.shared.save()
            
        } catch {
            print("Error saving alarm: \(error)")
        }
    }
    
    func delete(id: UUID) {
        let request = NSFetchRequest<NSManagedObject>(entityName: "AlarmEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            if let entity = results.first {
                context.delete(entity)
                CoreDataManager.shared.save()
            }
        } catch {
            print("Error deleting alarm: \(error)")
        }
    }
    
    private func mapToDomain(entity: NSManagedObject) -> Alarm? {
        guard let id = entity.value(forKey: "id") as? UUID,
              let hour = entity.value(forKey: "hour") as? Int16,
              let minute = entity.value(forKey: "minute") as? Int16,
              let isEnabled = entity.value(forKey: "isEnabled") as? Bool else {
            return nil
        }
        
        let daysString = entity.value(forKey: "days") as? String ?? ""
        let days = daysString.split(separator: ",").compactMap { Int($0) }
        
        return Alarm(id: id, hour: Int(hour), minute: Int(minute), days: days, isEnabled: isEnabled)
    }
}
