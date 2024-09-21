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
    public var id: Identifier

    /// The start time of the lap.
    public var startTime: Date

    /// The optional end time of the lap. Defaults to `nil` if the lap is ongoing.
    public var endTime: Date?

    /// Initializes a new lap instance with a specified start time and an optional end time.
    ///
    /// - Parameters:
    ///   - startTime: The start time of the lap.
    ///   - endTime: The end time of the lap. Defaults to `nil` for ongoing laps.
    public init(id: Identifier, startTime: Date, endTime: Date? = nil) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
    }

    public mutating func start(on date: Date = Date()) throws {
        guard lapStatus() == .inactive else {
            throw Error.lapActive
        }
        self.startTime = date
    }

    /// Stops the lap at the specified date.
    ///
    /// - Parameter date: The date when the lap ends. Defaults to the current date.
    /// - Throws: An error if the lap has already ended.
    public mutating func stop(on date: Date = Date()) throws {
        guard lapStatus() == .active else {
            throw Error.lapNotActive
        }

        self.endTime = date
    }

    /// Calculates the duration of the lap.
    ///
    /// - Throws: An error if the lap has not ended.
    /// - Returns: The duration of the lap as a `TimeInterval`.
    public func duration() throws -> TimeInterval {
        guard let endTime else {
            throw Error.lapActive
        }

        return endTime.timeIntervalSince(startTime)
    }
    
    /// Determines the current status of a lap.
    ///
    /// - Returns: The current status as a `LapStatus` enumerator indicating whether
    ///   the session is active, or inactive.
    public func lapStatus() -> LapStatus {
        guard let endTime else {
            return .active
        }

        return .inactive
    }
}

// MARK: - Identifier

extension Lap {
    /// A unique identifier for the session, conforming to `RawRepresentable`,
    /// `Equatable`, and `Hashable` protocols for easy management and comparison.
    public struct Identifier: RawRepresentable, Equatable, Hashable {
        /// The raw string value representing the identifier.
        public let rawValue: String

        /// Initializes a new identifier with the specified raw value.
        ///
        /// - Parameter rawValue: The string value that represents the identifier.
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Lap Errors

extension Lap {
    /// Error types specific to the `Lap` structure, used for error handling.
    public enum Error: CustomNSError {
        case lapNotActive      /// Indicates that the lap is inactive.
        case lapActive         /// Indicates that the lap is already active.
    }
}
