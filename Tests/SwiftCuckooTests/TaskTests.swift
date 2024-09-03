import XCTest
import SwiftCuckoo

class TaskTests: XCTestCase {
    
    // Given a unique identifier and a start time for a task
    var taskId: ObjectIdentifier!
    var startTime: Date!

    override func setUp() {
        super.setUp()
        taskId = ObjectIdentifier(self) // Using self as a dummy unique identifier
        startTime = Date() // Current date/time for the start time
    }
    
    // Test for when the task is created without an end time
    func testDuration_whenEndTimeIsNil_shouldReturnNil() {
        // Act
        let task = Task(id: taskId, startTime: startTime)
        
        // Assert
        XCTAssertNil(task.duration, "Duration should be nil when endTime is not set.")
    }
    
    // Test for when the task is created with a valid end time
    func testDuration_whenEndTimeIsSet_shouldReturnCorrectValue() {
        // Arrange
        let endTime = startTime.addingTimeInterval(3600) // 1 hour later
        
        // Act
        let task = Task(id: taskId, startTime: startTime, endTime: endTime)
        
        // Assert
        XCTAssertEqual(task.duration, 3600, "Duration should be 3600 seconds (1 hour) when endTime is set correctly.")
    }
    
    // Test for when the task is created with end time earlier than start time
    func testDuration_whenEndTimeIsEarlierThanStartTime_shouldReturnNil() {
        // Arrange
        let endTime = startTime.addingTimeInterval(-3600) // 1 hour earlier
        
        // Act
        let task = Task(id: taskId, startTime: startTime, endTime: endTime)
        
        // Assert
        XCTAssertNil(task.duration, "Duration should be nil when endTime is set to earlier than startTime.")
    }
    
    // Test for when the task is created with end time equal to start time
    func testDuration_whenEndTimeIsEqualToStartTime_shouldReturnZero() {
        // Arrange
        let endTime = startTime // same time
        
        // Act
        let task = Task(id: taskId, startTime: startTime, endTime: endTime)
        
        // Assert
        XCTAssertEqual(task.duration, 0, "Duration should be 0 seconds when endTime is equal to startTime.")
    }
}
