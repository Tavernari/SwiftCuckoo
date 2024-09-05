import Foundation

/// A protocol that defines time-tracking functionality for tasks.
public protocol TimeTracking {

    /// Starts or resumes a session for the given task ID.
    ///
    /// - Parameter taskID: The unique identifier for the task.
    /// - Returns: The `Date` representing the start time of the session.
    func startTracking(sessionId: Session.Identifier) -> Date
}
