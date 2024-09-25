import Foundation
import Testing
@testable import SwiftCuckoo

final class LapTests {

    /// Tests that starting a lap sets the start time
    @Test("Start lap should start time")
    func testStartLap() throws {
        // Arrange: Create a lap object with a defined start time
        let startTime: Date = .distantPast
        var lap = Lap(startTime: startTime)

        // Act: Start the lap
        try lap.start(on: startTime)

        // Assert: Verify that lap time is set
        #expect(
            lap.startTime == startTime,
            "The lap's start time should be set to provided start time")
    }

    /// Test that starting a lap twice will throw an error
    @Test("Starting a lap twice should throw an error")
    func testStartingLapTwiceThrowsError() throws {

        // Arrange: Create new lap
        var lap = Lap(startTime: .now)
        try lap.start()

        // Act & Assert: Attempt to start the lap again and expect an error
        #expect(
            throws: Lap.Error.lapAlreadyStarted,
            "Starting a lap that is already active should throw an error",
            performing: {
                try lap.start()
            }
        )
    }

    /// Test that stopping a lap that hasn't started will throw an error
    @Test("Stopping a lap that hasn't started should throw an error")
    func testStoppingInactiveLapThrowsError() throws {

        // Arrange: Create new lap
        var lap = Lap(startTime: .now)

        // Act & Assert: Attempt to start the lap again and expect an error
        #expect(
            throws: Lap.Error.tryingStopNonStartedLap,
            "Starting a lap that is already active should throw an error",
            performing: {
                try lap.stop()
            }
        )
    }

    /// Tests that stopping a lap sets the stop time
    @Test("Stop lap should set end time")
    func testStopLap() throws {
        // Arrange: Create a lap object and a defined end time
        let endTime: Date = .distantFuture
        var lap = Lap(startTime: .now)
        try lap.start()

        // Act: Stop the lap
        try lap.stop(on: endTime)


        // Assert: Verify that lap time is set
        #expect(
            lap.endTime == endTime,
            "The lap's end time should be set to provided end time")
        #expect(
            lap.endTime != nil,
            "The lap's end time should not be nil")
    }

    /// Tests that requesting the duration of a lap without starting one throws an error.
    @Test("Requesting duration without starting a lap should throw a lap not active error.")
    func testDurationWithoutStartTimeShouldThrowError() throws {
        // Arrange: Create a new lap without starting it
        let lap = Lap()

        // Act & Assert: Attempt to get the duration and expect an error
        #expect(
            throws: Lap.Error.tryingStopNonStartedLap,
            "Duration should not be calculable if the lap has not started.",
            performing: {
                try lap.duration()
            }
        )
    }

    /// Tests that requesting the duration of a lap without ending one throws an error.
    @Test("Requesting duration without ending a lap should throw a lap still active error.")
    func testDurationWithoutEndTimeShouldThrowError() throws {
        // Arrange: Create a new lap without starting it
        var lap = Lap()
        try lap.start(on: .now)

        // Act & Assert: Attempt to get the duration and expect an error
        #expect(
            throws: Lap.Error.lapAlreadyStarted,
            "Duration should not be calculable if the lap has not ended.",
            performing: {
                try lap.duration()
            }
        )
    }

    /// Tests that requesting the duration from a valid lap returns the correct duration
    @Test("Request duration with a lap that has a start and end time should return the correct duration")
    func testDurationWithValidLap() throws {
        // Arrange: Create new lap object, then start and end it
        var lap = Lap()
        try lap.start(on: .now)
        try lap.stop(on: .distantFuture)

        // Act: Calculate the duration of the lap
        let duration = try lap.duration()

        // Assert: Very that the duration is greater than zero
        #expect(
            duration > 0,
            "The duration should be greater than zero"
        )
    }
}
