import SwiftUI
import Combine
import UserNotifications
#if os(iOS)
import UIKit
#endif

@MainActor
final class PomodoroViewModel: ObservableObject {
    @Published var phase: TimerPhase = .idle
    @Published var settings = TimerSettings()
    @Published var completedSessions = 0
    @Published var todaySessions = 0
    @Published var animation = TimerAnimation()

    private var timer: Timer?
    private var totalDuration: TimeInterval = 0
    private let sound = SoundEngine.shared

    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return 1 - (phase.remaining / totalDuration)
    }

    var progressLabel: String {
        let r = Int(phase.remaining)
        return String(format: "%02d:%02d", r / 60, r % 60)
    }

    var totalLabel: String {
        let t = Int(totalDuration)
        return String(format: "%02d:%02d", t / 60, t % 60)
    }

    init() {
        sound.start()
        requestNotificationPermission()
    }

    // MARK: - Actions

    func startFocus() {
        totalDuration = TimeInterval(settings.focusMinutes * 60)
        phase = .focusing(totalDuration)
        startTimer()
    }

    func togglePause() {
        switch phase {
        case .focusing(let r), .shortBreak(let r), .longBreak(let r):
            phase = .paused(r)
            stopTimer()
        case .paused(let r):
            // 恢复前判断原来的 phase 类型
            if case .paused = phase {
                phase = .focusing(r)  // 简化：暂停后恢复默认回 focus
                totalDuration = TimeInterval(settings.focusMinutes * 60)
            }
            startTimer()
        default:
            break
        }
    }

    func reset() {
        stopTimer()
        phase = .idle
        totalDuration = 0
        animation = TimerAnimation()
    }

    func skipBreak() {
        stopTimer()
        startFocus()
    }

    // MARK: - Timer Loop

    private func startTimer() {
        stopTimer()
        sound.playTick(volume: settings.volume)

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        let remaining = phase.remaining - 1

        // 最后 3 秒播放倒计时音效
        if remaining <= 3 && remaining > 0 {
            sound.playTick(volume: settings.volume)
            if settings.hapticEnabled {
                #if os(iOS)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                #endif
            }
        }

        if remaining <= 0 {
            handlePhaseComplete()
            return
        }

        // Update phase with new remaining time
        switch phase {
        case .focusing:        phase = .focusing(remaining)
        case .shortBreak:      phase = .shortBreak(remaining)
        case .longBreak:       phase = .longBreak(remaining)
        default:               break
        }

        withAnimation(.easeInOut(duration: 0.5)) {
            animation.progress = progress
            animation.rotation += 0.5
        }
    }

    private func handlePhaseComplete() {
        stopTimer()

        switch phase {
        case .focusing:
            completedSessions += 1
            todaySessions += 1
            sendNotification(title: "🍅 专注完成！", body: "站起来伸个懒腰，休息一下吧～")
            sound.playSessionEnd(theme: settings.soundTheme, volume: settings.volume)
            if settings.hapticEnabled {
                #if os(iOS)
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                #endif
            }

            // 判断该长休息还是短休息
            if completedSessions % settings.sessionsUntilLongBreak == 0 {
                totalDuration = TimeInterval(settings.longBreakMinutes * 60)
                phase = .longBreak(totalDuration)
            } else {
                totalDuration = TimeInterval(settings.shortBreakMinutes * 60)
                phase = .shortBreak(totalDuration)
            }
            startTimer()

        case .shortBreak, .longBreak:
            sendNotification(title: "⏰ 休息结束", body: "继续加油，开始下一个番茄吧！")
            sound.playBreakEnd(theme: settings.soundTheme, volume: settings.volume)
            if settings.hapticEnabled {
                #if os(iOS)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                #endif
            }
            totalDuration = TimeInterval(settings.focusMinutes * 60)
            phase = .focusing(totalDuration)
            startTimer()

        default: break
        }

        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            animation.pulseScale = 1.15
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                self.animation.pulseScale = 1
            }
        }
    }

    // MARK: - Notifications

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        UNUserNotificationCenter.current().add(request)
    }

    deinit {
        timer?.invalidate()
    }
}
