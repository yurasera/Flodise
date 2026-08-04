//
//  FocusEnergyLevel.swift
//  Flodise
//
//  Created by Yuhaya Lissera on 04/08/26.
//

import SwiftUI

struct FocusEnergyLevel: View {
    let backgroundColor: Color
    let foregroundColor: Color
    let selectedEnergy: EnergyLevel?
    let onSelect: (EnergyLevel) -> Void
    var isCompact = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            if let selectedEnergy {
                HStack(spacing: 10) {
                    Image(systemName: selectedEnergy.icon)
                        .font(.title2)

                    Text(selectedEnergy.title)
                        .font(.subheadline.weight(.medium))
                }
                .foregroundStyle(foregroundColor)
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .background(Color.accentColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .accessibilityLabel("Selected energy level: \(selectedEnergy.title)")
                .frame(maxWidth: isCompact ? nil : .infinity, alignment: .leading)
            } else {
                Text("How's your energy right now?")
                    .font(.headline)

                HStack(spacing: 16) {
                    ForEach(EnergyLevel.allCases) { level in
                        Button {
                            onSelect(level)
                        } label: {
                            VStack(spacing: 10) {
                                Image(systemName: level.icon)
                                    .font(.title2)

                                Text(level.title)
                                    .font(.caption2)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(backgroundColor)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
