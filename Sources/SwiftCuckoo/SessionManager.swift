import Foundation

/// A struct responsible for managing time-tracking sessions
public struct SessionManager: TimeTracking {
    private init() {}

    /// stores all sessions.
    static public var sessions: [String: Session] = [:]

    /// Starts or resumes a session for the given task ID.
    ///
    /// - Parameter taskID: The unique identifier for the task.
    /// - Returns: The `Date` representing the start time of the active or resumed session.
    static public func startTracking(sessionId: Session.Identifier) -> Date {
        // check if there is an existing session that hasn't ended for a sessionId
        if let existingSession = SessionManager.sessions[sessionId.rawValue], existingSession.endTime == nil {
            return existingSession.startTime
        } else {
            let session = Session(id: sessionId, startTime: Date())
            SessionManager.sessions[sessionId.rawValue] = session
            return session.startTime
        }
    }
}
