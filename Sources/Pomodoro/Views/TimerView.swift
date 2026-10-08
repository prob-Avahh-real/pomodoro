import SwiftUI

// MARK: - Color Palette

extension Color {
    static let pomoRed    = Color(red: 0.91, green: 0.30, blue: 0.24)
    static let pomoGreen  = Color(red: 0.27, green: 0.75, blue: 0.44)
    static let pomoBlue   = Color(red: 0.20, green: 0.56, blue: 0.86)
    static let pomoGold   = Color(red: 0.95, green: 0.77, blue: 0.28)
    static let pomoBg     = Color(red: 0.96, green: 0.95, blue: 0.94)
}

// MARK: - Timer View

struct TimerView: View {
    @StateObject private var vm = PomodoroViewModel()
    @State private var showSettings = false

    var body: some View {
        ZStack {
            Color.pomoBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // 顶部统计
                statsBar
                    .padding(.top, 60)
                    .padding(.horizontal, 32)

                Spacer()

                // 核心计时圆环
                timerRing
                    .padding(.horizontal, 40)

                Spacer()

                // 控制按钮
                controlButtons
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(settings: $vm.settings)
        }
        .onAppear { SoundEngine.shared.start() }
    }

    // MARK: - Stats Bar

    private var statsBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(vm.phase.label)
                    .font(.title2).fontWeight(.bold)
                    .contentTransition(.numericText())
                Text("今日完成 \(vm.todaySessions) 个番茄")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(width: 40, height: 40)
                    .background(.white.opacity(0.8))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            }
        }
    }

    // MARK: - Timer Ring

    private var timerRing: some View {
        ZStack {
            // 背景环
            Circle()
                .stroke(Color.gray.opacity(0.12), lineWidth: 18)
                .frame(width: 280, height: 280)

            // 进度弧
            Circle()
                .trim(from: 0, to: vm.progress)
                .stroke(
                    AngularGradient(
                        colors: ringColors,
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
                .frame(width: 280, height: 280)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.8), value: vm.progress)

            // 脉冲缩放
            VStack(spacing: 4) {
                Image(systemName: vm.phase.icon)
                    .font(.system(size: 36))
                    .foregroundStyle(phaseColor)
                    .symbolEffect(.bounce, value: vm.phase.remaining)

                Text(vm.progressLabel)
                    .font(.system(size: 56, weight: .bold, design: .monospaced))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())

                Text(vm.totalLabel)
                    .font(.caption).foregroundStyle(.secondary)
            }
            .scaleEffect(vm.animation.pulseScale)
        }
        .frame(width: 280, height: 280)
    }

    // MARK: - Control Buttons

    private var controlButtons: some View {
        HStack(spacing: 20) {
            switch vm.phase {
            case .idle:
                Button(action: vm.startFocus) {
                    Label("开始专注", systemImage: "play.fill")
                        .font(.headline).foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(pomodoroGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }

            case .paused:
                Button(action: vm.reset) {
                    Label("结束", systemImage: "stop.fill")
                        .font(.headline).foregroundStyle(Color.pomoRed)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
                }
                Button(action: vm.togglePause) {
                    Label("继续", systemImage: "play.fill")
                        .font(.headline).foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(pomodoroGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }

            case .focusing, .shortBreak, .longBreak:
                Button(action: vm.togglePause) {
                    Label("暂停", systemImage: "pause.fill")
                        .font(.headline).foregroundStyle(Color.pomoRed)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
                }
                if !vm.phase.isWorking {
                    Button(action: vm.skipBreak) {
                        Label("跳过休息", systemImage: "forward.fill")
                            .font(.headline).foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(pomodoroGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                }
            }
        }
    }

    // MARK: - Computed

    private var phaseColor: Color {
        switch vm.phase {
        case .idle, .paused:    .secondary
        case .focusing:         Color.pomoRed
        case .shortBreak:       .pomoGreen
        case .longBreak:        .pomoBlue
        }
    }

    private var ringColors: [Color] {
        switch vm.phase {
        case .focusing:   [Color.pomoRed, Color.pomoRed.opacity(0.7), Color.orange]
        case .shortBreak: [.pomoGreen, .pomoGreen.opacity(0.7), .mint]
        case .longBreak:  [.pomoBlue, .pomoBlue.opacity(0.7), .pomoGold]
        default:          [.gray.opacity(0.3)]
        }
    }

    private var pomodoroGradient: LinearGradient {
        LinearGradient(
            colors: [Color.pomoRed, Color.orange],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @Binding var settings: TimerSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("番茄时长") {
                    Stepper("专注 \(settings.focusMinutes) 分钟",
                            value: $settings.focusMinutes, in: 5...60, step: 5)
                    Stepper("短休息 \(settings.shortBreakMinutes) 分钟",
                            value: $settings.shortBreakMinutes, in: 1...15, step: 1)
                    Stepper("长休息 \(settings.longBreakMinutes) 分钟",
                            value: $settings.longBreakMinutes, in: 5...45, step: 5)
                    Stepper("\(settings.sessionsUntilLongBreak) 轮后长休息",
                            value: $settings.sessionsUntilLongBreak, in: 2...8, step: 1)
                }

                Section("音效主题") {
                    Picker("提醒音效", selection: $settings.soundTheme) {
                        ForEach(SoundTheme.allCases, id: \.self) { theme in
                            HStack {
                                Text(themeIcon(theme))
                                Text(theme.rawValue)
                            }.tag(theme)
                        }
                    }
                    .pickerStyle(.inline)

                    HStack {
                        Text("音量")
                        Slider(value: $settings.volume, in: 0.1...1.0)
                        Button("试听") {
                            SoundEngine.shared.playSessionEnd(theme: settings.soundTheme, volume: settings.volume)
                        }
                        .font(.caption)
                    }
                }

                Section {
                    Toggle("触觉反馈", isOn: $settings.hapticEnabled)
                }
            }
            .navigationTitle("设置")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }

    private func themeIcon(_ theme: SoundTheme) -> String {
        switch theme {
        case .anime:  "⚡"
        case .funny:  "🤪"
        case .cat:    "🐱"
        case .retro:  "🕹️"
        case .gentle: "🌸"
        }
    }
}
