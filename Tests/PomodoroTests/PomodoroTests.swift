import XCTest
@testable import Pomodoro

final class PomodoroTests: XCTestCase {

    func testTimerPhaseEquality() {
        XCTAssertEqual(TimerPhase.idle, TimerPhase.idle)
        XCTAssertEqual(TimerPhase.focusing(100), TimerPhase.focusing(100))
        XCTAssertNotEqual(TimerPhase.focusing(100), TimerPhase.focusing(200))
        XCTAssertNotEqual(TimerPhase.focusing(100), TimerPhase.shortBreak(100))
    }

    func testTimerPhaseLabel() {
        XCTAssertEqual(TimerPhase.idle.label, "准备开始")
        XCTAssertEqual(TimerPhase.focusing(60).label, "🍅 专注中")
        XCTAssertEqual(TimerPhase.paused(30).label, "⏸ 已暂停")
    }

    func testTimerPhaseIsWorking() {
        XCTAssertTrue(TimerPhase.focusing(60).isWorking)
        XCTAssertFalse(TimerPhase.idle.isWorking)
        XCTAssertFalse(TimerPhase.shortBreak(60).isWorking)
        XCTAssertFalse(TimerPhase.longBreak(60).isWorking)
    }

    func testTimerPhaseRemaining() {
        XCTAssertEqual(TimerPhase.idle.remaining, 0)
        XCTAssertEqual(TimerPhase.focusing(1500).remaining, 1500)
        XCTAssertEqual(TimerPhase.paused(300).remaining, 300)
    }

    func testTimerSettingsDefault() {
        let settings = TimerSettings()
        XCTAssertEqual(settings.focusMinutes, 25)
        XCTAssertEqual(settings.shortBreakMinutes, 5)
        XCTAssertEqual(settings.longBreakMinutes, 15)
        XCTAssertEqual(settings.sessionsUntilLongBreak, 4)
        XCTAssertEqual(settings.soundTheme, .anime)
        XCTAssertTrue(settings.hapticEnabled)
    }

    func testTimerSettingsCodable() throws {
        let settings = TimerSettings(focusMinutes: 45, shortBreakMinutes: 10, soundTheme: .cat)
        let data = try JSONEncoder().encode(settings)
        let decoded = try JSONDecoder().decode(TimerSettings.self, from: data)
        XCTAssertEqual(decoded.focusMinutes, 45)
        XCTAssertEqual(decoded.shortBreakMinutes, 10)
        XCTAssertEqual(decoded.soundTheme, .cat)
    }

    func testSoundThemeAllCases() {
        let all = SoundTheme.allCases
        XCTAssertEqual(all.count, 5)
        XCTAssertTrue(all.contains(.anime))
        XCTAssertTrue(all.contains(.cat))
        XCTAssertTrue(all.contains(.gentle))
    }

    func testSessionRecord() {
        let record = SessionRecord(date: Date(), focusMinutes: 25, completedFocus: 3, interruptions: 1)
        XCTAssertEqual(record.focusMinutes, 25)
        XCTAssertEqual(record.completedFocus, 3)
        XCTAssertEqual(record.interruptions, 1)
    }

    func testTimerAnimationDefault() {
        let anim = TimerAnimation()
        XCTAssertEqual(anim.progress, 0)
        XCTAssertEqual(anim.pulseScale, 1)
        XCTAssertEqual(anim.rotation, 0)
    }
}
