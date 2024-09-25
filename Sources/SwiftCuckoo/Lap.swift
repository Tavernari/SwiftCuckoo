import Foundation

/// A model representing an individual lap within a session.
///
/// The `Lap` structure tracks the start time, end time, and calculates the duration
/// of a single lap, providing a way to monitor intervals within a task or session.
public struct Lap: Equatable, Hashable {

    /// Defines the different states of a  `Lap`.
    public enum LapStatus: Equatable {
        case active                /// Indicates the lap is active.
        case inactive              /// Indicates the lap is inactive.
    }

    /// A unique identifier for the lap instance.
    private(set) var id: UUID

    /// The start time of the lap.
    private(set) var startTime: Date?

    /// The optional end time of the lap. Defaults to `nil` if the lap is ongoing.
    private(set) var endTime: Date?

    /// Initializes a new lap instance with a specified start time and an optional end time.
    ///
    /// - Parameters:
    ///   - startTime: The start time of the lap.
    ///   - endTime: The end time of the lap. Defaults to `nil` for ongoing laps.
    public init(startTime: Date? = nil, endTime: Date? = nil) {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = endTime
    }

    public mutating func start(on date: Date = Date()) throws {
        guard lapStatus() == .inactive else {
            throw Error.lapAlreadyStarted
        }
        self.startTime = date
    }

    /// Stops the lap at the specified date.
    ///
    /// - Parameter date: The date when the lap ends. Defaults to the current date.
    /// - Throws: An error if the lap has already ended.
    public mutating func stop(on date: Date = Date()) throws {
        guard lapStatus() == .active else {
            throw Error.tryingStopNonStartedLap
        }

        self.endTime = date
    }

    /// Calculates the duration of the lap.
    ///
    /// - Throws: An error if the lap has not ended.
    /// - Returns: The duration of the lap as a `TimeInterval`.
    public func duration() throws -> TimeInterval {
        guard let endTime else {
            throw Error.lapAlreadyStarted
        }

        guard let startTime else {
            throw Error.tryingStopNonStartedLap
        }

        return endTime.timeIntervalSince(startTime)
    }
    
    /// Determines the current status of a lap.
    ///
    /// - Returns: The current status as a `LapStatus` enumerator indicating whether
    ///   the session is active, or inactive.
    public func lapStatus() -> LapStatus {
        guard endTime != nil else {
            return .active
        }

        return .inactive
    }
}

// MARK: - Lap Errors

extension Lap {
    /// Error types specific to the `Lap` structure, used for error handling.
    public enum Error: CustomNSError {
        case tryingStopNonStartedLap      /// Indicates that the lap is stopped already..
        case lapAlreadyStarted         /// Indicates that the lap is already started.
    }
}
