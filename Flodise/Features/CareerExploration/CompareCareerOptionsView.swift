import SwiftUI

struct CompareCareerOptionsView: View {
    let discoveryStore: DiscoveryStore
    let careerStore: CareerExplorationStore

    @State private var selectedCareerIDs: Set<String>
    @State private var comparisonNotes: [String: String] = [:]

    init(discoveryStore: DiscoveryStore, careerStore: CareerExplorationStore) {
        self.discoveryStore = discoveryStore
        self.careerStore = careerStore
        _selectedCareerIDs = State(initialValue: Set(careerStore.shortlistedCareers.prefix(2).map(\.id)))
    }

    private var shortlistedCareers: [CareerPath] {
        careerStore.shortlistedCareers
    }

    private var selectedCareers: [CareerPath] {
        shortlistedCareers.filter { selectedCareerIDs.contains($0.id) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.large) {
                CompareHeader()

                if shortlistedCareers.isEmpty {
                    CompareEmptyState()
                } else if shortlistedCareers.count == 1 {
                    CompareSingleCareerState(career: shortlistedCareers[0])
                } else {
                    CareerComparisonPicker(
                        careers: shortlistedCareers,
                        selectedCareerIDs: $selectedCareerIDs
                    )

                    if selectedCareers.count < 2 {
                        CompareSelectionHint()
                    } else {
                        ComparisonContent(
                            careers: selectedCareers,
                            discoveryStore: discoveryStore,
                            careerStore: careerStore,
                            comparisonNotes: $comparisonNotes
                        )
                    }
                }
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.large)
        }
        .background(Color.adaptiveBackground)
        .navigationTitle("Compare Career Options")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CompareHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("Compare Career Options")
                .font(.largeTitle.weight(.bold))
            Text("See how your shortlisted paths differ.")
                .font(.body)
                .foregroundStyle(Color.adaptiveTextSecondary)
            Text("There isn't one perfect path. Compare what each option offers, requires, and asks of you.")
                .font(.subheadline)
                .foregroundStyle(Color.adaptiveTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct CareerComparisonPicker: View {
    let careers: [CareerPath]
    @Binding var selectedCareerIDs: Set<String>

    private var canAddAnotherCareer: Bool {
        selectedCareerIDs.count < 4
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("Choose paths to compare")
                    .font(.title3.weight(.bold))
                Text("Select 2–4 paths. Your shortlist stays unchanged.")
                    .font(.subheadline)
                    .foregroundStyle(Color.adaptiveTextSecondary)
            }

            VStack(spacing: Spacing.small) {
                ForEach(careers) { career in
                    Button {
                        toggle(career)
                    } label: {
                        HStack(spacing: Spacing.small) {
                            Image(systemName: selectedCareerIDs.contains(career.id) ? "checkmark.circle.fill" : "circle")
                                .font(.title3)
                                .foregroundStyle(selectedCareerIDs.contains(career.id) ? Color.brandPrimary : Color.adaptiveTextSecondary)
                            Text(career.title)
                                .font(.subheadline.weight(.medium))
                            Spacer()
                        }
                        .padding(Spacing.medium)
                        .foregroundStyle(Color.adaptiveTextPrimary)
                        .background(Color.adaptiveSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(selectedCareerIDs.contains(career.id) ? Color.brandPrimary.opacity(0.35) : Color.adaptiveSeparator.opacity(0.35), lineWidth: 1)
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(selectedCareerIDs.count == 4 && !selectedCareerIDs.contains(career.id))
                }
            }
        }
    }

    private func toggle(_ career: CareerPath) {
        if selectedCareerIDs.contains(career.id) {
            selectedCareerIDs.remove(career.id)
        } else if canAddAnotherCareer {
            selectedCareerIDs.insert(career.id)
        }
    }
}

private struct CompareSelectionHint: View {
    var body: some View {
        MessageCard(
            icon: "arrow.left.arrow.right",
            title: "Choose at least two paths",
            message: "Comparison works best when you can see the differences between possibilities."
        )
    }
}

private struct CompareEmptyState: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            MessageCard(
                icon: "bookmark",
                title: "You haven't shortlisted any career paths yet.",
                message: "Explore different paths first, then come back here when you have a few worth comparing."
            )

            Button {
                dismiss()
            } label: {
                Text("Explore Career Paths")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.brandPrimary)
        }
    }
}

private struct CompareSingleCareerState: View {
    let career: CareerPath
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            MessageCard(
                icon: "arrow.left.arrow.right",
                title: "Add at least one more career path to compare different possibilities.",
                message: "Keep exploring until you have another path that is worth considering alongside \(career.title)."
            )

            Button {
                dismiss()
            } label: {
                Text("Explore More Career Paths")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.brandPrimary)
        }
    }
}

private struct MessageCard: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.medium) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(Color.brandPrimary)
                .frame(width: 36, height: 36)
                .background(Color.brandTertiary)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Color.adaptiveTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.adaptiveSurface)
        .clipShape(RoundedRectangle(cornerRadius: Spacing.medium, style: .continuous))
    }
}

private struct ComparisonContent: View {
    let careers: [CareerPath]
    let discoveryStore: DiscoveryStore
    let careerStore: CareerExplorationStore
    @Binding var comparisonNotes: [String: String]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.large) {
            ComparisonDimension(title: "Overview") {
                ForEach(careers) { career in
                    ComparisonCareerCard(career: career, discoveryStore: discoveryStore, careerStore: careerStore)
                }
            }

            ComparisonDimension(title: "What You Might Do") {
                ForEach(careers) { career in
                    CareerComparisonColumn(career: career) {
                        BulletList(items: career.activities)
                    }
                }
            }

            ComparisonDimension(title: "Attributes") {
                ForEach(careers) { career in
                    CareerComparisonColumn(career: career) {
                        AttributeChips(attributes: career.attributes)
                    }
                }
            }

            ComparisonDimension(title: "Skills") {
                ForEach(careers) { career in
                    SkillsComparisonCard(career: career)
                }
            }

            DiscoveryConnectionsSection(careers: careers, discoveryStore: discoveryStore)

            ComparisonDimension(title: "Opportunities") {
                ForEach(careers) { career in
                    CareerComparisonColumn(career: career) {
                        BulletList(items: career.opportunities)
                    }
                }
            }

            ComparisonDimension(title: "Challenges") {
                ForEach(careers) { career in
                    CareerComparisonColumn(career: career) {
                        BulletList(items: career.challenges)
                    }
                }
            }

            TradeOffsSection(careers: careers)
            WorthExploringSection(careers: careers, careerStore: careerStore)
            ComparisonNotesSection(careers: careers, comparisonNotes: $comparisonNotes)
            ReflectionSection()
        }
    }
}

private struct ComparisonDimension<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text(title)
                .font(.title2.weight(.bold))
            content()
        }
    }
}

private struct ComparisonCareerCard: View {
    let career: CareerPath
    let discoveryStore: DiscoveryStore
    let careerStore: CareerExplorationStore

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    NavigationLink {
                        CareerPathDetailView(career: career, discoveryStore: discoveryStore, careerStore: careerStore)
                    } label: {
                        Text(career.title)
                            .font(.headline)
                            .foregroundStyle(Color.brandPrimary)
                    }
                    Text(career.shortDescription)
                        .font(.caption)
                        .foregroundStyle(Color.adaptiveTextSecondary)
                }
                Spacer(minLength: 8)
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.brandPrimary)
            }
            Text(career.overview)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
        .comparisonSurface()
    }
}

private struct CareerComparisonColumn<Content: View>: View {
    let career: CareerPath
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text(career.title)
                .font(.headline)
            content()
        }
        .comparisonSurface()
    }
}

private struct AttributeChips: View {
    let attributes: [String]

    var body: some View {
        FlowLayout(items: attributes) { attribute in
            Text(attribute)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
                .background(Color.brandTertiary)
                .clipShape(Capsule())
        }
    }
}

private struct SkillsComparisonCard: View {
    let career: CareerPath

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text(career.title)
                .font(.headline)
            Text("Skills you may already have explored")
                .font(.subheadline.weight(.semibold))
            BulletList(items: career.exploredSkills)
            Text("Skills worth developing")
                .font(.subheadline.weight(.semibold))
                .padding(.top, 6)
            BulletList(items: career.developingSkills)
        }
        .comparisonSurface()
    }
}

private struct DiscoveryConnectionsSection: View {
    let careers: [CareerPath]
    let discoveryStore: DiscoveryStore

    private var hasConnections: Bool {
        careers.contains { !$0.matchedDiscoveryOptions(with: discoveryStore).isEmpty }
    }

    var body: some View {
        if hasConnections {
            ComparisonDimension(title: "What Connects With What You've Discovered") {
                Text("These connections come from your Self Discovery reflections.")
                    .font(.subheadline)
                    .foregroundStyle(Color.adaptiveTextSecondary)
                ForEach(careers) { career in
                    let connections = career.matchedDiscoveryOptions(with: discoveryStore)
                    if !connections.isEmpty {
                        VStack(alignment: .leading, spacing: Spacing.small) {
                            Text(career.title)
                                .font(.headline)
                            ForEach(connections, id: \.self) { connection in
                                Label(connection, systemImage: "checkmark.circle.fill")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.brandPrimary)
                            }
                        }
                        .comparisonSurface()
                    }
                }
            }
        }
    }
}

private struct TradeOffsSection: View {
    let careers: [CareerPath]

    var body: some View {
        ComparisonDimension(title: "Trade-offs") {
            ForEach(careers) { career in
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text(career.title)
                        .font(.headline)
                    Text("What may appeal to you")
                        .font(.subheadline.weight(.semibold))
                    BulletList(items: career.attributes)
                    Text("What may require consideration")
                        .font(.subheadline.weight(.semibold))
                        .padding(.top, 6)
                    BulletList(items: career.challenges)
                }
                .comparisonSurface()
            }
        }
    }
}

private struct WorthExploringSection: View {
    let careers: [CareerPath]
    let careerStore: CareerExplorationStore

    var body: some View {
        ComparisonDimension(title: "Worth Exploring Further") {
            Text("Mark any paths you would like to understand more deeply. This is not a final choice.")
                .font(.subheadline)
                .foregroundStyle(Color.adaptiveTextSecondary)
            ForEach(careers) { career in
                Button {
                    careerStore.toggleWorthExploringFurther(career)
                } label: {
                    HStack {
                        Image(systemName: careerStore.isWorthExploringFurther(career) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(careerStore.isWorthExploringFurther(career) ? Color.brandPrimary : Color.adaptiveTextSecondary)
                        Text(career.title)
                            .font(.subheadline.weight(.medium))
                        Spacer()
                    }
                    .padding(Spacing.medium)
                    .foregroundStyle(Color.adaptiveTextPrimary)
                    .background(Color.adaptiveSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct ComparisonNotesSection: View {
    let careers: [CareerPath]
    @Binding var comparisonNotes: [String: String]

    var body: some View {
        ComparisonDimension(title: "Comparison Notes") {
            Text("Capture a thought while these differences are fresh.")
                .font(.subheadline)
                .foregroundStyle(Color.adaptiveTextSecondary)
            ForEach(careers) { career in
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text(career.title)
                        .font(.headline)
                    TextField(
                        "Why am I considering this path?",
                        text: Binding(
                            get: { comparisonNotes[career.id, default: ""] },
                            set: { comparisonNotes[career.id] = $0 }
                        ),
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                    .padding(Spacing.small)
                    .background(Color.adaptiveBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .comparisonSurface()
            }
        }
    }
}

private struct ReflectionSection: View {
    private let prompts = [
        "Which type of work energizes you?",
        "Which challenges are you willing to take on?",
        "Which skills would you enjoy developing?",
        "Which environment feels more natural to you?",
        "Which path would you like to learn more about?"
    ]

    var body: some View {
        ComparisonDimension(title: "Reflect") {
            Text("Which differences matter most to you?")
                .font(.subheadline)
                .foregroundStyle(Color.adaptiveTextSecondary)
            ForEach(prompts, id: \.self) { prompt in
                Label(prompt, systemImage: "circle")
                    .font(.subheadline)
            }
        }
    }
}

private struct BulletList: View {
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(items, id: \.self) { item in
                Label(item, systemImage: "circle.fill")
                    .font(.subheadline)
                    .labelStyle(ComparisonBulletLabelStyle())
            }
        }
    }
}

private struct ComparisonBulletLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            configuration.icon
                .font(.system(size: 5))
                .foregroundStyle(Color.brandPrimary)
            configuration.title
        }
    }
}

private struct FlowLayout<Item: Hashable, Content: View>: View {
    let items: [Item]
    @ViewBuilder let content: (Item) -> Content

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), alignment: .leading)], alignment: .leading, spacing: Spacing.small) {
            ForEach(items, id: \.self) { item in
                content(item)
            }
        }
    }
}

private extension View {
    func comparisonSurface() -> some View {
        padding(Spacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.adaptiveSurface)
            .clipShape(RoundedRectangle(cornerRadius: Spacing.medium, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Spacing.medium, style: .continuous)
                    .stroke(Color.adaptiveSeparator.opacity(0.35), lineWidth: 1)
            }
    }
}
