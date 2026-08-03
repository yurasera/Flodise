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
    let level: Int
    let exp: Int
    @State private var isShowingCapacityInfo = false

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: Spacing.small) {
                HStack(alignment: .center, spacing: Spacing.small) {
                    Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.brandSecondary)

                    VStack(alignment: .leading, spacing: 2) {
                        HStack{
                            NavigationLink {
                                StopPathView()
                            } label: {
                                Text("Flodise")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.brandSecondary)
                            }
                            .buttonStyle(.plain)
                            
                            Spacer()

                            Button {
                                isShowingCapacityInfo = true
                            } label: {
                                Image(systemName: "questionmark.circle")
                                    .font(.caption)
                                    .foregroundStyle(Color.brandSecondary)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Daily Capacity Limit information")
                        }
                        Text("Odyssey Planning")
                            .font(.caption)
                            .foregroundStyle(Color.brandSecondary)
                    }
                }
                
                VStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Label("Energy", systemImage: "bolt.fill")

                            Spacer()

                            Text("\(energy)/10")
                                .monospacedDigit()
                        }

                        if energy >= 0 {
                            ProgressView(value: Double(energy), total: 10)
                                .tint(.yellow)
                        } else {
                            ProgressView(value: Double(abs(energy)), total: 10)
                                .tint(.red)
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Label("Level \(level)", systemImage: "sparkles")

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
        }
        .frame(maxWidth: .infinity)
        .background(Color.brandPrimary)
        .sheet(isPresented: $isShowingCapacityInfo) {
            DailyCapacityInfoView()
                .presentationDetents([.medium])
        }
    }
}

private struct DailyCapacityInfoView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Label("Daily Capacity Limit", systemImage: "bolt.fill")
                    .font(.title2.weight(.bold))

                Text("Setiap hari Anda memiliki kapasitas hingga 10 effort. Selesaikan task sesuai kapasitas ini agar rencana harian tetap realistis.")

                VStack(alignment: .leading, spacing: 8) {
                    Text("Tentang effort")
                        .font(.headline)
                    Text("Effort menggambarkan energi dan fokus yang dibutuhkan sebuah task. Nilainya dihitung dari lima indikator: perlu belajar, belum tahu cara, perlu banyak berpikir, perlu banyak langkah, dan butuh fokus penuh.")
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Capacity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct StopPathView: View {
    @State private var preferredColorScheme: ColorScheme = .dark

    var body: some View {
        VStack(spacing: 4) {
            Text("STOP!")
                .font(.title.weight(.bold))
                .multilineTextAlignment(.center)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))

            Text("Jalan sudah dipilih.")
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)

            Text("Istirahat!!!")
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(preferredColorScheme)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    preferredColorScheme = preferredColorScheme == .dark ? .light : .dark
                } label: {
                    Image(systemName: preferredColorScheme == .dark ? "sun.max.fill" : "moon.fill")
                }
                .accessibilityLabel(
                    preferredColorScheme == .dark ? "Switch to Light Mode" : "Switch to Dark Mode"
                )
            }
        }
    }
}
