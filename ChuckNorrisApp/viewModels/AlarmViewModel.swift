//
//  AlarmViewModel.swift
//  ChuckNorrisApp
//
//  Created by Gemini on 12/02/26.
//

import Foundation
import Combine

class AlarmViewModel: ObservableObject {
    @Published var alarms: [Alarm] = []
    
    private let repository: AlarmRepository
    private let notificationManager: NotificationManager
    
    init(repository: AlarmRepository = AlarmRepositoryImpl(), notificationManager: NotificationManager = NotificationManager.shared) {
        self.repository = repository
        self.notificationManager = notificationManager
        fetchAlarms()
    }
    
    func fetchAlarms() {
        self.alarms = repository.getAll()
    }
    
    func addAlarm(hour: Int, minute: Int, days: [Int], isEnabled: Bool) {
        let alarm = Alarm(hour: hour, minute: minute, days: days, isEnabled: isEnabled)
        repository.save(alarm: alarm)
        if isEnabled {
            notificationManager.scheduleAlarm(alarm: alarm)
        }
        fetchAlarms()
    }
    
    func updateAlarm(_ alarm: Alarm) {
        repository.save(alarm: alarm)
        if alarm.isEnabled {
            notificationManager.scheduleAlarm(alarm: alarm)
        } else {
            notificationManager.cancelAlarm(id: alarm.id)
        }
        fetchAlarms()
    }
    
    func deleteAlarm(at offsets: IndexSet) {
        offsets.forEach { index in
            let alarm = alarms[index]
            repository.delete(id: alarm.id)
            notificationManager.cancelAlarm(id: alarm.id)
        }
        fetchAlarms()
    }
    
    func deleteAlarm(_ alarm: Alarm) {
        repository.delete(id: alarm.id)
        notificationManager.cancelAlarm(id: alarm.id)
        fetchAlarms()
    }
    
    func toggleAlarm(_ alarm: Alarm) {
        var updatedAlarm = alarm
        updatedAlarm.isEnabled.toggle()
        updateAlarm(updatedAlarm)
    }
}
