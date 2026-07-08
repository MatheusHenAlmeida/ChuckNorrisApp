//
//  AlarmListView.swift
//  ChuckNorrisApp
//
//  Created by Gemini on 12/02/26.
//

import SwiftUI

struct AlarmListView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = AlarmViewModel()
    @State private var showingAddAlarm: Bool
    @State private var selectedAlarm: Alarm?
    
    init(showAddAlarmInitially: Bool = false) {
        _showingAddAlarm = State(initialValue: showAddAlarmInitially)
        _selectedAlarm = State(initialValue: nil)
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.alarms) { alarm in
                    AlarmRow(alarm: alarm, viewModel: viewModel) {
                        selectedAlarm = alarm
                    }
                }
                .onDelete(perform: viewModel.deleteAlarm)
            }
            .navigationTitle("Alarms")
            .navigationBarItems(
                leading: Button("Close") {
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
        }
        .onAppear {
            viewModel.fetchAlarms()
            NotificationManager.shared.requestPermission()
        }
    }
}

struct AlarmRow: View {
    let alarm: Alarm
    @ObservedObject var viewModel: AlarmViewModel
    let onTap: () -> Void
    
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
            Toggle("", isOn: Binding(
                get: { alarm.isEnabled },
                set: { _ in viewModel.toggleAlarm(alarm) }
            ))
            .labelsHidden()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
    
    private func daysText(for days: [Int]) -> String {
        if days.isEmpty {
            return "One time"
        }
        if days.count == 7 {
            return "Every day"
        }
        // Map 1-7 to Sun-Sat
        let formatter = DateFormatter()
        let symbols = formatter.shortWeekdaySymbols!
        return days.sorted().map { symbols[$0 - 1] }.joined(separator: ", ")
    }
}
