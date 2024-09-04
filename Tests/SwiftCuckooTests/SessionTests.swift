import Foundation
import SwiftCuckoo
import Testing

private extension Session.Identifier {
    static let test = Session.Identifier(rawValue: "test")
}

final class SessionTests {
    @Test("Test duration when end time is nil")
    func testDuration_whenEndTimeIsNil_shouldThrowMissingEndTimeError() {
        // Given
        let startTime = Date()
        let session = Session(id: .test, startTime: startTime)
        
        #expect(throws: Session.Error.missingEndTime, performing: {
            try session.duration()
        })
    }
    
    @Test("Test duration when end time is set")
    func testDuration_whenEndTimeIsSet_shouldReturnCorrectValue() throws {
        // Given
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(3600) // 1 hour later
        let session = Session(id: .test, startTime: startTime, endTime: endTime)
        
        // Act
        let duration = try session.duration()
        
        // Assert
        #expect(duration == 3600) // Duration should be 3600 seconds (1 hour) when endTime is set correctly.
    }
    
    @Test("Test duration when end time is earlier than start time")
    func testDuration_whenEndTimeIsEarlierThanStartTime_shouldThrowEndTimeBeforeStartTimeError() {
        // Given
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(-3600) // 1 hour earlier
        let session = Session(id: .test, startTime: startTime, endTime: endTime)
        
        // Act & Assert
        #expect(throws: Session.Error.endTimeBeforeStartTime, performing: {
            try session.duration()
        })
    }
    
    @Test("Test duration when end time is equal to start time")
    func testDuration_whenEndTimeIsEqualToStartTime_shouldReturnZero() throws {
        // Given
        let startTime = Date()
        let endTime = startTime // same time
        let session = Session(id: .test, startTime: startTime, endTime: endTime)
        
        // Act
        let duration = try session.duration()
        
        // Assert
        #expect(duration == 0) // Duration should be 0 seconds when endTime is equal to startTime.
    }
}
