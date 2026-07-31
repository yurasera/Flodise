import Foundation
import Observation

enum CareerCategory: String, CaseIterable, Identifiable {
    case technology = "Technology"
    case design = "Design"
    case business = "Business"
    case marketing = "Marketing"
    case finance = "Finance"
    case research = "Research"
    case education = "Education"
    case creative = "Creative"
    case operations = "Operations"
    case leadership = "Leadership"

    var id: String { rawValue }
}

enum CareerCuriosity: String, CaseIterable, Identifiable {
    case curious = "Just curious"
    case interested = "Interested"
    case veryInterested = "Very interested"

    var id: String { rawValue }
}

struct CareerPath: Identifiable, Hashable {
    let id: String
    let title: String
    let shortDescription: String
    let overview: String
    let categories: [CareerCategory]
    let attributes: [String]
    let activities: [String]
    let opportunities: [String]
    let challenges: [String]
    let exploredSkills: [String]
    let developingSkills: [String]
    let relatedCareerIDs: [String]
    let matchingTags: Set<String>
}

enum CareerPathData {
    static let all: [CareerPath] = [
        CareerPath(
            id: "product-manager",
            title: "Product Manager",
            shortDescription: "Connects people, ideas, and product decisions.",
            overview: "Product Managers help teams understand problems, define priorities, and decide what to build.",
            categories: [.business, .technology, .leadership],
            attributes: ["Strategy", "Problem solving", "Collaboration", "Variety"],
            activities: ["Understand user problems", "Define product direction", "Prioritize opportunities", "Work with designers and engineers", "Make decisions with incomplete information"],
            opportunities: ["Multiple industries", "Transferable skills", "Different work environments", "Potential growth areas"],
            challenges: ["Ambiguous decisions", "Continuous learning", "Stakeholder management", "High responsibility"],
            exploredSkills: ["Communication", "Problem solving"],
            developingSkills: ["Product strategy", "Data analysis", "User research"],
            relatedCareerIDs: ["business-analyst", "ux-researcher", "project-manager", "product-designer"],
            matchingTags: ["Exploring ideas", "Solving problems", "Communicating", "Collaborative", "Variety", "Growth", "Impact"]
        ),
        CareerPath(
            id: "product-designer",
            title: "Product Designer",
            shortDescription: "Shapes useful, clear, and thoughtful experiences.",
            overview: "Product Designers explore user needs and turn them into interfaces and experiences that help people accomplish something meaningful.",
            categories: [.design, .technology, .creative],
            attributes: ["Creativity", "Empathy", "Problem solving", "Making things"],
            activities: ["Understand people and their needs", "Sketch and prototype ideas", "Shape interaction details", "Collaborate with product teams", "Learn from feedback"],
            opportunities: ["Work across many products", "Visible creative output", "Transferable design practice", "Close connection to users"],
            challenges: ["Many possible solutions", "Frequent feedback", "Balancing user and business needs", "Continuous craft development"],
            exploredSkills: ["Empathy", "Making things"],
            developingSkills: ["Interaction design", "Prototyping", "Visual communication"],
            relatedCareerIDs: ["product-manager", "ux-researcher", "creative-director"],
            matchingTags: ["Creating beauty", "Making things", "Helping people", "Creativity", "Empathy", "Exploring ideas", "Flexible"]
        ),
        CareerPath(
            id: "ux-researcher",
            title: "UX Researcher",
            shortDescription: "Turns curiosity about people into useful insight.",
            overview: "UX Researchers study how people think, behave, and use products so teams can make more informed decisions.",
            categories: [.research, .technology, .design],
            attributes: ["Curiosity", "Empathy", "Pattern finding", "Communication"],
            activities: ["Plan interviews and studies", "Listen for patterns", "Observe people using products", "Synthesize what you learn", "Share findings with teams"],
            opportunities: ["Work in many product areas", "Build deep understanding of people", "Influence decisions", "Blend qualitative and analytical work"],
            challenges: ["Recruiting participants", "Interpreting incomplete signals", "Advocating for evidence", "Research trade-offs"],
            exploredSkills: ["Empathy", "Seeing patterns", "Communicating"],
            developingSkills: ["Research methods", "Data synthesis", "Facilitation"],
            relatedCareerIDs: ["product-designer", "product-manager", "business-analyst"],
            matchingTags: ["Learning", "Helping people", "Exploring ideas", "Seeing patterns", "Empathy", "Connection", "Deep focus"]
        ),
        CareerPath(
            id: "business-analyst",
            title: "Business Analyst",
            shortDescription: "Finds clarity in complex problems and decisions.",
            overview: "Business Analysts connect business needs, data, and practical solutions to help organizations make better decisions.",
            categories: [.business, .finance, .operations],
            attributes: ["Analysis", "Structure", "Communication", "Impact"],
            activities: ["Clarify business questions", "Analyze information", "Map processes", "Compare possible solutions", "Explain findings to stakeholders"],
            opportunities: ["Transferable analytical skills", "Many industries", "Exposure to different problems", "Clear paths to specialize"],
            challenges: ["Messy information", "Competing priorities", "Detailed investigation", "Influencing without authority"],
            exploredSkills: ["Solving problems", "Organizing", "Communication"],
            developingSkills: ["Data analysis", "Process mapping", "Business modeling"],
            relatedCareerIDs: ["product-manager", "project-manager", "strategy-consultant"],
            matchingTags: ["Solving problems", "Seeing patterns", "Organizing", "Structured", "Mastery", "Stability", "Impact"]
        ),
        CareerPath(
            id: "teacher",
            title: "Learning Facilitator",
            shortDescription: "Helps people understand, grow, and move forward.",
            overview: "Learning Facilitators design and guide experiences that help people build understanding, confidence, and capability.",
            categories: [.education, .leadership],
            attributes: ["Connection", "Growth", "Communication", "Meaning"],
            activities: ["Understand learners", "Plan learning experiences", "Explain complex ideas", "Give useful feedback", "Create a supportive environment"],
            opportunities: ["Direct human impact", "Many learning contexts", "Creative teaching formats", "Deep relationships"],
            challenges: ["Different learning needs", "Emotional energy", "Preparation time", "Measuring progress"],
            exploredSkills: ["Communicating", "Empathy", "Helping people"],
            developingSkills: ["Facilitation", "Curriculum design", "Group dynamics"],
            relatedCareerIDs: ["ux-researcher", "content-creator", "project-manager"],
            matchingTags: ["Helping people", "Learning", "Communicating", "Empathy", "Connection", "Impact", "In-person"]
        ),
        CareerPath(
            id: "creative-director",
            title: "Creative Director",
            shortDescription: "Guides creative work toward a clear shared vision.",
            overview: "Creative Directors shape the direction of creative projects and help teams turn ideas into coherent work.",
            categories: [.creative, .marketing, .leadership],
            attributes: ["Vision", "Creativity", "Collaboration", "Influence"],
            activities: ["Set creative direction", "Develop concepts", "Give feedback", "Bring people around a vision", "Balance quality and constraints"],
            opportunities: ["Work across creative fields", "Shape meaningful narratives", "Lead multidisciplinary teams", "Build a distinctive body of work"],
            challenges: ["Subjective feedback", "Tight constraints", "High accountability", "Protecting creative focus"],
            exploredSkills: ["Creating beauty", "Communicating", "Making decisions"],
            developingSkills: ["Creative direction", "Storytelling", "Team leadership"],
            relatedCareerIDs: ["product-designer", "content-creator", "product-manager"],
            matchingTags: ["Creating beauty", "Making things", "Creativity", "Communicating", "Collaborative", "Variety", "Freedom"]
        )
    ]

    static func career(id: String) -> CareerPath? {
        all.first { $0.id == id }
    }
}

@Observable
final class CareerExplorationStore {
    private(set) var shortlistedIDs: Set<String> = []
    private(set) var curiosity: [String: CareerCuriosity] = [:]

    func isShortlisted(_ career: CareerPath) -> Bool {
        shortlistedIDs.contains(career.id)
    }

    func toggleShortlist(_ career: CareerPath) {
        if isShortlisted(career) {
            shortlistedIDs.remove(career.id)
        } else {
            shortlistedIDs.insert(career.id)
        }
    }

    func curiosity(for career: CareerPath) -> CareerCuriosity? {
        curiosity[career.id]
    }

    func setCuriosity(_ level: CareerCuriosity, for career: CareerPath) {
        curiosity[career.id] = level
    }

    var shortlistedCareers: [CareerPath] {
        CareerPathData.all.filter { shortlistedIDs.contains($0.id) }
    }
}

extension CareerPath {
    func matchCount(with discoveryStore: DiscoveryStore) -> Int {
        let discovered = Set(DiscoveryCategory.allCases.flatMap { discoveryStore.selectedOptions(for: $0) })
        return matchingTags.intersection(discovered).count
    }

    func matchedAttributes(with discoveryStore: DiscoveryStore) -> [String] {
        let discovered = Set(DiscoveryCategory.allCases.flatMap { discoveryStore.selectedOptions(for: $0) })
        return attributes.filter { matchingTags.contains($0) || discovered.contains($0) }
    }

    func matchedDiscoveryOptions(with discoveryStore: DiscoveryStore) -> [String] {
        let discovered = Set(DiscoveryCategory.allCases.flatMap { discoveryStore.selectedOptions(for: $0) })
        return matchingTags.intersection(discovered).sorted()
    }
}
