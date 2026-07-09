//
//  AlarmRepositoryImplTest.swift
//  ChuckNorrisAppTests
//
//  Created by Antigravity on 09/07/26.
//

import XCTest
@testable import ChuckNorrisApp

final class AlarmRepositoryImplTest: XCTestCase {
    private var repository: AlarmRepositoryImpl!
    
    override func setUp() {
        super.setUp()
        repository = AlarmRepositoryImpl()
    }
    
    func testSaveAndFetchAndDelete() {
        let alarm = Alarm(hour: 11, minute: 45, days: [2, 4], isEnabled: true)
        
        // Save
        repository.save(alarm: alarm)
        
        // Fetch
        let alarms = repository.getAll()
        let fetched = alarms.first(where: { $0.id == alarm.id })
        
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.hour, 11)
        XCTAssertEqual(fetched?.minute, 45)
        XCTAssertEqual(fetched?.days, [2, 4])
        XCTAssertEqual(fetched?.isEnabled, true)
        
        // Update
        var updated = alarm
        updated.hour = 12
        repository.save(alarm: updated)
        
        let updatedAlarms = repository.getAll()
        let fetchedUpdated = updatedAlarms.first(where: { $0.id == alarm.id })
        XCTAssertEqual(fetchedUpdated?.hour, 12)
        
        // Delete
        repository.delete(id: alarm.id)
        
        let alarmsAfterDelete = repository.getAll()
        XCTAssertNil(alarmsAfterDelete.first(where: { $0.id == alarm.id }))
    }
}
