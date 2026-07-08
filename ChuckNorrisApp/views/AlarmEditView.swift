//
//  AlarmEditView.swift
//  ChuckNorrisApp
//
//  Created by Gemini on 12/02/26.
//

import SwiftUI

struct AlarmEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: AlarmViewModel
    
    @State private var date: Date
    @State private var selectedDays: Set<Int> = []
    
    var existingAlarm: Alarm?
    
    init(viewModel: AlarmViewModel, alarm: Alarm? = nil) {
        self.viewModel = viewModel
        self.existingAlarm = alarm
        
        if let alarm = alarm {
            var components = DateComponents()
            components.hour = alarm.hour
            components.minute = alarm.minute
            self._date = State(initialValue: Calendar.current.date(from: components) ?? Date())
            self._selectedDays = State(initialValue: Set(alarm.days))
        } else {
            self._date = State(initialValue: Date())
            self._selectedDays = State(initialValue: [])
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Time")) {
                    DatePicker("Select Time", selection: $date, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                }
                
                Section(header: Text("Repeat")) {
                    ForEach(1...7, id: \.self) { day in
                        MultipleSelectionRow(title: dayName(for: day), isSelected: selectedDays.contains(day)) {
                            if selectedDays.contains(day) {
                                selectedDays.remove(day)
                            } else {
                                selectedDays.insert(day)
                            }
                        }
                    }
                }
            }
            .navigationTitle(existingAlarm == nil ? "Add Alarm" : "Edit Alarm")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveAlarm()
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func saveAlarm() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let days = Array(selectedDays).sorted()
        
        if let existing = existingAlarm {
            var updated = existing
            updated.hour = hour
            updated.minute = minute
            updated.days = days
            // Maintain existing ID and enabled state, or re-enable on edit?
            // Usually editing re-enables or keeps intent. Let's keep existing enabled state or force true.
            // Android spec: "Crie múltiplos UNNotificationRequest".
            // Let's keep it simple: Update it.
            viewModel.updateAlarm(updated)
        } else {
            viewModel.addAlarm(hour: hour, minute: minute, days: days, isEnabled: true)
        }
    }
    
    private func dayName(for day: Int) -> String {
        // 1 = Sunday
        let formatter = DateFormatter()
        return formatter.weekdaySymbols[day - 1]
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: self.action) {
            HStack {
                Text(title)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                }
            }
        }
        .foregroundColor(.primary)
    }
}

#if DEBUG
struct AlarmEditView_Previews: PreviewProvider {
    static var previews: some View {
        let mockRepository = MockAlarmRepository()
        let viewModel = AlarmViewModel(repository: mockRepository)
        AlarmEditView(viewModel: viewModel, alarm: nil)
    }
}
#endif
