import Foundation
import Testing
@testable import SwiftCuckoo

private extension Session.Identifier {
    static let test = Session.Identifier(rawValue: "test")
}

final class SessionManagerStaticMemoryStorageTests {
    
    private let sessionManagerStaticMemoryStorage = SessionManagerStaticMemoryStorage()
    
    /// Tests the operations of `SessionManagerStaticMemoryStorage` for registering,
    /// updating, and removing sessions in sequence, ensuring that the appropriate session
    /// states are reflected at each step.
    @Test("Testing operations of SessionManagerStaticMemoryStorage: registering, updating, and removing a session.")
    func testSessionManagerStaticMemoryStorage_when_registering_updating_and_removing_session() async throws {
        // Arrange: Create a new session for testing
        var session = Session(id: .test)
        
        // Act: Attempt to retrieve a session that hasn't been registered yet
        await #expect(
            try sessionManagerStaticMemoryStorage.session(for: .test) == nil,
            "The session should not exist before registration."
        )
        
        // Act: Register the session
        try await sessionManagerStaticMemoryStorage.register(session: session)
        
        // Assert: Check if the session status is idle after registration
        await #expect(
            try sessionManagerStaticMemoryStorage.session(for: .test)?.status() == .idle,
            "After registration, the session status should be idle."
        )
        
        // Act: Start the session
        try session.start()
        
        // Act: Update the session in storage
        try await sessionManagerStaticMemoryStorage.update(session: session)
        
        // Assert: Verify that the session status is now running
        await #expect(
            try sessionManagerStaticMemoryStorage.session(for: .test)?.status() == .running,
            "After starting, the session status should be running."
        )
        
        // Act: Remove the session from storage
        try await sessionManagerStaticMemoryStorage.remove(session: session)
        
        // Assert: Ensure that the session has been removed from storage
        await #expect(
            try sessionManagerStaticMemoryStorage.session(for: .test) == nil,
            "The session should be removed from storage."
        )
    }
}
