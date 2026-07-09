//
//  AlarmViewModelTest.swift
//  ChuckNorrisAppTests
//
//  Created by Antigravity on 09/07/26.
//

import XCTest
import Mockingbird
@testable import ChuckNorrisApp

final class AlarmViewModelTest: XCTestCase {
    private var viewModel: AlarmViewModel!
    private var repository = mock(AlarmRepository.self)
    private var notificationManager = mock(NotificationManaging.self)
    
    override func setUp() {
        super.setUp()
        given(repository.getAll()).willReturn([])
        viewModel = AlarmViewModel(repository: repository, notificationManager: notificationManager)
    }
    
    override func tearDown() {
        clearStubs(on: repository)
        clearStubs(on: notificationManager)
        super.tearDown()
    }
    
    func testFetchAlarms() {
        let expectedAlarms = [Alarm(hour: 8, minute: 0)]
        given(repository.getAll()).willReturn(expectedAlarms)
        
        clearInvocations(on: repository)
        viewModel.fetchAlarms()
        
        XCTAssertEqual(viewModel.alarms.count, 1)
        XCTAssertEqual(viewModel.alarms.first?.hour, 8)
        verify(repository.getAll()).wasCalled()
    }
    
    func testAddAlarm_enabled() {
        viewModel.addAlarm(hour: 9, minute: 30, days: [2, 3], isEnabled: true)
        
        verify(repository.save(alarm: any())).wasCalled()
        verify(notificationManager.scheduleAlarm(alarm: any())).wasCalled()
    }
    
    func testAddAlarm_disabled() {
        viewModel.addAlarm(hour: 10, minute: 0, days: [], isEnabled: false)
        
        verify(repository.save(alarm: any())).wasCalled()
        verify(notificationManager.scheduleAlarm(alarm: any())).wasCalled(never)
    }
    
    func testUpdateAlarm_enabled() {
        let alarm = Alarm(hour: 7, minute: 15, isEnabled: true)
        viewModel.updateAlarm(alarm)
        
        verify(repository.save(alarm: any())).wasCalled()
        verify(notificationManager.scheduleAlarm(alarm: any())).wasCalled()
    }
    
    func testUpdateAlarm_disabled() {
        let alarm = Alarm(hour: 7, minute: 15, isEnabled: false)
        viewModel.updateAlarm(alarm)
        
        verify(repository.save(alarm: any())).wasCalled()
        verify(notificationManager.cancelAlarm(id: any())).wasCalled()
    }
    
    func testDeleteAlarm_byAlarm() {
        let alarm = Alarm(hour: 7, minute: 15)
        viewModel.deleteAlarm(alarm)
        
        verify(repository.delete(id: alarm.id)).wasCalled()
        verify(notificationManager.cancelAlarm(id: alarm.id)).wasCalled()
    }
    
    func testDeleteAlarm_byIndexSet() {
        let alarm1 = Alarm(hour: 7, minute: 15)
        let alarm2 = Alarm(hour: 8, minute: 30)
        given(repository.getAll()).willReturn([alarm1, alarm2])
        viewModel.fetchAlarms()
        
        viewModel.deleteAlarm(at: IndexSet(integer: 1))
        
        verify(repository.delete(id: alarm2.id)).wasCalled()
        verify(notificationManager.cancelAlarm(id: alarm2.id)).wasCalled()
    }
    
    func testToggleAlarm() {
        let alarm = Alarm(hour: 7, minute: 15, isEnabled: true)
        viewModel.toggleAlarm(alarm)
        
        verify(repository.save(alarm: any())).wasCalled()
        verify(notificationManager.cancelAlarm(id: alarm.id)).wasCalled()
    }
}
