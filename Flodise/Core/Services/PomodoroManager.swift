//
//  PomodoroManager.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 05/07/26.
//

import SwiftUI
import SwiftData
import UserNotifications
import AVFoundation
import ActivityKit

@Observable
final class PomodoroManager {
    // MARK: - Published Properties
    var isRunning = false
    var remainingTime: TimeInterval = 0
    var currentTask: Task?
    
    // MARK: - Private Properties
    private var timer: Timer?
    private let defaults = UserDefaults.standard
    private var audioPlayer: AVAudioPlayer?
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var liveActivity: Activity<PomodoroAttributes>?
    
    // MARK: - Keys for UserDefaults
    private let startDateKey = "pomodoroStartDate"
    private let endDateKey = "pomodoroEndDate"
    private let durationKey = "pomodoroDuration"
    private let taskIdKey = "pomodoroTaskId"
    private let isRunningKey = "pomodoroIsRunning"
    
    // MARK: - Constants
    let defaultDuration: TimeInterval = 25 * 60 // 25 minutes
    
    // MARK: - Initialization
    init() {
        setupAudioSession()
        restoreStateIfNeeded()
    }
    
    // MARK: - Audio Session Setup
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session setup error: \(error.localizedDescription)")
        }
    }
    
    private func startBackgroundAudio() {
        guard let url = Bundle.main.url(forResource: "silence", withExtension: "mp3") else {
            // Create silent audio if file doesn't exist
            createAndPlaySilentAudio()
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.volume = 0
            audioPlayer?.play()
        } catch {
            print("Audio playback error: \(error.localizedDescription)")
            createAndPlaySilentAudio()
        }
    }
    
    private func createAndPlaySilentAudio() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.duckOthers, .mixWithOthers])
            try audioSession.setActive(true)
            
            // Create silent audio buffer using AVAudioEngine
            audioEngine = AVAudioEngine()
            playerNode = AVAudioPlayerNode()
            
            guard let audioEngine = audioEngine, let playerNode = playerNode else { return }
            
            // Create audio format (1 second of silence)
            let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)
            let buffer = AVAudioPCMBuffer(pcmFormat: format!, frameCapacity: 44100)
            buffer?.frameLength = 44100
            
            // Fill buffer with silence (zeros)
            if let channelData = buffer?.floatChannelData {
                for channel in 0..<Int(format!.channelCount) {
                    memset(channelData[channel], 0, Int(buffer!.frameCapacity) * MemoryLayout<Float>.size)
                }
            }
            
            audioEngine.attach(playerNode)
            audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: format)
            
            try audioEngine.start()
            playerNode.scheduleBuffer(buffer!, at: nil, options: .loops, completionHandler: nil)
            playerNode.play()
            
        } catch {
            print("Silent audio setup error: \(error.localizedDescription)")
        }
    }
    
    private func stopBackgroundAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        
        playerNode?.stop()
        audioEngine?.stop()
        playerNode = nil
        audioEngine = nil
    }
    
    // MARK: - Public Methods
    
    /// Start Pomodoro timer untuk task tertentu
    func startPomodoro(for task: Task, duration: TimeInterval? = nil) {
        stopPomodoro() // Stop timer yang sedang berjalan jika ada
        
        let duration = duration ?? defaultDuration
        let now = Date()
        let endDate = now.addingTimeInterval(duration)
        
        // Save to UserDefaults
        defaults.set(now, forKey: startDateKey)
        defaults.set(endDate, forKey: endDateKey)
        defaults.set(duration, forKey: durationKey)
        defaults.set(task.persistentModelID.hashValue, forKey: taskIdKey)
        defaults.set(true, forKey: isRunningKey)
        
        // Update state
        currentTask = task
        isRunning = true
        remainingTime = duration
        
        // Update task status
        task.status = .focus
        task.focusStartedAt = now
        try? task.modelContext?.save()
        
        // Schedule local notification
        scheduleCompletionNotification(duration: duration)
        startLiveActivity(task: task, startDate: now, endDate: endDate, duration: duration)
        
        // Start background audio to keep app alive
        startBackgroundAudio()
        
        // Start UI update timer (only for foreground)
        startUIUpdateTimer()
    }
    
    /// Stop Pomodoro timer
    func stopPomodoro() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        
        // Stop background audio
        stopBackgroundAudio()
        endLiveActivity(state: .paused)
        
        // Clear UserDefaults
        defaults.removeObject(forKey: startDateKey)
        defaults.removeObject(forKey: endDateKey)
        defaults.removeObject(forKey: durationKey)
        defaults.removeObject(forKey: taskIdKey)
        defaults.removeObject(forKey: isRunningKey)
        
        // Cancel pending notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    /// Complete Pomodoro session
    func completePomodoro() {
        let finishedTask = currentTask
        endLiveActivity(state: .finished)
        stopPomodoro()
        
        if let task = finishedTask {
            task.status = .completed
            task.completedAt = .now
            try? task.modelContext?.save()
        }
        
        currentTask = nil
        remainingTime = 0
    }
    
    /// Handle app entering background - save current state
    func saveStateWhenEnteringBackground() {
        guard isRunning else { return }
        // State sudah disimpan di startPomodoro, tidak perlu save lagi
    }
    
    /// Handle app becoming active - restore dan update timer
    func restoreStateIfNeeded() {
        guard let endDateData = defaults.object(forKey: endDateKey) as? Date else {
            return
        }
        
        let endDate = endDateData
        let now = Date()
        
        // Cek apakah sesi sudah selesai
        if now >= endDate {
            // Sesi sudah selesai
            completePomodoro()
            
            // Trigger haptic
            triggerCompletionHaptic()
            
            // Show notification jika aplikasi masih di background saat itu
            showCompletionNotification()
            
            return
        }
        
        // Restore state
        if let startDateData = defaults.object(forKey: startDateKey) as? Date,
           let duration = defaults.object(forKey: durationKey) as? TimeInterval,
           let isRunningData = defaults.bool(forKey: isRunningKey) as? Bool,
           isRunningData {
            
            isRunning = true
            remainingTime = endDate.timeIntervalSince(now)
            updateLiveActivity(state: .running)
            
            // Restart background audio
            startBackgroundAudio()
            
            // Start UI update timer
            startUIUpdateTimer()
        }
    }
    
    /// Update remaining time saat aplikasi active
    func updateRemainingTime() {
        guard isRunning,
              let endDateData = defaults.object(forKey: endDateKey) as? Date else {
            return
        }
        
        let remaining = endDateData.timeIntervalSince(Date())
        
        if remaining <= 0 {
            completePomodoro()
            triggerCompletionHaptic()
        } else {
            remainingTime = remaining
            updateLiveActivity(state: .running)
        }
    }
    
    // MARK: - Private Methods

    private func startLiveActivity(task: Task, startDate: Date, endDate: Date, duration: TimeInterval) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = PomodoroAttributes(
            taskId: String(task.persistentModelID.hashValue),
            taskTitle: task.title,
            taskCategory: task.category?.name
        )
        let state = PomodoroAttributes.ContentState(
            sessionName: sessionName(for: duration),
            remainingTime: max(0, endDate.timeIntervalSince(.now)),
            totalDuration: duration,
            startDate: startDate,
            endDate: endDate,
            progress: progress(startDate: startDate, endDate: endDate),
            state: .running
        )

        do {
            liveActivity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: endDate),
                pushType: nil
            )
        } catch {
            print("Live Activity start error: \(error.localizedDescription)")
        }
    }

    private func updateLiveActivity(state: PomodoroSessionState) {
        guard let liveActivity,
              let startDate = defaults.object(forKey: startDateKey) as? Date,
              let endDate = defaults.object(forKey: endDateKey) as? Date,
              let duration = defaults.object(forKey: durationKey) as? TimeInterval else { return }

        let contentState = PomodoroAttributes.ContentState(
            sessionName: sessionName(for: duration),
            remainingTime: max(0, endDate.timeIntervalSince(.now)),
            totalDuration: duration,
            startDate: startDate,
            endDate: endDate,
            progress: progress(startDate: startDate, endDate: endDate),
            state: state
        )

        _Concurrency.Task { @MainActor in
            await liveActivity.update(ActivityContent(state: contentState, staleDate: endDate))
        }
    }

    private func endLiveActivity(state: PomodoroSessionState) {
        guard let liveActivity else { return }

        let now = Date()
        let duration = defaults.object(forKey: durationKey) as? TimeInterval ?? defaultDuration
        let contentState = PomodoroAttributes.ContentState(
            sessionName: sessionName(for: duration),
            remainingTime: 0,
            totalDuration: duration,
            startDate: now,
            endDate: now,
            progress: 1,
            state: state
        )

        _Concurrency.Task { @MainActor in
            await liveActivity.end(ActivityContent(state: contentState, staleDate: nil), dismissalPolicy: .default)
        }

        self.liveActivity = nil
    }

    private func sessionName(for duration: TimeInterval) -> String {
        switch Int(duration / 60) {
        case 5:
            return "Short Break"
        case 15:
            return "Long Break"
        default:
            return "Focus"
        }
    }

    private func progress(startDate: Date, endDate: Date) -> Double {
        let duration = endDate.timeIntervalSince(startDate)
        guard duration > 0 else { return 1 }
        let elapsed = Date().timeIntervalSince(startDate)
        return min(max(elapsed / duration, 0), 1)
    }
    
    private func startUIUpdateTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateRemainingTime()
        }
    }
    
    private func scheduleCompletionNotification(duration: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Pomodoro Selesai"
        content.body = "Sesi fokus Anda telah selesai. Bagus!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: duration, repeats: false)
        let request = UNNotificationRequest(identifier: "pomodoroCompletion", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    private func showCompletionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Pomodoro Selesai"
        content.body = "Sesi fokus Anda telah selesai!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "pomodoroCompleted", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func triggerCompletionHaptic() {
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
    }
    
    deinit {
        timer?.invalidate()
    }
}
