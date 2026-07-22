//
//  PriorityFilterSection.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 06/07/26.
//

import SwiftUI

struct PriorityFilterSection: View {
    @Binding var selectedCategory: CategoryFilter
    @Binding var selectedProgress: ProgressFilter
    @State private var showProgressFilter = false
    
    var body: some View {
        Section {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Category")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button {
                            withAnimation(.snappy) {
                                showProgressFilter.toggle()
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(selectedProgress.rawValue)
                                Image(systemName: showProgressFilter ? "chevron.up" : "chevron.down")
                                    .font(.caption2)
                            }
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.thinMaterial, in: Capsule())
                        }
                    }
                    
                    if showProgressFilter {
                        VStack(spacing: 8) {
                            ForEach(ProgressFilter.allCases) { progress in
                                Button {
                                    selectedProgress = progress
                                    withAnimation(.snappy) {
                                        showProgressFilter = false
                                    }
                                } label: {
                                    HStack {
                                        Text(progress.rawValue)
                                        Spacer()
                                        if selectedProgress == progress {
                                            Image(systemName: "checkmark")
                                                .font(.caption.weight(.semibold))
                                        }
                                    }
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(selectedProgress == progress ? Color.secondary.opacity(0.14) : Color.clear)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 4)
                    }
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(CategoryFilter.allCases) { category in
                            Text(category.rawValue == "Hobbies" ? "Creative" : category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .padding(.vertical, 8)
        }
    }
}
