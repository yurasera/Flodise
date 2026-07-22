//
//  FocusViewModel.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 19/07/26.
//

import SwiftUI
import CoreHaptics
import AudioToolbox
import Observation
import OSLog

@Observable
final class FocusViewModel {
    var now = Date()
    var hapticEngine: CHHapticEngine?
    
    private static let logger = Logger(subsystem: "com.yuhayalissera.Flocus", category: "FocusView")
    
    init() {
        prepareHaptics()
    }
    
    // MARK: - Time Formatting
    
    func focusDurationText(for task: Task) -> String {
        let startDate = task.focusStartedAt ?? task.createdAt
        let duration = max(0, Int(now.timeIntervalSince(startDate)))
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        let seconds = duration % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }

        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Color Management
    
    func backgroundColor(for categoryName: String?) -> Color {
        switch categoryName {
        case CategoryKind.current.title:
            return Color.brandPrimary
        case CategoryKind.alternative.title:
            return Color.brandSecondary
        case CategoryKind.dream.title:
            return Color.brandTertiary
        default:
            return .secondary
        }
    }
    
    func textColor(for categoryName: String?) -> Color {
        switch categoryName {
        case CategoryKind.current.title:
            return Color.brandTertiary
        case CategoryKind.alternative.title:
            return Color.brandTertiary
        case CategoryKind.dream.title:
            return Color.brandPrimary
        default:
            return .secondary
        }
    }
    
    // MARK: - Haptics
    
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            return
        }

        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            Self.logger.error("Failed to start haptic engine: \(error.localizedDescription)")
        }
    }
    
    func playStartHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = hapticEngine else {
            return
        }

        do {
            let event = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: 0,
                duration: 0.8
            )

            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            Self.logger.error("Failed to play start haptic: \(error.localizedDescription)")
        }
    }

    func playFinishHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = hapticEngine else {
            return
        }

        do {
            let events = [
                CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                    ],
                    relativeTime: 0,
                    duration: 1.0
                ),
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [],
                    relativeTime: 1.1
                )
            ]

            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            Self.logger.error("Failed to play finish haptic: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Audio
    
    func playStartSound() {
        AudioServicesPlaySystemSound(1113)
    }

    func playFinishSound() {
        AudioServicesPlaySystemSound(1005)
    }
    
    // MARK: - Notifications
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                Self.logger.error("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
}
