import AVFoundation
import Foundation

/// 合成音效引擎 — 全部用 AVAudioEngine 生成，零外部音频文件
final class SoundEngine {
    static let shared = SoundEngine()
    private let engine = AVAudioEngine()
    private var isRunning = false

    private init() {}

    func start() {
        guard !isRunning else { return }
        do {
            #if os(iOS)
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            #endif
            engine.prepare()
            try engine.start()
            isRunning = true
        } catch {
            print("[SoundEngine] Failed: \(error)")
        }
    }

    // MARK: - Theme-based playback

    func playSessionEnd(theme: SoundTheme, volume: Float) {
        switch theme {
        case .anime:   playAnimeFanfare(volume: volume)
        case .funny:   playFunnyAlert(volume: volume)
        case .cat:     playCatMeow(volume: volume)
        case .retro:   playRetroJingle(volume: volume)
        case .gentle:  playGentleChime(volume: volume)
        }
    }

    func playBreakEnd(theme: SoundTheme, volume: Float) {
        switch theme {
        case .anime:   playAnimeResume(volume: volume)
        case .funny:   playFunnyResume(volume: volume)
        case .cat:     playCatPurr(volume: volume)
        case .retro:   playRetroStart(volume: volume)
        case .gentle:  playGentleChime(volume: volume)
        }
    }

    func playTick(volume: Float) {
        playTone(frequency: 800, duration: 0.015, volume: volume * 0.3)
    }

    // MARK: - Anime Theme: 热血番剧风格

    private func playAnimeFanfare(volume: Float) {
        // 上升音阶 → 类似主角觉醒 BGM
        let notes: [Float] = [523, 659, 784, 1047] // C5 E5 G5 C6
        for (i, note) in notes.enumerated() {
            let delay = Double(i) * 0.12
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.playTone(frequency: note, duration: 0.25, volume: volume, wave: .square)
            }
        }
        // 结尾喊声效果 → 快速琶音
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            for i in 0..<8 {
                let d = Double(i) * 0.04
                DispatchQueue.main.asyncAfter(deadline: .now() + d) {
                    self.playTone(frequency: 880 + Float(i) * 55, duration: 0.06, volume: volume * 0.7, wave: .square)
                }
            }
        }
    }

    private func playAnimeResume(volume: Float) {
        // 轻快的三音 → "下一集！"
        playTone(frequency: 587, duration: 0.12, volume: volume, wave: .sine)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.playTone(frequency: 784, duration: 0.12, volume: volume, wave: .sine)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.playTone(frequency: 988, duration: 0.2, volume: volume, wave: .sine)
        }
    }

    // MARK: - Funny Theme: 搞笑音效

    private func playFunnyAlert(volume: Float) {
        // 滑音下降 → 类似卡通人物摔倒
        for i in 0..<15 {
            let delay = Double(i) * 0.03
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.playTone(frequency: 1200 - Float(i) * 70, duration: 0.05, volume: volume, wave: .square)
            }
        }
        // "叮叮叮" 催促
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for i in 0..<3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                    self.playTone(frequency: 1600, duration: 0.08, volume: volume * 0.8, wave: .square)
                }
            }
        }
    }

    private func playFunnyResume(volume: Float) {
        // 弹簧音效 → "boing!"
        for i in 0..<8 {
            let delay = Double(i) * 0.02
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.playTone(frequency: 300 + Float(i) * 80, duration: 0.04, volume: volume, wave: .sine)
            }
        }
    }

    // MARK: - Cat Theme: 猫猫

    private func playCatMeow(volume: Float) {
        // 模拟猫叫频率变化
        let meowFreqs: [Float] = [600, 750, 800, 750, 600, 500]
        for (i, freq) in meowFreqs.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.07) {
                self.playTone(frequency: freq, duration: 0.08, volume: volume * 0.6, wave: .sine)
            }
        }
        // 呼噜声 → 低频振动
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for i in 0..<20 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.04) {
                    self.playTone(frequency: 80 + Float(i % 4) * 15, duration: 0.05, volume: volume * 0.3, wave: .sine)
                }
            }
        }
    }

    private func playCatPurr(volume: Float) {
        for i in 0..<10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05) {
                self.playTone(frequency: 120 + Float(i % 3) * 20, duration: 0.06, volume: volume * 0.25, wave: .sine)
            }
        }
    }

    // MARK: - Retro Theme: 8-bit 游戏风

    private func playRetroJingle(volume: Float) {
        // 超级马里奥式音阶
        let notes: [(Float, Float)] = [
            (659, 0.1), (659, 0.1), (0, 0.1), (659, 0.1),
            (0, 0.1), (523, 0.1), (659, 0.1), (784, 0.2),
            (0, 0.15), (392, 0.2),
        ]
        var t: Double = 0
        for (freq, dur) in notes {
            let delay = t
            if freq > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.playTone(frequency: freq, duration: Float(dur), volume: volume, wave: .square)
                }
            }
            t += Double(dur)
        }
    }

    private func playRetroStart(volume: Float) {
        playTone(frequency: 440, duration: 0.1, volume: volume, wave: .square)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            self.playTone(frequency: 554, duration: 0.1, volume: volume, wave: .square)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            self.playTone(frequency: 659, duration: 0.15, volume: volume, wave: .square)
        }
    }

    // MARK: - Gentle Theme: 温柔提醒

    private func playGentleChime(volume: Float) {
        let notes: [Float] = [523, 659, 784, 1047]
        for (i, note) in notes.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.4) {
                self.playTone(frequency: note, duration: 0.5, volume: volume * 0.5,
                              wave: .sine, decay: 3)
            }
        }
    }

    // MARK: - Core Synthesizer

    private func playTone(
        frequency: Float,
        duration: Float,
        volume: Float,
        wave: WaveType = .sine,
        decay: Float = 12
    ) {
        let sampleRate = engine.outputNode.outputFormat(forBus: 0).sampleRate
        let frameCount = AVAudioFrameCount(duration * Float(sampleRate))

        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: engine.outputNode.outputFormat(forBus: 0),
            frameCapacity: frameCount
        ) else { return }

        buffer.frameLength = frameCount

        for i in 0..<Int(frameCount) {
            let t = Float(i) / Float(sampleRate)
            let env = exp(-t * decay)
            let phase = 2 * .pi * frequency * t
            let sample: Float = switch wave {
            case .sine:   sin(phase)
            case .square: sin(phase) >= 0 ? 1 : -1
            case .saw:    2 * (t * frequency - floor(t * frequency + 0.5))
            }
            buffer.floatChannelData?.pointee[i] = sample * env * volume
        }

        let player = AVAudioPlayerNode()
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: buffer.format)
        player.scheduleBuffer(buffer, at: nil, options: .interrupts) {
            DispatchQueue.main.async { self.engine.detach(player) }
        }
        player.play()
    }

    private enum WaveType { case sine, square, saw }
}
