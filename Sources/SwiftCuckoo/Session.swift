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
    }
}
