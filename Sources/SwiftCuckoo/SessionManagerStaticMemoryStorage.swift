import Foundation

/// An actor responsible for managing session storage in memory.
/// This implementation is a static in-memory store that provides
/// concurrent access to session data in a thread-safe manner.
public actor SessionManagerStaticMemoryStorage: SessionManagerStorage {
    
    /// A static dictionary holding sessions, indexed by their identifiers.
    static var sessions: [Session.Identifier: Session] = [:]
    
    /// Initializes a new instance of `SessionManagerStaticMemoryStorage`.
    public init() {}
    
    /// Registers a new session in the static memory storage.
    ///
    /// - Parameter session: The `Session` instance to be registered.
    /// - Throws: An error if the registration process fails.
    public func register(session: Session) async throws {
        Self.sessions[session.id] = session
    }
    
    /// Removes a specific session from the static memory storage.
    ///
    /// - Parameter session: The `Session` instance to be removed.
    /// - Throws: An error if the removal process fails.
    public func remove(session: Session) async throws {
        Self.sessions.removeValue(forKey: session.id)
    }
    
    /// Updates an existing session in the static memory storage.
    ///
    /// - Parameter session: The `Session` instance to be updated with new details.
    /// - Throws: An error if the update process fails.
    public func update(session: Session) async throws {
        Self.sessions[session.id] = session
    }
    
    /// Retrieves a session from the static memory storage by its identifier.
    ///
    /// - Parameter id: The unique identifier for the session to retrieve.
    /// - Returns: The `Session` instance if found, or `nil` if no session
    ///            exists with the provided identifier.
    /// - Throws: An error if the retrieval process fails.
    public func session(for id: Session.Identifier) async throws -> Session? {
        Self.sessions[id]
    }
}
