import Foundation
import Testing
@testable import SwiftCuckoo

private extension Session.Identifier {
    static let test = Session.Identifier(rawValue: "test")
    static let test2 = Session.Identifier(rawValue: "test2")
}

private final actor SessionManagerStorageStub: SessionManagerStorage {
    
    var sessions: [Session.Identifier: Session] = [:]
    
    private var registerThrowsError: Error?
    
    @discardableResult
    func throwErrorOnRegister(_ error: Error) async -> Self {
        registerThrowsError = error
        return self
    }
    
    func register(session: SwiftCuckoo.Session) async throws {
        if let registerThrowsError {
            throw registerThrowsError
        }
        
        sessions[session.id] = session
    }
    
    func remove(session: SwiftCuckoo.Session) async throws {
        sessions.removeValue(forKey: session.id)
    }
    
    func update(session: SwiftCuckoo.Session) async throws {
        sessions[session.id] = session
    }
    
    func session(for id: SwiftCuckoo.Session.Identifier) async throws -> SwiftCuckoo.Session? {
        sessions[id]
    }
}

final class SessionManagerTests {
    private var sessionManagerStorageStub = SessionManagerStorageStub()
    lazy var sessionManager = SessionManager(sessionManagerStorage: self.sessionManagerStorageStub)

    /// Tests starting tracking when the session does not exist, ensuring the session is created.
    @Test("Starting tracking when session doesn't exist creates the session.")
    func testStartTracking_when_session_doesnt_exist() async throws {
        // Arrange: Verify that the session is initially not present
        await #expect(
            try sessionManager.session(byId: .test) == nil,
            "Session with identifier test should not exist at the start."
        )
        
        // Act: Start tracking a new session
        try? await sessionManager.startTracking(sessionId: .test)
        
        // Assert: Verify that the session is now created
        await #expect(
            try sessionManager.session(byId: .test) != nil,
            "Session with identifier test should be present after starting tracking."
        )
        
        // Arrange: Verify that another session does not exist
        await #expect(
            try sessionManager.session(byId: .test2) == nil,
            "Session with identifier test2 should not exist at the start."
        )
        
        // Act: Start tracking a session with a different identifier
        try? await sessionManager.startTracking(sessionId: .test2)
        
        // Assert: Verify that the second session is created
        await #expect(
            try sessionManager.session(byId: .test2) != nil,
            "Session with identifier test2 should be present after starting tracking."
        )
    }
    
    /// Tests starting tracking on the same session twice to ensure proper error handling.
    @Test("Attempting to start tracking twice should throw an error.")
    func testStartTrackingTwice() async throws {
        // Arrange: Start tracking a session
        try? await sessionManager.startTracking(sessionId: .test)
        
        // Assert: Verify that the session is now created
        await #expect(try sessionManager.session(byId: .test) != nil,
                       "Session with identifier test should be present after first start.")
        
        // Act & Assert: Attempt to start the same session again and expect an error
        await #expect(
            throws: SessionManagerError.cannotStartSessionTwice,
            "Starting a session that is already running should throw an error.",
            performing: {
                try await sessionManager.startTracking(sessionId: .test)
            }
        )
    }
    
    /// Tests attempting to start tracking a session when the registration fails.
    @Test("Starting tracking should fail when registration fails.")
    func testStartTracking_when_register_fails() async throws {
        // Arrange: Configure the storage stub to throw an error during registration
        await sessionManagerStorageStub.throwErrorOnRegister(NSError(domain: "Register Error", code: 1))
        
        // Act & Assert: Attempt to start tracking and expect an error
        await #expect(
            throws: NSError.self,
            "Starting a session should throw an error when registration fails.",
            performing: {
                try await sessionManager.startTracking(sessionId: .test)
            }
        )
    }
}
