import SwiftUI

struct CareerExplorationView: View {
    let discoveryStore: DiscoveryStore
    let careerStore: CareerExplorationStore

    @State private var searchText = ""
    @State private var selectedCategory: CareerCategory?

    private var filteredCareers: [CareerPath] {
        CareerPathData.all.filter { career in
            let matchesSearch = searchText.isEmpty ||
                career.title.localizedCaseInsensitiveContains(searchText) ||
                career.shortDescription.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == nil || career.categories.contains(selectedCategory!)
            return matchesSearch && matchesCategory
        }
    }

    private var personalizedCareers: [CareerPath] {
        let ranked = CareerPathData.all
            .map { ($0, $0.matchCount(with: discoveryStore)) }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
            .map(\.0)
        return ranked.isEmpty ? Array(CareerPathData.all.prefix(3)) : Array(ranked.prefix(3))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.large) {
                CareerExplorationHeader()

                BasedOnYouSection(
                    discoveryStore: discoveryStore,
                    careers: personalizedCareers,
                    careerStore: careerStore
                )

                MyCareerPathsSection(careerStore: careerStore, discoveryStore: discoveryStore)
                ExploreMoreSection(
                    careers: filteredCareers,
                    searchText: $searchText,
                    selectedCategory: $selectedCategory,
                    discoveryStore: discoveryStore,
                    careerStore: careerStore
                )
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.large)
        }
        .background(Color.adaptiveBackground)
        .navigationTitle("Explore Career Paths")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CareerExplorationHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("Explore Career Paths")
                .font(.largeTitle.weight(.bold))
            Text("Don't choose yet. Explore what's possible.")
                .font(.body)
                .foregroundStyle(Color.adaptiveTextSecondary)
        }
    }
}

private struct BasedOnYouSection: View {
    let discoveryStore: DiscoveryStore
    let careers: [CareerPath]
    let careerStore: CareerExplorationStore

    private var discoveredOptions: [String] {
        DiscoveryCategory.allCases.flatMap { discoveryStore.selectedOptions(for: $0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("Based on You")
                    .font(.title2.weight(.bold))
                if discoveredOptions.isEmpty {
                    Text("Start exploring careers based on your interests and curiosity.")
                        .font(.subheadline)
                        .foregroundStyle(Color.adaptiveTextSecondary)
                } else {
                    Text("Based on what you've discovered about yourself, these paths may be worth exploring.")
                        .font(.subheadline)
                        .foregroundStyle(Color.adaptiveTextSecondary)
                    
                    Text("You've explored: \(discoveredOptions.prefix(4).joined(separator: " • "))")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.brandPrimary)
                }
            }

            ForEach(careers) { career in
                CareerPathCard(
                    career: career,
                    label: discoveryStore.completedCount == 0 ? "Explore" : "Worth exploring",
                    discoveryStore: discoveryStore,
                    careerStore: careerStore
                )
            }
        }
    }
}

private struct ExploreMoreSection: View {
    let careers: [CareerPath]
    @Binding var searchText: String
    @Binding var selectedCategory: CareerCategory?
    let discoveryStore: DiscoveryStore
    let careerStore: CareerExplorationStore
    @State private var isExploreMoreExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isExploreMoreExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("Explore More")
                        .font(.title2.weight(.bold))

                    Spacer()

                    Image(systemName: isExploreMoreExpanded
                          ? "chevron.up"
                          : "chevron.down")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(Color.adaptiveTextPrimary)
            }
            .buttonStyle(.plain)

            if isExploreMoreExpanded {
                HStack(spacing: Spacing.small) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.adaptiveTextSecondary)
                    TextField("Search career paths", text: $searchText)
                        .textInputAutocapitalization(.never)
                }
                .padding(.horizontal, Spacing.medium)
                .padding(.vertical, 12)
                .background(Color.adaptiveSurface)
                .clipShape(RoundedRectangle(cornerRadius: Spacing.medium, style: .continuous))
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.small) {
                        CategoryChip(title: "All", isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }
                        ForEach(CareerCategory.allCases) { category in
                            CategoryChip(title: category.rawValue, isSelected: selectedCategory == category) {
                                selectedCategory = category
                            }
                        }
                    }
                }
                
                if careers.isEmpty {
                    Text("No career paths match this search yet.")
                        .font(.subheadline)
                        .foregroundStyle(Color.adaptiveTextSecondary)
                        .padding(.vertical, Spacing.medium)
                } else {
                    ForEach(careers) { career in
                        CareerPathCard(
                            career: career,
                            label: "Explore",
                            discoveryStore: discoveryStore,
                            careerStore: careerStore
                        )
                    }
                }
            }
        }
    }
}

private struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(title, action: action)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .foregroundStyle(isSelected ? Color.white : Color.adaptiveTextPrimary)
            .background(isSelected ? Color.brandPrimary : Color.adaptiveSurface)
            .clipShape(Capsule())
            .buttonStyle(.plain)
    }
}

private struct CareerPathCard: View {
    let career: CareerPath
    let label: String
    let discoveryStore: DiscoveryStore
    let careerStore: CareerExplorationStore

    var body: some View {
        NavigationLink {
            CareerPathDetailView(career: career, discoveryStore: discoveryStore, careerStore: careerStore)
        } label: {
            VStack(alignment: .leading, spacing: Spacing.small) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(career.title)
                            .font(.headline)
                        Text(career.shortDescription)
                            .font(.caption)
                            .foregroundStyle(Color.adaptiveTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.adaptiveTextSecondary)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(career.attributes, id: \.self) { attribute in
                            Text(attribute)
                                .font(.caption)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 5)
                                .background(Color.brandTertiary)
                                .clipShape(Capsule())
                        }
                    }
                }

                Text(label + "   ›")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.brandPrimary)
            }
            .padding(Spacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.adaptiveSurface)
            .clipShape(RoundedRectangle(cornerRadius: Spacing.medium, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Spacing.medium, style: .continuous)
                    .stroke(Color.adaptiveSeparator.opacity(0.35), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct MyCareerPathsSection: View {
    let careerStore: CareerExplorationStore
    let discoveryStore: DiscoveryStore

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            if !careerStore.shortlistedCareers.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("My Career Paths")
                        .font(.title2.weight(.bold))
                    Text("\(careerStore.shortlistedCareers.count) paths you're curious about")
                        .font(.subheadline)
                        .foregroundStyle(Color.adaptiveTextSecondary)
                }

                ForEach(careerStore.shortlistedCareers) { career in
                    CareerPathCard(
                        career: career,
                        label: "Shortlisted",
                        discoveryStore: discoveryStore,
                        careerStore: careerStore
                    )
                }
                NavigationLink {
                    CompareCareerOptionsView(discoveryStore: discoveryStore, careerStore: careerStore)
                } label: {
                    Label("Compare Career Options", systemImage: "arrow.left.arrow.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.brandPrimary)
            }

            
        }
    }
}

struct CareerPathDetailView: View {
    let career: CareerPath
    let discoveryStore: DiscoveryStore
    let careerStore: CareerExplorationStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.large) {
                CareerDetailHeader(career: career, careerStore: careerStore)
                DetailSection(title: "Overview") {
                    Text(career.overview)
                        .font(.body)
                }
                DetailSection(title: "What You Might Do") {
                    BulletList(items: career.activities)
                }
                WhyExploreSection(career: career, discoveryStore: discoveryStore)
                DetailSection(title: "Opportunities") {
                    BulletList(items: career.opportunities)
                }
                DetailSection(title: "Challenges") {
                    BulletList(items: career.challenges)
                }
                SkillSnapshot(career: career, discoveryStore: discoveryStore)
                CuriositySection(career: career, careerStore: careerStore)
                TryBeforeYouDecide()
                RelatedCareersSection(career: career, discoveryStore: discoveryStore, careerStore: careerStore)
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.large)
        }
        .background(Color.adaptiveBackground)
        .navigationTitle(career.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CareerDetailHeader: View {
    let career: CareerPath
    let careerStore: CareerExplorationStore

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text(career.title)
                        .font(.largeTitle.weight(.bold))
                    Text(career.shortDescription)
                        .font(.body)
                        .foregroundStyle(Color.adaptiveTextSecondary)
                }
                Spacer()
                Image(systemName: "arrow.up.right")
                    .foregroundStyle(Color.brandPrimary)
            }

            Button {
                careerStore.toggleShortlist(career)
            } label: {
                Label(careerStore.isShortlisted(career) ? "Shortlisted" : "Stay Curious", systemImage: careerStore.isShortlisted(career) ? "bookmark.fill" : "bookmark")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.brandPrimary)
        }
    }
}

private struct DetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text(title)
                .font(.title3.weight(.bold))
            content()
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
                    .labelStyle(BulletLabelStyle())
            }
        }
    }
}

private struct BulletLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            configuration.icon
                .font(.system(size: 5))
                .foregroundStyle(Color.brandPrimary)
            configuration.title
        }
    }
}

private struct WhyExploreSection: View {
    let career: CareerPath
    let discoveryStore: DiscoveryStore

    var body: some View {
        let connections = career.matchedDiscoveryOptions(with: discoveryStore)
        if !connections.isEmpty {
            DetailSection(title: "Why Explore This Path") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("These connections come from what you've explored so far.")
                        .font(.subheadline)
                        .foregroundStyle(Color.adaptiveTextSecondary)
                    ForEach(connections, id: \.self) { connection in
                        Label(connection, systemImage: "checkmark.circle.fill")
                            .font(.subheadline)
                            .foregroundStyle(Color.brandPrimary)
                    }
                }
            }
        }
    }
}

private struct SkillSnapshot: View {
    let career: CareerPath
    let discoveryStore: DiscoveryStore

    var body: some View {
        let explored = career.exploredSkills.filter { skill in
            DiscoveryCategory.allCases.flatMap { discoveryStore.selectedOptions(for: $0) }.contains(skill)
        }
        DetailSection(title: "Skill Snapshot") {
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("Already explored")
                    .font(.subheadline.weight(.semibold))
                if explored.isEmpty {
                    Text("Keep exploring to connect your existing strengths here.")
                        .font(.subheadline)
                        .foregroundStyle(Color.adaptiveTextSecondary)
                } else {
                    ForEach(explored, id: \.self) { skill in
                        Label(skill, systemImage: "checkmark.circle.fill")
                            .foregroundStyle(Color.brandPrimary)
                    }
                }
                Text("Worth developing")
                    .font(.subheadline.weight(.semibold))
                    .padding(.top, 6)
                ForEach(career.developingSkills, id: \.self) { skill in
                    Label(skill, systemImage: "circle")
                        .foregroundStyle(Color.adaptiveTextSecondary)
                }
            }
            .font(.subheadline)
        }
    }
}

private struct CuriositySection: View {
    let career: CareerPath
    let careerStore: CareerExplorationStore

    var body: some View {
        DetailSection(title: "How curious are you about this path?") {
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("This is about curiosity, not suitability.")
                    .font(.subheadline)
                    .foregroundStyle(Color.adaptiveTextSecondary)
                ForEach(CareerCuriosity.allCases) { level in
                    Button {
                        careerStore.setCuriosity(level, for: career)
                    } label: {
                        HStack {
                            Text(level.rawValue)
                            Spacer()
                            Image(systemName: careerStore.curiosity(for: career) == level ? "checkmark.circle.fill" : "circle")
                        }
                        .padding(Spacing.medium)
                        .foregroundStyle(careerStore.curiosity(for: career) == level ? Color.white : Color.adaptiveTextPrimary)
                        .background(careerStore.curiosity(for: career) == level ? Color.brandPrimary : Color.adaptiveSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct TryBeforeYouDecide: View {
    var body: some View {
        DetailSection(title: "Try Before You Decide") {
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("You don't need to commit to a career to learn more about it.")
                    .font(.subheadline)
                    .foregroundStyle(Color.adaptiveTextSecondary)
                BulletList(items: ["Talk to someone in this career", "Watch or observe the work", "Try a small beginner project", "Join a relevant community", "Take a short introductory course"])
                Button("Create an Experiment") { }
                    .buttonStyle(.bordered)
                    .tint(Color.brandPrimary)
                    .padding(.top, 4)
                    .accessibilityHint("Experiment planning will connect to First Action Plan in a future stage")
            }
        }
    }
}

private struct RelatedCareersSection: View {
    let career: CareerPath
    let discoveryStore: DiscoveryStore
    let careerStore: CareerExplorationStore

    var body: some View {
        DetailSection(title: "You Might Also Explore") {
            VStack(spacing: Spacing.small) {
                ForEach(career.relatedCareerIDs.compactMap { CareerPathData.career(id: $0) }) { related in
                    NavigationLink {
                        CareerPathDetailView(career: related, discoveryStore: discoveryStore, careerStore: careerStore)
                    } label: {
                        HStack {
                            Text(related.title)
                                .font(.subheadline.weight(.medium))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color.adaptiveTextSecondary)
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
}
