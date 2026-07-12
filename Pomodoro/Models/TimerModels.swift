import Foundation

// MARK: - Timer Phase

enum TimerPhase: Equatable {
    case idle
    case focusing(TimeInterval)    // remaining seconds
    case shortBreak(TimeInterval)
    case longBreak(TimeInterval)
    case paused(TimeInterval)      // paused with remaining seconds

    var label: String {
        switch self {
        case .idle:                  "准备开始"
        case .focusing:              "🍅 专注中"
        case .shortBreak:            "☕️ 小休息"
        case .longBreak:             "🌴 大休息"
        case .paused:                "⏸ 已暂停"
        }
    }

    var icon: String {
        switch self {
        case .idle:                  "timer"
        case .focusing:              "brain.head.profile"
        case .shortBreak:            "cup.and.saucer.fill"
        case .longBreak:             "beach.umbrella.fill"
        case .paused:                "pause.circle.fill"
        }
    }

    var isWorking: Bool {
        if case .focusing = self { return true }
        return false
    }

    var remaining: TimeInterval {
        switch self {
        case .idle:                  0
        case .focusing(let r),
             .shortBreak(let r),
             .longBreak(let r),
             .paused(let r):         r
        }
    }
}

// MARK: - Sound Theme

enum SoundTheme: String, CaseIterable, Codable {
    case anime = "动漫风"
    case funny = "搞笑风"
    case cat    = "猫猫风"
    case retro  = "复古游戏风"
    case gentle = "温柔提醒"
}

// MARK: - Timer Settings

struct TimerSettings: Codable {
    var focusMinutes: Int = 25
    var shortBreakMinutes: Int = 5
    var longBreakMinutes: Int = 15
    var sessionsUntilLongBreak: Int = 4
    var soundTheme: SoundTheme = .anime
    var volume: Float = 0.7
    var hapticEnabled: Bool = true
}

// MARK: - Session Record

struct SessionRecord: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let focusMinutes: Int
    let completedFocus: Int       // actually completed focus sessions
    let interruptions: Int
}

// MARK: - Animation State

struct TimerAnimation {
    var progress: CGFloat = 0       // 0..1
    var pulseScale: CGFloat = 1
    var rotation: Double = 0
}
