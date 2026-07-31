import SwiftUI

struct DiscoveryView: View {
    let store: DiscoveryStore
    let careerStore: CareerExplorationStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.large) {
                DiscoveryHeader()
                DiscoveryProgress(store: store)

                VStack(alignment: .leading, spacing: Spacing.medium) {
                    Text("Explore at your own pace")
                        .font(.title3.weight(.semibold))

                    ForEach(DiscoveryCategory.allCases) { category in
                        NavigationLink {
                            DiscoveryDetailView(category: category, store: store)
                        } label: {
                            DiscoveryCategoryCard(
                                category: category,
                                isComplete: store.isComplete(category),
                                selectedCount: store.selectedOptions(for: category).count
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                EmergingPatternCard(store: store)
                CareerExplorationCTA(store: store, careerStore: careerStore)
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.large)
        }
        .background(Color.adaptiveBackground)
        .navigationTitle("Self Discovery")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct DiscoveryHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("Self Discovery")
                .font(.largeTitle.weight(.bold))
            Text("Before deciding where to go, understand what matters to you.")
                .font(.body)
                .foregroundStyle(Color.adaptiveTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct DiscoveryProgress: View {
    let store: DiscoveryStore

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            HStack {
                Text("Your Discovery")
                    .font(.headline)
                Spacer()
                Text("\(store.completedCount) of 5 explored")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.adaptiveTextSecondary)
            }
            ProgressView(value: Double(store.completedCount), total: 5)
                .tint(Color.brandPrimary)
        }
        .padding(Spacing.medium)
        .background(Color.adaptiveSurface)
        .clipShape(RoundedRectangle(cornerRadius: Spacing.medium, style: .continuous))
    }
}

private struct DiscoveryCategoryCard: View {
    let category: DiscoveryCategory
    let isComplete: Bool
    let selectedCount: Int

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.medium) {
            Image(systemName: isComplete ? "checkmark" : category.icon)
                .font(.headline.weight(.semibold))
                .foregroundStyle(isComplete ? Color.white : Color.brandPrimary)
                .frame(width: 40, height: 40)
                .background(isComplete ? Color.brandPrimary : Color.brandTertiary)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(category.title)
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.adaptiveTextSecondary)
                }
                Text(isComplete ? "You've explored this part of yourself." : category.question)
                    .font(.subheadline)
                    .foregroundStyle(Color.adaptiveTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 6) {
                    Text(isComplete ? "Completed" : "Explore")
                        .font(.caption.weight(.semibold))
                    if isComplete && selectedCount > 0 {
                        Text("• \(selectedCount) selected")
                            .font(.caption)
                            .foregroundStyle(Color.adaptiveTextSecondary)
                    }
                }
                .foregroundStyle(Color.brandPrimary)
            }
        }
        .padding(Spacing.medium)
        .background(Color.adaptiveSurface)
        .clipShape(RoundedRectangle(cornerRadius: Spacing.medium, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Spacing.medium, style: .continuous)
                .stroke(isComplete ? Color.brandPrimary.opacity(0.25) : Color.adaptiveSeparator.opacity(0.35), lineWidth: 1)
        }
    }
}

private struct EmergingPatternCard: View {
    let store: DiscoveryStore

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Label("Your Emerging Pattern", systemImage: "wand.and.stars")
                .font(.headline)
            Text("As you explore, we'll help you notice patterns in what matters to you, what gives you energy, and how you prefer to work.")
                .font(.subheadline)
                .foregroundStyle(Color.adaptiveTextSecondary)
            if store.completedCount >= 3 {
                let themes = DiscoveryCategory.allCases
                    .flatMap { store.selectedOptions(for: $0) }
                    .prefix(5)
                    .joined(separator: " • ")
                Text("So far, you have noticed: \(themes)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.brandPrimary)
            } else {
                Text("Your pattern will become clearer as you explore.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.adaptiveTextSecondary)
            }
        }
        .padding(Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.adaptiveSurface)
        .clipShape(RoundedRectangle(cornerRadius: Spacing.medium, style: .continuous))
    }
}

private struct CareerExplorationCTA: View {
    let store: DiscoveryStore
    let careerStore: CareerExplorationStore

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("Ready to explore what's next?")
                    .font(.title3.weight(.bold))
                Text("Your discoveries will become the foundation for exploring different possible life and career paths.")
                    .font(.subheadline)
                    .foregroundStyle(Color.adaptiveTextSecondary)
            }

            NavigationLink {
                CareerExplorationView(discoveryStore: store, careerStore: careerStore)
            } label: {
                Text("Explore Career Paths")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.brandPrimary)
        }
        .padding(.bottom, Spacing.medium)
    }
}

struct DiscoveryDetailView: View {
    let category: DiscoveryCategory
    let store: DiscoveryStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.large) {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Image(systemName: category.icon)
                        .font(.title2)
                        .foregroundStyle(Color.brandPrimary)
                    Text(category.question)
                        .font(.title2.weight(.bold))
                    Text(category.detail)
                        .font(.body)
                        .foregroundStyle(Color.adaptiveTextSecondary)
                }

                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text("Choose what resonates")
                        .font(.headline)
                    Text("There are no right answers. Select anything that feels true for you.")
                        .font(.subheadline)
                        .foregroundStyle(Color.adaptiveTextSecondary)
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: Spacing.small)], spacing: Spacing.small) {
                    ForEach(category.options, id: \.self) { option in
                        Button {
                            store.toggle(option, for: category)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: store.isSelected(option, for: category) ? "checkmark.circle.fill" : "circle")
                                Text(option)
                                    .font(.subheadline.weight(.medium))
                                Spacer(minLength: 0)
                            }
                            .padding(Spacing.medium)
                            .foregroundStyle(store.isSelected(option, for: category) ? Color.white : Color.adaptiveTextPrimary)
                            .background(store.isSelected(option, for: category) ? Color.brandPrimary : Color.adaptiveSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button(store.isComplete(category) ? "Save reflection" : "Choose at least one") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.brandPrimary)
                .disabled(!store.isComplete(category))
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.large)
        }
        .background(Color.adaptiveBackground)
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
