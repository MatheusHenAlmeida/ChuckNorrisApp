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
}

// TODO: Mover ações do AlarmRepository e do ChuckNorrisWebClient para ViewModel, se possível
class NotificationManagerImpl: NSObject, UNUserNotificationCenterDelegate, NotificationManager {
    nonisolated(unsafe) static let shared = NotificationManagerImpl()
    
    var webClient: ChuckNorrisWebClient?
    var alarmRepository: AlarmRepository?
    private(set) var pendingJokePayload: (text: String, speak: Bool)?
    
    init(webClient: ChuckNorrisWebClient? = nil, alarmRepository: AlarmRepository? = nil) {
        self.webClient = webClient
        self.alarmRepository = alarmRepository
        super.init()
        UNUserNotificationCenter.current().delegate = self
        setupNotificationCategories()
        setupLifecycleObservers()
        cleanUpExpiredSingleRunAlarms()
    }
    
    func setPendingJoke(text: String, speak: Bool) {
        self.pendingJokePayload = (text, speak)
    }
    
    func consumePendingJokePayload() -> (text: String, speak: Bool)? {
        defer { self.pendingJokePayload = nil }
        return self.pendingJokePayload
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
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func appDidBecomeActive() {
        cleanUpExpiredSingleRunAlarms()
    }
    
    private func checkAndDeleteSingleRunAlarm(id: UUID) {
        let alarms = alarmRepository?.getAll() ?? []
        if let alarm = alarms.first(where: { $0.id == id }) {
            if alarm.days.isEmpty {
                print("Deleting single-run alarm: \(id)")
                alarmRepository?.delete(id: id)
            }
        }
    }
    
    func cleanUpExpiredSingleRunAlarms() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { [weak self] requests in
            let pendingIds = Set(requests.map { $0.identifier })
            
            let alarms = self?.alarmRepository?.getAll() ?? []
            
            for alarm in alarms {
                if alarm.days.isEmpty && alarm.isEnabled {
                    if !pendingIds.contains(alarm.id.uuidString) {
                        print("Cleaning up expired single-run alarm: \(alarm.id)")
                        self?.alarmRepository?.delete(id: alarm.id)
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
        
        let client = self.webClient
        Task {
            var jokeText = NSLocalizedString("time_for_chuck_norris_joke", comment: "Default body text for Chuck Norris joke alarm notification")
            do {
                if let joke = try await client?.getJoke(), let val = joke.value {
                    jokeText = val
                }
            } catch {
                print("Error fetching joke for alarm notification: \(error)")
            }
            
            let content = buildNotificationContent(alarmId: alarm.id.uuidString, joke: jokeText)
            
            if alarm.days.isEmpty {
                let request = createNotificationRequest(alarm: alarm, content: content)
                
                try? await UNUserNotificationCenter.current().add(request)
            } else {
                for day in alarm.days {
                    let request = createNotificationRequest(alarm: alarm, content: content, forDay: day)
                    
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
            self.pendingJokePayload = (joke, shouldSpeak)
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
            self.pendingJokePayload = (joke, shouldSpeak)
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

// MARK: - Internal Helpers
private func buildNotificationContent(alarmId: String, joke: String) -> UNNotificationContent {
    let content = UNMutableNotificationContent()
    content.title = NSLocalizedString("time_for_chuck_norris_joke", comment: "Title for Chuck Norris joke alarm notification")
    content.body = joke
    content.sound = .default
    content.categoryIdentifier = "ALARM_CATEGORY"
    content.userInfo = [
        "alarmId": alarmId,
        "joke": joke
    ]
    
    return content
}

private func createNotificationRequest(alarm: Alarm, content: UNNotificationContent, forDay day: Int? = nil) -> UNNotificationRequest {
    var dateComponents = DateComponents()
    dateComponents.hour = alarm.hour
    dateComponents.minute = alarm.minute
    if let day {
        dateComponents.weekday = day // 1 = Sunday matches UNCalendarNotificationTrigger
    }
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: day != nil)
    var uniqueIdentifier = ""
    if let day {
        uniqueIdentifier = "\(alarm.id.uuidString)-\(day)"
    } else {
        uniqueIdentifier = alarm.id.uuidString
    }
    let request = UNNotificationRequest(identifier: uniqueIdentifier, content: content, trigger: trigger)
    
    return request
}
