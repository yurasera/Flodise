import Observation

enum DiscoveryCategory: String, CaseIterable, Hashable, Identifiable {
    case interests
    case values
    case strengths
    case motivation
    case workStyle

    var id: String { rawValue }

    var title: String {
        switch self {
        case .interests: "Interests"
        case .values: "Values"
        case .strengths: "Strengths"
        case .motivation: "Motivation"
        case .workStyle: "Work Style"
        }
    }

    var icon: String {
        switch self {
        case .interests: "sparkles"
        case .values: "heart.text.square"
        case .strengths: "figure.arms.open"
        case .motivation: "bolt.fill"
        case .workStyle: "slider.horizontal.3"
        }
    }

    var question: String {
        switch self {
        case .interests: "What naturally draws your attention?"
        case .values: "What matters most to you?"
        case .strengths: "What do you naturally do well?"
        case .motivation: "What gives you energy?"
        case .workStyle: "How do you prefer to work?"
        }
    }

    var detail: String {
        switch self {
        case .interests: "Explore the activities, topics, and experiences that make you curious."
        case .values: "Identify the principles you want your life and work to reflect."
        case .strengths: "Reflect on the abilities and qualities you can rely on."
        case .motivation: "Discover the conditions and activities that make work feel meaningful."
        case .workStyle: "Explore the environments and ways of working that fit you best."
        }
    }

    var options: [String] {
        switch self {
        case .interests: ["Making things", "Learning", "Helping people", "Exploring ideas", "Being outdoors", "Creating beauty"]
        case .values: ["Freedom", "Stability", "Growth", "Impact", "Creativity", "Connection", "Mastery"]
        case .strengths: ["Seeing patterns", "Communicating", "Solving problems", "Organizing", "Empathy", "Making decisions"]
        case .motivation: ["Progress", "Meaningful impact", "Curiosity", "Recognition", "Autonomy", "Connection"]
        case .workStyle: ["Independent", "Collaborative", "Structured", "Flexible", "Deep focus", "Variety", "Remote", "In-person"]
        }
    }
}

@Observable
final class DiscoveryStore {
    private(set) var responses: [DiscoveryCategory: Set<String>] = [:]

    var completedCount: Int {
        DiscoveryCategory.allCases.filter { isComplete($0) }.count
    }

    func isComplete(_ category: DiscoveryCategory) -> Bool {
        !(responses[category] ?? []).isEmpty
    }

    func isSelected(_ option: String, for category: DiscoveryCategory) -> Bool {
        responses[category]?.contains(option) == true
    }

    func toggle(_ option: String, for category: DiscoveryCategory) {
        var selected = responses[category] ?? []
        if selected.contains(option) {
            selected.remove(option)
        } else {
            selected.insert(option)
        }
        responses[category] = selected
    }

    func selectedOptions(for category: DiscoveryCategory) -> [String] {
        responses[category, default: []].sorted()
    }
}
