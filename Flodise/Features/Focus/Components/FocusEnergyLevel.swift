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
    
    @State private var selectedEnergy: EnergyLevel = .okay
    
    var energyValue: Int {
        selectedEnergy.rawValue
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            Text("How's your energy right now?")
                .font(.headline)
            
            HStack(spacing: 16) {
                ForEach(EnergyLevel.allCases) { level in
                    
                    Button {
                        withAnimation(.snappy) {
                            selectedEnergy = level
                        }
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
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(selectedEnergy == level
                                      ? Color.accentColor.opacity(0.15)
                                      : backgroundColor)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(
                                    selectedEnergy == level
                                    ? Color.accentColor
                                    : Color.clear,
                                    lineWidth: 2
                                )
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Text(selectedEnergy.title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }
}
