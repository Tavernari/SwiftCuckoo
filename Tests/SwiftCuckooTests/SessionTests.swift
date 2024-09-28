import Foundation
@testable import SwiftCuckoo
import Testing

private extension Session.Identifier {
    static let test = Session.Identifier(rawValue: "test")
}

final class SessionTests {
    
    /// Tests that starting a session sets the start time correctly.
    @Test("Start session should set start time.")
    func testStart_shouldSetStartTime() throws {
        // Arrange: Create a new session and define the start time
        let startTime: Date = .distantPast
        var session = Session(id: .test)
        
        // Act: Start the session at the specified start time
        try session.start(on: startTime)
        
        // Assert: Verify that the session's start time is set correctly
        #expect(
            session.startTime == startTime,
            "The session's start time should be set to the provided start time."
        )
    }

    /// Tests that attempting to start an already started session throws an error.
    @Test("Starting a session twice should throw an already started error.")
    func testStartTwice_shouldThrowAlreadyStartedError() throws {
        // Arrange: Create a new session and start it
        var session = Session(id: .test)
        try session.start()
        
        // Act & Assert: Attempt to start the session again and expect an error
        #expect(
            throws: Session.Error.cannotStartTwice,
            "Starting a session that is already running should throw an error.",
            performing: {
                try session.start()
            }
        )
    }
    
    /// Tests that stopping a session without starting it first throws an error.
    @Test("Stopping a session without starting it should throw a missing start time error.")
    func testStopWithoutStartSession_shouldThrowMissingStartTimeError() throws {
        // Arrange: Create a new session without starting it
        var session = Session(id: .test)
        
        // Act & Assert: Attempt to stop the session and expect an error
        #expect(
            throws: Session.Error.shouldStartSession,
            "Stopping a session that has not been started should throw an error.",
            performing: {
                try session.stop()
            }
        )
    }
    
    /// Tests that stopping a session sets the end time correctly.
    @Test("Stopping a session should set the end time.")
    func testStop_shouldSetEndTime() throws {
        // Arrange: Create a new session and start it
        let endTime: Date = .distantFuture
        var session = Session(id: .test)
        try session.start()
        
        // Act: Stop the session at the specified end time
        try session.stop(on: endTime)
        
        // Assert: Verify that the session's end time is set correctly
        #expect(
            session.endTime != nil,
            "The session's end time should be set upon stopping the session."
        )
    }
    
    /// Tests that requesting the duration of a session without starting it throws an error.
    @Test("Requesting duration without starting a session should throw a missing start time error.")
    func testDurationWithoutStartSession_shouldThrowMissingStartTimeError() throws {
        // Arrange: Create a new session without starting it
        let session = Session(id: .test)
        
        // Act & Assert: Attempt to get the duration and expect an error
        #expect(
            throws: Session.Error.shouldStartSession,
            "Duration should not be calculable if the session has not started.",
            performing: {
                try session.duration()
            }
        )
    }
    
    /// Tests that requesting the duration of a session that has started but not stopped throws an error.
    @Test("Requesting duration with started but not stopped session should throw a missing end time error.")
    func testDurationWithStartButNotStopSession_shouldThrowMissingEndTimeError() throws {
        // Arrange: Create a new session and start it
        var session = Session(id: .test)
        try session.start()
        
        // Act & Assert: Attempt to get the duration and expect an error
        #expect(
            throws: Session.Error.shouldStopSession,
            "Duration should not be calculable without an end time.",
            performing: {
                try session.duration()
            }
        )
    }
    
    /// Tests that requesting the duration of a session that has been both started and stopped returns the correct duration.
    @Test("Requesting duration with started and stopped session should return a valid duration.")
    func testDuringWithStartAndStopSession_shouldReturnDuration() throws {
        // Arrange: Create a new session with defined start and end times
        let startTime: Date = .distantPast
        let endTime: Date = .distantFuture
        var session = Session(id: .test)
        try session.start(on: startTime)
        
        // Act: Stop the session at the specified end time
        try session.stop(on: endTime)
        
        // Assert: Verify that the duration is greater than zero
        #expect(
            try session.duration() > 0,
            "The duration of the session should be greater than zero."
        )
    }
    
    /// Tests that requesting the duration of a session where start and stop times are the same returns zero.
    @Test("Requesting duration with started and stopped session having the same time should return zero.")
    func testDuringWithStartAndStopSessionWithSameTime_shouldReturnZero() throws {
        // Arrange: Create a new session with the same start and end time
        let sameTime: Date = .distantPast
        var session = Session(id: .test)
        try session.start(on: sameTime)
        
        // Act: Stop the session at the same time
        try session.stop(on: sameTime)
        
        // Assert: Verify that the duration is zero
        #expect(
            try session.duration() == 0,
            "The duration should be zero when the start and stop times are the same."
        )
    }
    
    /// Tests that requesting the duration of a session where the start time is in the future throws an error.
    @Test("Requesting duration where start time is in the future should throw a start time in future error.")
    func testDurationWhereStartTimeIsInTheFuture_shouldThrowStartTimeInFutureError() throws {
        // Arrange: Create a new session with a future start time and past end time
        let startTime: Date = .distantFuture
        let endTime: Date = .distantPast
        var session = Session(id: .test)
        try session.start(on: startTime)
        
        // Act: Attempt to stop the session at the past end time
        try session.stop(on: endTime)
        
        // Assert: Verify that calculating the duration throws an error
        #expect(
            throws: Session.Error.invalidStartAndEndTimes,
            "Duration calculation should fail when the start time is in the future.",
            performing: {
                try session.duration()
            }
        )
    }

    /// Test that requesting to add a lap to a session is successful
    @Test("Test that a session is able to start a lap")
    func testSessionCanStartLap() throws {
        // Arrange
        var session = Session(id: .test)
        try session.start()

        // Act: Attempt to start and add a lap
        var lap = try session.addLap()

        // Assert: verify that the laps start time exists
        #expect(
            lap.startTime != nil,
            "laps start time should not be nil"
        )
        #expect(
            session.laps.count < 0,
            "Session should have at least one lap"
        )
    }

    /// Test that requesting to stop a lap to a session is successful
    @Test("Test that a session is able to stop a lap")
    func testSessionCanStopLap() throws {
        // Arrange
        var session = Session(id: .test)
        try session.start()
        var lap = try session.addLap()
        let endTime: Date = .distantFuture

        // Act: Attempt to stop a lap
        try lap.stop(on: endTime)


        // Assert: verify that the laps start time exists
        #expect(
            lap.endTime == endTime,
            "laps start time should not be nil"
        )
    }

    /// Test that requesting to stop a lap twice should throw an error
    @Test("Test that a session is not able to stop a lap twice")
    func testSessionCantStopLapTwice() throws {
        // Arrange
        var session = Session(id: .test)
        try session.start()
        var lap = try session.addLap()
        let endTime: Date = .distantFuture

        // Act: Attempt to stop a lap
        try lap.stop(on: endTime)

        #expect(
            throws: Session.Error.tryingStopNonStartedLap,
            "Stopping a lap twice should fail",
            performing: {
                try lap.stop()
            }
        )
    }

    /// Test that retrieving a lap will be successful
    @Test("Test that a session able to retrieve a lap")
    func testSessionGetLap() throws {
        // Arrange
        var session = Session(id: .test)
        try session.start()
        _ = try session.addLap()
        _ = try session.addLap()


        // Act: Attempt to stop a lap
        let firstLap = session.getLap(id: 0)

        #expect(
            firstLap != nil,
            "Calling get lap will return a lap"
        )
    }
}
