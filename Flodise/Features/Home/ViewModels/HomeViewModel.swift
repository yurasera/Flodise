//
//  HomeViewModel.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 18/07/26.
//

import SwiftUI
import SwiftData
import Observation

@Observable
final class HomeViewModel {
    // MARK: - Properties
    var isPresentingPriorityTasks = false
    var isCurrentVisible = true
    var isAlternativeVisible = true
    var isDreamVisible = true
    var energy = 10 {
        didSet { saveEnergy() }
    }
    var level = 1 {
        didSet { saveProgress() }
    }
    var exp = 0 {
        didSet { saveProgress() }
    }
    var currentLevel = 1 {
        didSet { saveCategoryProgress() }
    }
    var currentExp = 0 {
        didSet { saveCategoryProgress() }
    }
    var alternativeLevel = 1 {
        didSet { saveCategoryProgress() }
    }
    var alternativeExp = 0 {
        didSet { saveCategoryProgress() }
    }
    var dreamLevel = 1 {
        didSet { saveCategoryProgress() }
    }
    var dreamExp = 0 {
        didSet { saveCategoryProgress() }
    }
    
    private var modelContext: ModelContext?
    private let defaults = UserDefaults.standard
    private let energyResetDateKey = "homeEnergyResetDate"
    private let energyKey = "homeEnergy"
    private let levelKey = "homeLevel"
    private let expKey = "homeExp"
    private let currentLevelKey = "homeCurrentLevel"
    private let currentExpKey = "homeCurrentExp"
    private let alternativeLevelKey = "homeAlternativeLevel"
    private let alternativeExpKey = "homeAlternativeExp"
    private let dreamLevelKey = "homeDreamLevel"
    private let dreamExpKey = "homeDreamExp"
    private var energyResetTimer: Timer?
    
    // MARK: - Initialization
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        loadProgress()
    }
    
    func setContext(_ context: ModelContext) {
        self.modelContext = context
        loadProgress()
        ensureDailyEnergyReset()
    }
    
    // MARK: - Task Filtering
    func currentTasks(from tasks: [Task]) -> [Task] {
        tasks.filter {
            $0.category?.name == CategoryKind.current.title &&
            $0.status != .archive &&
            $0.status != .idea &&
            $0.status != .planned
        }
    }

    func alternativeTasks(from tasks: [Task]) -> [Task] {
        tasks.filter {
            $0.category?.name == CategoryKind.alternative.title &&
            $0.status != .archive &&
            $0.status != .idea &&
            $0.status != .planned
        }
    }

    func dreamTasks(from tasks: [Task]) -> [Task] {
        tasks.filter {
            $0.category?.name == CategoryKind.dream.title &&
            $0.status != .archive &&
            $0.status != .idea &&
            $0.status != .planned
        }
    }
    
    func focusTask(from tasks: [Task]) -> Task? {
        tasks.first { $0.status == .focus }
    }
    
    // MARK: - Actions
    func startFocus(tasks: [Task]) {
        guard let priorityTask = tasks.first(where: { $0.status == .backlog }) else {
            return
        }

        for task in tasks {
            if task.status == .focus {
                task.status = .backlog
                task.focusStartedAt = nil
            }
        }

        priorityTask.status = .focus
        priorityTask.focusStartedAt = .now

        save()
    }

    func stopFocus(tasks: [Task]) {
        guard let focusTask = focusTask(from: tasks) else { return }
        focusTask.status = .backlog
        focusTask.focusStartedAt = nil
        save()
    }

    func consumeEnergy() {
        ensureDailyEnergyReset()
        energy = min(10, max(0, energy - 1))
    }

    func gainExp() {
        ensureDailyEnergyReset()
        exp += 10
        while exp >= 100 {
            exp -= 100
            level += 1
        }
    }

    func gainCategoryExp(for category: CategoryKind, amount: Int) {
        switch category {
        case .current:
            currentExp += amount
            while currentExp >= 100 {
                currentExp -= 100
                currentLevel += 1
            }
        case .alternative:
            alternativeExp += amount
            while alternativeExp >= 100 {
                alternativeExp -= 100
                alternativeLevel += 1
            }
        case .dream:
            dreamExp += amount
            while dreamExp >= 100 {
                dreamExp -= 100
                dreamLevel += 1
            }
        }
    }

    func ensureDailyEnergyReset() {
        let now = Date()
        let calendar = Calendar.current
        let lastReset = defaults.object(forKey: energyResetDateKey) as? Date

        if let lastReset, calendar.isDate(lastReset, inSameDayAs: now) {
            scheduleNextEnergyReset()
            return
        }

        energy = 10
        saveEnergy()
        defaults.set(now, forKey: energyResetDateKey)
        scheduleNextEnergyReset()
    }

    func saveEnergy() {
        defaults.set(energy, forKey: energyKey)
    }

    func saveProgress() {
        defaults.set(level, forKey: levelKey)
        defaults.set(exp, forKey: expKey)
    }

    func saveCategoryProgress() {
        defaults.set(currentLevel, forKey: currentLevelKey)
        defaults.set(currentExp, forKey: currentExpKey)
        defaults.set(alternativeLevel, forKey: alternativeLevelKey)
        defaults.set(alternativeExp, forKey: alternativeExpKey)
        defaults.set(dreamLevel, forKey: dreamLevelKey)
        defaults.set(dreamExp, forKey: dreamExpKey)
    }
    
    private func save() {
        do {
            try modelContext?.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }

    private func loadProgress() {
        let savedEnergy = defaults.object(forKey: energyKey) as? Int
        let savedLevel = defaults.object(forKey: levelKey) as? Int
        let savedExp = defaults.object(forKey: expKey) as? Int
        let savedCurrentLevel = defaults.object(forKey: currentLevelKey) as? Int
        let savedCurrentExp = defaults.object(forKey: currentExpKey) as? Int
        let savedAlternativeLevel = defaults.object(forKey: alternativeLevelKey) as? Int
        let savedAlternativeExp = defaults.object(forKey: alternativeExpKey) as? Int
        let savedDreamLevel = defaults.object(forKey: dreamLevelKey) as? Int
        let savedDreamExp = defaults.object(forKey: dreamExpKey) as? Int

        if let savedEnergy {
            energy = min(max(0, savedEnergy), 10)
        }

        if let savedLevel {
            level = max(1, savedLevel)
        }

        if let savedExp {
            exp = min(max(0, savedExp), 99)
        }

        if let savedCurrentLevel {
            currentLevel = max(1, savedCurrentLevel)
        }
        if let savedCurrentExp {
            currentExp = min(max(0, savedCurrentExp), 99)
        }
        if let savedAlternativeLevel {
            alternativeLevel = max(1, savedAlternativeLevel)
        }
        if let savedAlternativeExp {
            alternativeExp = min(max(0, savedAlternativeExp), 99)
        }
        if let savedDreamLevel {
            dreamLevel = max(1, savedDreamLevel)
        }
        if let savedDreamExp {
            dreamExp = min(max(0, savedDreamExp), 99)
        }
    }

    private func scheduleNextEnergyReset() {
        energyResetTimer?.invalidate()

        let calendar = Calendar.current
        let now = Date()
        guard let nextMidnight = calendar.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) else {
            return
        }

        let interval = nextMidnight.timeIntervalSince(now)
        energyResetTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            guard let self else { return }
            self.energy = 10
            self.defaults.set(Date(), forKey: self.energyResetDateKey)
            self.scheduleNextEnergyReset()
        }
    }
}
