//
//  NotificationManager.swift
//  ChuckNorrisApp
//
//  Created by Gemini on 12/02/26.
//

import Foundation
import UserNotifications
import AVFoundation
import UIKit

protocol NotificationManager {
    func scheduleAlarm(alarm: Alarm)
    func cancelAlarm(id: UUID)
    func requestPermission()
    func consumePendingJokePayload() -> (text: String, speak: Bool)?
    func setPendingJoke(text: String, speak: Bool)
}

extension NotificationManager {
    func setPendingJoke(text: String, speak: Bool) {}
}

class NotificationManagerImpl: NSObject, UNUserNotificationCenterDelegate, NotificationManager {
    nonisolated(unsafe) static let shared = NotificationManagerImpl()
    
    private(set) var pendingJokePayload: (text: String, speak: Bool)?
    
    func setPendingJoke(text: String, speak: Bool) {
        self.pendingJokePayload = (text, speak)
    }
    
    func consumePendingJokePayload() -> (text: String, speak: Bool)? {
        defer { self.pendingJokePayload = nil }
        return self.pendingJokePayload
    }
    
    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        setupNotificationCategories()
        setupLifecycleObservers()
        cleanUpExpiredSingleRunAlarms()
    }
    
    private func setupNotificationCategories() {
        let tellJokeAction = UNNotificationAction(
            identifier: "TELL_JOKE_ACTION",
            title: NSLocalizedString("tell_me_the_joke_action", comment: "Notification action button title to tell the joke"),
            options: [.foreground]
        )
        
        let category = UNNotificationCategory(
            identifier: "ALARM_CATEGORY",
            actions: [tellJokeAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    private func setupLifecycleObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func handleAppForeground() {
        cleanUpExpiredSingleRunAlarms()
    }
    
    private func checkAndDeleteSingleRunAlarm(id: UUID) {
        let repository: AlarmRepository = AlarmRepositoryImpl(context: CoreDataManager.shared.context)
        let alarms = repository.getAll()
        if let alarm = alarms.first(where: { $0.id == id }) {
            if alarm.days.isEmpty {
                print("Deleting single-run alarm: \(id)")
                repository.delete(id: id)
            }
        }
    }
    
    func cleanUpExpiredSingleRunAlarms() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let pendingIds = Set(requests.map { $0.identifier })
            
            let repository: AlarmRepository = AlarmRepositoryImpl(context: CoreDataManager.shared.context)
            let alarms = repository.getAll()
            
            for alarm in alarms {
                if alarm.days.isEmpty && alarm.isEnabled {
                    if !pendingIds.contains(alarm.id.uuidString) {
                        print("Cleaning up expired single-run alarm: \(alarm.id)")
                        repository.delete(id: alarm.id)
                    }
                }
            }
        }
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission denied: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleAlarm(alarm: Alarm) {
        // Cancel existing notifications for this alarm ID (we will use ID + identifiers)
        cancelAlarm(id: alarm.id)
        
        Task {
            var jokeText = NSLocalizedString("time_for_chuck_norris_joke", comment: "Default body text for Chuck Norris joke alarm notification")
            do {
                let service = ChuckNorrisServiceImpl(baseUrl: "https://api.chucknorris.io/jokes")
                let client = ChuckNorrisWebClientImpl(webService: service)
                if let joke = try await client.getJoke(), let val = joke.value {
                    jokeText = val
                }
            } catch {
                print("Error fetching joke for alarm notification: \(error)")
            }
            
            let content = UNMutableNotificationContent()
            content.title = NSLocalizedString("time_for_chuck_norris_joke", comment: "Title for Chuck Norris joke alarm notification")
            content.body = jokeText
            content.sound = .default
            content.categoryIdentifier = "ALARM_CATEGORY"
            content.userInfo = [
                "alarmId": alarm.id.uuidString,
                "joke": jokeText
            ]
            
            if alarm.days.isEmpty {
                // One-time alarm (Next occurrence)
                var dateComponents = DateComponents()
                dateComponents.hour = alarm.hour
                dateComponents.minute = alarm.minute
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let request = UNNotificationRequest(identifier: alarm.id.uuidString, content: content, trigger: trigger)
                
                try? await UNUserNotificationCenter.current().add(request)
            } else {
                // Recurring alarm for each day
                for day in alarm.days {
                    var dateComponents = DateComponents()
                    dateComponents.hour = alarm.hour
                    dateComponents.minute = alarm.minute
                    dateComponents.weekday = day // 1 = Sunday matches UNCalendarNotificationTrigger
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                    // Unique identifier for each day instance: UUID-Day
                    let request = UNNotificationRequest(identifier: "\(alarm.id.uuidString)-\(day)", content: content, trigger: trigger)
                    
                    try? await UNUserNotificationCenter.current().add(request)
                }
            }
        }
    }
    
    func cancelAlarm(id: UUID) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiers = requests.map { $0.identifier }.filter { $0.contains(id.uuidString) }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        if let alarmIdString = userInfo["alarmId"] as? String, let alarmId = UUID(uuidString: alarmIdString) {
            checkAndDeleteSingleRunAlarm(id: alarmId)
        }
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let action = response.actionIdentifier
        let userInfo = response.notification.request.content.userInfo
        if let alarmIdString = userInfo["alarmId"] as? String, let alarmId = UUID(uuidString: alarmIdString) {
            checkAndDeleteSingleRunAlarm(id: alarmId)
        }
        
        if action == "TELL_JOKE_ACTION" || action == UNNotificationDefaultActionIdentifier {
            let joke = userInfo["joke"] as? String ?? response.notification.request.content.body
            let shouldSpeak = (action == "TELL_JOKE_ACTION")
            
            DispatchQueue.main.async {
                NotificationManagerImpl.shared.handleNotificationResponse(joke: joke, shouldSpeak: shouldSpeak)
            }
        }
        completionHandler()
    }
    
    @MainActor
    private func handleNotificationResponse(joke: String, shouldSpeak: Bool) {
        guard let scene = UIApplication.shared.connectedScenes.first(where: {
            $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive
        }) as? UIWindowScene ?? UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first else {
            setPendingJoke(text: joke, speak: shouldSpeak)
            return
        }
        
        if let viewController = window.findViewController {
            if viewController.presentedViewController != nil {
                viewController.dismiss(animated: true) {
                    viewController.displayJoke(text: joke, speak: shouldSpeak)
                }
            } else {
                viewController.displayJoke(text: joke, speak: shouldSpeak)
            }
        } else {
            setPendingJoke(text: joke, speak: shouldSpeak)
        }
    }
}

private extension UIWindow {
    @MainActor
    var findViewController: ViewController? {
        var current = rootViewController
        while let vc = current {
            if let target = vc as? ViewController {
                return target
            }
            current = vc.presentedViewController
        }
        return nil
    }
}
