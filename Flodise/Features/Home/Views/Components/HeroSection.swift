//
//  HeroSection.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 01/07/26.
//

import SwiftUI

struct HomeHeroSection: View {
    let categories: [Category]
    let energy: Int
    let exp: Int
    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: Spacing.small) {
                NavigationLink {
                    StopPathView()
                } label: {
                    Text("Flodise")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.brandSecondary)
                }
                .buttonStyle(.plain)

                Text("Oddyssey Planning")
                    .font(.callout)
                    .foregroundStyle(Color.brandSecondary)
                
                VStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Label("Energy", systemImage: "bolt.fill")

                            Spacer()

                            Text("\(energy)/10")
                                .monospacedDigit()
                        }

                        ProgressView(value: Double(energy), total: 10)
                            .tint(.yellow)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Label("EXP", systemImage: "sparkles")

                            Spacer()

                            Text("\(exp)/100")
                                .monospacedDigit()
                        }

                        ProgressView(value: Double(exp), total: 100)
                            .tint(.blue)
                    }
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.white)
            .padding()
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.brandPrimary)
    }
}

private struct StopPathView: View {
    @State private var colorScheme: ColorScheme = .light

    var body: some View {
        VStack(spacing: 4) {
            Text("STOP.")
                .font(.title.weight(.bold))
                .multilineTextAlignment(.center)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))

            Text("Jalan sudah dipilih.")
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)

            Text("Istirahatkan pikiranmu.")
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(colorScheme)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    colorScheme = colorScheme == .dark ? .light : .dark
                } label: {
                    Image(systemName: colorScheme == .dark ? "sun.max.fill" : "moon.fill")
                }
                .accessibilityLabel(colorScheme == .dark ? "Switch to Light Mode" : "Switch to Dark Mode")
            }
        }
    }
}
