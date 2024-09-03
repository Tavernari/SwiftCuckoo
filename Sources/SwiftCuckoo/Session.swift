import Foundation

/// A model representing a session for time tracking in the SwiftCuckoo application.
///
/// The `Session` structure is designed to encapsulate the details of a task that
/// includes its start time, optional end time, and the duration calculated
/// from these timestamps. This structure aids in managing and reporting
/// the time spent on various tasks, providing valuable insights for users
/// looking to optimize their productivity.
public struct Session: Equatable, Hashable {
    /// A unique identifier for the session instance.
    public var id: Identifier
    
    /// The start time of the session. This indicates when the session began.
    public var startTime: Date
    
    /// The optional end time of the session. This indicates when the session
    /// was completed or could still be ongoing.
    public var endTime: Date?

    /// Initializes a new session instance with a unique identifier, a start
    /// time, and an optional end time.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the session. This helps in managing
    ///          and tracking individual session instances.
    ///   - startTime: The starting time of the session, indicating when it begins.
    ///   - endTime: The end time of the session, representing when the session is
    ///              completed. This parameter is optional and defaults to nil for ongoing sessions.
    ///
    /// - Note: Ensure that the `endTime` is provided if the session is completed.
    package init(id: Identifier, startTime: Date, endTime: Date? = nil) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
    }
    
    /// Calculates the duration of the session.
    ///
    /// - Throws: An error of type `Error` if:
    ///   - The `endTime` is missing.
    ///   - The `endTime` is before the `startTime`, indicating an invalid time range.
    ///
    /// - Returns: The duration of the session as a `TimeInterval` representing
    ///   the time spent from the start time to the end time.
    public func duration() throws(Session.Error) -> TimeInterval {
        guard let endTime else {
            throw Error.missingEndTime
        }
        
        guard endTime >= startTime else {
            throw Error.endTimeBeforeStartTime
        }
        
        return endTime.timeIntervalSince(startTime)
    }
}

// MARK: - Identifier

extension Session {
    /// A unique identifier for the session, conforming to `RawRepresentable`,
    /// `Equatable`, and `Hashable` protocols for easy management and comparison.
    public struct Identifier: RawRepresentable, Equatable, Hashable {
        /// The raw string value representing the identifier.
        public let rawValue: String
        
        /// Initializes a new identifier with a given raw value.
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
    /// used for error handling during duration calculations.
    public enum Error: CustomNSError {
        /// Indicates that the end time is missing, required for duration calculation.
        case missingEndTime
        
        /// Indicates that the end time is set earlier than the start time,
        /// leading to an invalid duration result.
        case endTimeBeforeStartTime
    }
}
