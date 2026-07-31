//
//  FlodiseApp.swift
//  Flodise
//
//  Created by Yuhaya Lissera on 22/07/26.
//

import SwiftUI
import SwiftData

@main
struct FlodiseApp: App {
    private let container: ModelContainer
    
    @State private var pomodoroManager = PomodoroManager()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        do {
            container = try DatabaseManager.makeContainer()
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(pomodoroManager)
        }
        .modelContainer(container)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            handleScenePhaseChange(newPhase: newPhase)
        }
    }
    
    // MARK: - Scene Phase Management
    
    private func handleScenePhaseChange(newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            pomodoroManager.restoreStateIfNeeded()
        case .background:
            pomodoroManager.saveStateWhenEnteringBackground()
        case .inactive:
            break
        @unknown default:
            break
        }
    }
}
