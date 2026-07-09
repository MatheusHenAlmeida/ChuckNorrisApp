//
//  AlarmListView.swift
//  ChuckNorrisApp
//
//  Created by Gemini on 12/02/26.
//

import SwiftUI

struct AlarmListView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: AlarmViewModel
    @State private var showingAddAlarm: Bool
    @State private var selectedAlarm: Alarm?
    @State private var showingDeleteConfirmation = false
    @State private var alarmToDelete: Alarm?
    
    init(showAddAlarmInitially: Bool = false, viewModel: AlarmViewModel = AlarmViewModel()) {
        _showingAddAlarm = State(initialValue: showAddAlarmInitially)
        _selectedAlarm = State(initialValue: nil)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.alarms) { alarm in
                    AlarmRow(
                        alarm: alarm,
                        viewModel: viewModel,
                        onEdit: {
                            selectedAlarm = alarm
                        },
                        onDelete: {
                            alarmToDelete = alarm
                            showingDeleteConfirmation = true
                        }
                    )
                }
                .onDelete(perform: viewModel.deleteAlarm)
            }
            .navigationTitle(NSLocalizedString("alarm_list_title", comment: "Alarm list navigation title"))
            .navigationBarItems(
                leading: Button(NSLocalizedString("alarm_list_close_button", comment: "Close button title")) {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(action: {
                    selectedAlarm = nil
                    showingAddAlarm = true
                }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $showingAddAlarm) {
                AlarmEditView(viewModel: viewModel, alarm: nil)
            }
            .sheet(item: $selectedAlarm) { alarm in
                AlarmEditView(viewModel: viewModel, alarm: alarm)
            }
            .alert(isPresented: $showingDeleteConfirmation) {
                Alert(
                    title: Text(NSLocalizedString("alarm_list_delete_title", comment: "Delete alarm alert title")),
                    message: Text(NSLocalizedString("alarm_list_delete_message", comment: "Delete alarm alert message")),
                    primaryButton: .destructive(Text(NSLocalizedString("alarm_list_confirm_button", comment: "Confirm button title"))) {
                        if let alarm = alarmToDelete {
                            viewModel.deleteAlarm(alarm)
                        }
                        alarmToDelete = nil
                    },
                    secondaryButton: .cancel(Text(NSLocalizedString("alarm_list_cancel_button", comment: "Cancel button title"))) {
                        alarmToDelete = nil
                    }
                )
            }
        }
        .onAppear {
            viewModel.fetchAlarms()
            NotificationManager.shared.requestPermission()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                viewModel.fetchAlarms()
            }
        }
    }
}

struct AlarmRow: View {
    let alarm: Alarm
    @ObservedObject var viewModel: AlarmViewModel
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(String(format: "%02d:%02d", alarm.hour, alarm.minute))
                    .font(.largeTitle)
                Text(daysText(for: alarm.days))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            HStack(spacing: 20) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private func daysText(for days: [Int]) -> String {
        if days.isEmpty {
            return NSLocalizedString("alarm_list_one_time", comment: "Label for non-repeating alarm")
        }
        if days.count == 7 {
            return NSLocalizedString("alarm_list_every_day", comment: "Label for alarm repeating every day")
        }
        // Map 1-7 to Sun-Sat
        let formatter = DateFormatter()
        let symbols = formatter.shortWeekdaySymbols!
        return days.sorted().map { symbols[$0 - 1] }.joined(separator: ", ")
    }
}

#if DEBUG
class MockAlarmRepository: AlarmRepository {
    var alarms: [Alarm] = [
        Alarm(id: UUID(), hour: 8, minute: 0, days: [2, 3, 4, 5, 6], isEnabled: true),
        Alarm(id: UUID(), hour: 10, minute: 30, days: [], isEnabled: false),
        Alarm(id: UUID(), hour: 19, minute: 15, days: [1, 7], isEnabled: true)
    ]
    
    func getAll() -> [Alarm] {
        return alarms
    }
    
    func save(alarm: Alarm) {}
    func delete(id: UUID) {}
}

struct AlarmListView_Previews: PreviewProvider {
    static var previews: some View {
        let mockRepository = MockAlarmRepository()
        let viewModel = AlarmViewModel(repository: mockRepository)
        AlarmListView(showAddAlarmInitially: false, viewModel: viewModel)
    }
}

struct AlarmRowView_Previews: PreviewProvider {
    static var previews: some View {
        let alarm = Alarm(id: UUID(), hour: 8, minute: 0, days: [2, 3, 4, 5, 6], isEnabled: true)
        let mockRepository = MockAlarmRepository()
        let viewModel = AlarmViewModel(repository: mockRepository)
        AlarmRow(alarm: alarm, viewModel: viewModel, onEdit: {}, onDelete: {})
    }
}
#endif
