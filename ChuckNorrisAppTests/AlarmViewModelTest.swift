//
//  AlarmViewModelTest.swift
//  ChuckNorrisAppTests
//
//  Created by Antigravity on 09/07/26.
//

import XCTest
import AVFoundation
@testable import ChuckNorrisApp

final class AlarmRepositoryMock: AlarmRepository {
    var getAllReturnValue: [Alarm] = []
    var getAllCalled = false
    var saveCalled = false
    var savedAlarm: Alarm?
    var deleteCalled = false
    var deletedId: UUID?
    
    func getAll() -> [Alarm] {
        getAllCalled = true
        return getAllReturnValue
    }
    
    func save(alarm: Alarm) {
        saveCalled = true
        savedAlarm = alarm
    }
    
    func delete(id: UUID) {
        deleteCalled = true
        deletedId = id
    }
    
    func reset() {
        getAllReturnValue = []
        getAllCalled = false
        saveCalled = false
        savedAlarm = nil
        deleteCalled = false
        deletedId = nil
    }
}

final class NotificationManagerMock: NotificationManager {
    var scheduleAlarmCalled = false
    var scheduledAlarm: Alarm?
    var cancelAlarmCalled = false
    var cancelledId: UUID?
    var requestPermissionCalled = false
    
    func scheduleAlarm(alarm: Alarm) {
        scheduleAlarmCalled = true
        scheduledAlarm = alarm
    }
    
    func cancelAlarm(id: UUID) {
        cancelAlarmCalled = true
        cancelledId = id
    }
    
    func requestPermission() {
        requestPermissionCalled = true
    }
    
    func reset() {
        scheduleAlarmCalled = false
        scheduledAlarm = nil
        cancelAlarmCalled = false
        cancelledId = nil
        requestPermissionCalled = false
    }
}

@MainActor
final class AlarmViewModelTest: XCTestCase {
    private var viewModel: AlarmViewModelImpl!
    private var repository = AlarmRepositoryMock()
    private var notificationManager = NotificationManagerMock()
    
    override func setUp() {
        super.setUp()
        repository.reset()
        notificationManager.reset()
        viewModel = AlarmViewModelImpl(
            repository: repository,
            notificationManager: notificationManager,
            speechService: SpeechService(speechSynthesizer: AVSpeechSynthesizer())
        )
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFetchAlarms() {
        let expectedAlarms = [Alarm(hour: 8, minute: 0)]
        repository.getAllReturnValue = expectedAlarms
        
        repository.getAllCalled = false
        viewModel.fetchAlarms()
        
        XCTAssertEqual(viewModel.alarms.count, 1)
        XCTAssertEqual(viewModel.alarms.first?.hour, 8)
        XCTAssertTrue(repository.getAllCalled)
    }
    
    func testAddAlarm_enabled() {
        viewModel.addAlarm(hour: 9, minute: 30, days: [2, 3], isEnabled: true)
        
        XCTAssertTrue(repository.saveCalled)
        XCTAssertTrue(notificationManager.scheduleAlarmCalled)
    }
    
    func testAddAlarm_disabled() {
        viewModel.addAlarm(hour: 10, minute: 0, days: [], isEnabled: false)
        
        XCTAssertTrue(repository.saveCalled)
        XCTAssertFalse(notificationManager.scheduleAlarmCalled)
    }
    
    func testUpdateAlarm_enabled() {
        let alarm = Alarm(hour: 7, minute: 15, isEnabled: true)
        viewModel.updateAlarm(alarm)
        
        XCTAssertTrue(repository.saveCalled)
        XCTAssertTrue(notificationManager.scheduleAlarmCalled)
    }
    
    func testUpdateAlarm_disabled() {
        let alarm = Alarm(hour: 7, minute: 15, isEnabled: false)
        viewModel.updateAlarm(alarm)
        
        XCTAssertTrue(repository.saveCalled)
        XCTAssertTrue(notificationManager.cancelAlarmCalled)
    }
    
    func testDeleteAlarm_byAlarm() {
        let alarm = Alarm(hour: 7, minute: 15)
        viewModel.deleteAlarm(alarm)
        
        XCTAssertEqual(repository.deletedId, alarm.id)
        XCTAssertEqual(notificationManager.cancelledId, alarm.id)
    }
    
    func testDeleteAlarm_byIndexSet() {
        let alarm1 = Alarm(hour: 7, minute: 15)
        let alarm2 = Alarm(hour: 8, minute: 30)
        repository.getAllReturnValue = [alarm1, alarm2]
        viewModel.fetchAlarms()
        
        viewModel.deleteAlarm(at: IndexSet(integer: 1))
        
        XCTAssertEqual(repository.deletedId, alarm2.id)
        XCTAssertEqual(notificationManager.cancelledId, alarm2.id)
    }
    
    func testToggleAlarm() {
        let alarm = Alarm(hour: 7, minute: 15, isEnabled: true)
        viewModel.toggleAlarm(alarm)
        
        XCTAssertTrue(repository.saveCalled)
        XCTAssertEqual(notificationManager.cancelledId, alarm.id)
    }
}
