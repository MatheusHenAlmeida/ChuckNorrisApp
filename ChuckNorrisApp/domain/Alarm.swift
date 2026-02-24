//
//  Alarm.swift
//  ChuckNorrisApp
//
//  Created by Gemini on 12/02/26.
//

import Foundation

struct Alarm: Identifiable, Codable {
    let id: UUID
    var hour: Int
    var minute: Int
    var days: [Int] // 1 = Sunday, 7 = Saturday
    var isEnabled: Bool
    var label: String?
    
    init(id: UUID = UUID(), hour: Int, minute: Int, days: [Int] = [], isEnabled: Bool = true, label: String? = nil) {
        self.id = id
        self.hour = hour
        self.minute = minute
        self.days = days
        self.isEnabled = isEnabled
        self.label = label
    }
}
