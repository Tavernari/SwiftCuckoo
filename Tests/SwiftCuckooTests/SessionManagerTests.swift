import Foundation
import Testing
import SwiftCuckoo

private extension Session.Identifier {
    static let test = Session.Identifier(rawValue: "test")
    static let test2 = Session.Identifier(rawValue: "test2")
}

final class SessionManagerTests {


    @Test("Test start tracking when session already exists")
    func testStartTracking_when_session_exists() {
        let startTime = Date()
        let session1 = Session(id: .test, startTime: startTime)
        let session2 = Session(id: .test2, startTime: startTime)

        SessionManager.sessions[Session.Identifier.test.rawValue] = session1
        SessionManager.sessions[Session.Identifier.test2.rawValue] = session2

        let testSessionStartTime = SessionManager.startTracking(sessionId: .test)

        #expect(testSessionStartTime == session1.startTime)
        #expect(testSessionStartTime != session2.startTime)
    }

    @Test("Test start tracking when session doesn't exists")
    func testStartTracking_when_session_doesnt_exist() {
        let newSessionDate = SessionManager.startTracking(sessionId: Session.Identifier(rawValue: "New Session"))

        #expect(SessionManager.sessions["New Session"]?.startTime == newSessionDate)
    }
}
