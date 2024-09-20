import Foundation

/// A model representing an individual lap within a session.
///
/// The `Lap` structure tracks the start time, end time, and calculates the duration
/// of a single lap, providing a way to monitor intervals within a task or session.
public struct Lap: Equatable, Hashable {

    /// The start time of the lap.
    public var startTime: Date

    /// The optional end time of the lap. Defaults to `nil` if the lap is ongoing.
    public var endTime: Date?

    /// Initializes a new lap instance with a specified start time and an optional end time.
    ///
    /// - Parameters:
    ///   - startTime: The start time of the lap.
    ///   - endTime: The end time of the lap. Defaults to `nil` for ongoing laps.
    public init(startTime: Date, endTime: Date? = nil) {
        self.startTime = startTime
        self.endTime = endTime
    }

    /// Stops the lap at the specified date.
    ///
    /// - Parameter date: The date when the lap ends. Defaults to the current date.
    /// - Throws: An error if the lap has already ended.
    public mutating func stop(on date: Date = Date()) throws {
        guard self.endTime == nil else {
            throw Error.lapAlreadyStopped
        }

        self.endTime = date
    }

    /// Calculates the duration of the lap.
    ///
    /// - Throws: An error if the lap has not ended.
    /// - Returns: The duration of the lap as a `TimeInterval`.
    public func duration() throws -> TimeInterval {
        guard let endTime else {
            throw Error.lapNotEnded
        }

        return endTime.timeIntervalSince(startTime)
    }

    /// Determines the current status of the lap.
    ///
    /// - Returns: A boolean indicating whether the lap is still running or has completed.
    public func isRunning() -> Bool {
        return self.endTime == nil
    }
}

// MARK: - Lap Errors

extension Lap {
    /// Error types specific to the `Lap` structure, used for error handling.
    public enum Error: CustomNSError {
        case lapAlreadyStopped      /// Indicates that the lap has already been stopped.
        case lapNotEnded            /// Indicates that the lap has not ended.
    }
}
