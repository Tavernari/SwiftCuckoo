import Foundation

/// A model representing a session for time tracking in the SwiftCuckoo application.
///
/// The `Session` structure encapsulates the details of a task, including its start
/// time, optional end time, and the duration calculated from these timestamps.
/// This structure aids in managing and reporting the time spent on various tasks,
/// providing valuable insights for users looking to optimize their productivity.
public struct Session: Equatable, Hashable {
    
    /// Defines the possible validation errors for a `Session`.
    public enum Invalid: Equatable {
        case startTimeInFuture  /// Indicates the start time is set in the future.
        case unknown             /// Represents an unknown error state.
    }
    
    /// Defines the possible states of a `Session`.
    public enum Status: Equatable {
        case idle                /// Indicates the session is not currently active.
        case running             /// Indicates the session is currently in progress.
        case completed           /// Indicates the session has completed.
        case invalid(Invalid)    /// Indicates the session has an invalid state with a specific reason.
    }
    
    /// A unique identifier for the session instance.
    public var id: Identifier
    
    /// The start time of the session. This indicates when the session began.
    public var startTime: Date?
    
    /// The optional end time of the session. This indicates when the session
    /// was completed or could still be ongoing.
    public var endTime: Date?

    /// Array of `Lap` which stores lap information
    // TODO: Maybe fix docC
    private(set) var laps: [Lap]

    /// Initializes a new session instance with a unique identifier and an optional start time.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the session, aiding in tracking individual sessions.
    ///   - startTime: The starting time of the session, indicating when it begins. Defaults to nil.
    ///   - endTime: The end time of the session. This parameter is optional and defaults to nil.
    ///
    /// - Note: Ensure that `endTime` is provided if the session is completed.
    public init(id: Identifier) {
        self.id = id
        self.startTime = nil
        self.endTime = nil
        self.laps = []
    }
    
    /// Starts the session at the specified date.
    ///
    /// - Parameter date: The date to start the session. Defaults to the current date.
    /// - Throws: An error of type `Error` if:
    ///   - The session is already running (cannot start twice).
    public mutating func start(on date: Date = Date()) throws {
        guard status() == .idle else {
            throw Error.cannotStartTwice
        }
        
        self.startTime = date
    }
    
    /// Stops the session at the specified date.
    ///
    /// - Parameter date: The date to stop the session. Defaults to the current date.
    /// - Throws: An error of type `Error` if:
    ///   - The session has not been started (must start before stopping).
    public mutating func stop(on date: Date = Date()) throws {
        guard status() == .running else {
            throw Error.shouldStartSession
        }
        
        self.endTime = date
    }
    
    /// Calculates the duration of the session.
    ///
    /// - Throws: An error of type `Error` if:
    ///   - The `endTime` is missing.
    ///   - The `endTime` is before the `startTime`, indicating an invalid time range.
    ///
    /// - Returns: The duration of the session as a `TimeInterval` representing
    ///   the time spent from the start time to the end time.
    public func duration() throws -> TimeInterval {
        guard let startTime else {
            throw Error.shouldStartSession
        }
        
        guard let endTime else {
            throw Error.shouldStopSession
        }
        
        guard self.status() == .completed else {
            throw Error.invalidStartAndEndTimes
        }
        
        return endTime.timeIntervalSince(startTime)
    }
    
    /// Determines the current status of the session.
    ///
    /// - Returns: The current status as a `Status` enumerator indicating whether
    ///   the session is idle, running, completed, or invalid.
    public func status() -> Status {
        guard let startTime else {
            return .idle
        }
        
        guard let endTime else {
            return .running
        }
        
        guard startTime.compare(endTime) != .orderedDescending else {
            return .invalid(.startTimeInFuture)
        }
        
        return .completed
    }

    // MARK: - Session Lap Functions

    /// Retrieves a specific lap based on its index in the collection.
    ///
    /// This function returns the lap at the specified index in the `laps` collection.
    ///
    /// - Parameter id: The index of the lap to be retrieved, starting from `0` for the first lap.
    /// - Returns: An optional `Lap` instance. If the index is valid (within the range of the `laps` collection), it returns the `Lap` object; otherwise, returns `nil`.
    public func getLap(id: Int) -> Lap? {
        guard id >= 0 && id < laps.count else {
            return nil
        }
        return laps[id]
    }

    /// Adds a new lap to the session and starts it.
    ///
    /// This function creates a new `Lap` instance with the current time as the start time. It attempts to start the lap, and if successful, appends it to the `laps` collection and returns the `Lap` instance.
    ///
    /// - Throws:
    ///     - `Error.lapAlreadyStarted`: If the lap is already started. Although this scenario is unlikely since a new lap is created, the error is still handled for safety.
    /// - Returns: The newly added `Lap` instance.
    public mutating func addLap() throws -> Lap {
        var lap = Lap(startTime: Date())

        do {
            try lap.start()
        } catch Lap.Error.lapAlreadyStarted {
            throw Error.lapAlreadyStarted
        }

        self.laps.append(lap)
        return lap
    }

    /// Stops an existing lap based on the provided index.
    ///
    /// This function attempts to retrieve a lap at the specified index and stop it. If the lap has not been started yet,
    /// an error will be thrown indicating that the lap cannot be stopped.
    ///
    /// - Parameter id: The index of the lap to be stopped, starting from `0` for the first lap.
    /// - Throws:
    ///     - `Error.tryingStopNonStartedLap`: If the function attempts to stop a lap that has not been started.
    /// - Note: If the lap does not exist at the given index, this function will do nothing, as the `getLap(id:)` function returns `nil`.
    public mutating func stopLap(id: Int) throws {
        var lap = getLap(id: id)

        do {
            try lap?.stop()
        } catch Lap.Error.tryingStopNonStartedLap {
            throw Error.tryingStopNonStartedLap
        }
    }
}

// MARK: - Identifier

extension Session {
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

// MARK: - Session Errors

extension Session {
    /// Error types specific to the `Session` structure, conforming to `CustomNSError`,
    /// used for error handling during duration calculations and session state management.
    public enum Error: CustomNSError {
        case shouldStartSession               /// Indicates that the session should have been started before this action.
        case shouldStopSession                /// Indicates that the session should have been stopped before this action.
        case cannotStartTwice                 /// Indicates an attempt to start a session that is already running.
        case invalidStartAndEndTimes          /// Indicates an inconsistency between the start and end times.
        case lapAlreadyStarted                /// Indicates that the session is unable to start/add a lap
        case tryingStopNonStartedLap          /// Indicates that the session is unable to stop the lap
    }
}
