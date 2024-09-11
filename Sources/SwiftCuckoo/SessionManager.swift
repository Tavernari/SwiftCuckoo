import Foundation

/// Error types for the `SessionManager` related operations.
public enum SessionManagerError: Error {
    case cannotStartSessionTwice  /// Indicates an attempt to start a session that is already running.
}

/// A protocol that defines the required functionalities for session storage, enabling
/// asynchronous operations for registering, removing, updating, and retrieving sessions.
public protocol SessionManagerStorage: Sendable {
    /// Registers a new session in the storage.
    ///
    /// - Parameter session: The session instance to be registered.
    /// - Throws: An error if the registration fails.
    func register(session: Session) async throws
    
    /// Removes a specific session from the storage.
    ///
    /// - Parameter session: The session instance to be removed.
    /// - Throws: An error if the removal fails.
    func remove(session: Session) async throws
    
    /// Updates an existing session in the storage.
    ///
    /// - Parameter session: The session instance with updated details.
    /// - Throws: An error if the update fails.
    func update(session: Session) async throws
    
    /// Retrieves a session based on its identifier.
    ///
    /// - Parameter id: The unique identifier for the session to retrieve.
    /// - Returns: The session instance if found, or `nil` if not.
    /// - Throws: An error if the retrieval fails.
    func session(for id: Session.Identifier) async throws -> Session?
}

/// A struct responsible for managing time-tracking sessions.
/// It handles starting, stopping, and retrieving sessions,
/// leveraging a specified storage mechanism to persist session data.
public struct SessionManager: TimeTracking {
    
    private var sessionManagerStorage: SessionManagerStorage
    
    /// Initializes a new instance of `SessionManager` with a specified storage instance.
    ///
    /// - Parameter sessionManagerStorage: An instance conforming to `SessionManagerStorage`,
    ///                                     defaults to `SessionManagerStaticMemoryStorage`.
    public init(sessionManagerStorage: SessionManagerStorage = SessionManagerStaticMemoryStorage()) {
        self.sessionManagerStorage = sessionManagerStorage
    }

    /// Starts or resumes a session for the given session ID.
    ///
    /// If there is an existing session corresponding to the session ID, it attempts to start it;
    /// if not, it creates a new session.
    ///
    /// - Parameter sessionId: The unique identifier for the session.
    /// - Throws: An error of type `SessionManagerError` if there is an attempt
    ///           to start an already running session.
    /// - Returns: The `Date` representing the start time of the active or resumed session.
    public func startTracking(sessionId: Session.Identifier) async throws {
        do {
            var session = try await self.sessionManagerStorage.session(for: sessionId) ?? Session(id: sessionId)
            try session.start(on: Date())
            try await self.sessionManagerStorage.register(session: session)
        } catch Session.Error.cannotStartTwice {
            throw SessionManagerError.cannotStartSessionTwice
        } catch {
            throw error
        }
    }
    
    /// Retrieves a session by its identifier.
    ///
    /// - Parameter sessionId: The unique identifier for the session to retrieve.
    /// - Returns: An optional `Session`, which will be `nil` if no session is found
    ///            corresponding to the provided identifier.
    /// - Throws: An error if the session retrieval fails.
    public func session(byId sessionId: Session.Identifier) async throws -> Session? {
        try await sessionManagerStorage.session(for: sessionId)
    }
}
