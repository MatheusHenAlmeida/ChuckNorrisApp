//
//  NotificationManager.swift
//  ChuckNorrisApp
//
//  Created by Gemini on 12/02/26.
//

import Foundation
import UserNotifications
import AVFoundation

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    private let speechService = SpeechService(speechSynthesizer: AVSpeechSynthesizer())
    
    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        setupNotificationCategories()
    }
    
    private func setupNotificationCategories() {
        let tellJokeAction = UNNotificationAction(
            identifier: "TELL_JOKE_ACTION",
            title: "Tell me the joke",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: "ALARM_CATEGORY",
            actions: [tellJokeAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
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
            var jokeText = "Time for a Chuck Norris Joke!"
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
            content.title = "Time for a Chuck Norris Joke!"
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
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "TELL_JOKE_ACTION" {
            let joke = response.notification.request.content.userInfo["joke"] as? String ?? response.notification.request.content.body
            speechService.speech(message: joke)
        }
        completionHandler()
    }
}
