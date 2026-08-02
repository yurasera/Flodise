//
//  FocusActionButton.swift
//  Flocus
//

import SwiftUI

struct FocusActionButton: View {
    let action: () -> Void
    let backgroundColor: Color
    let foregroundColor: Color
    
    var body: some View {
        VStack(spacing: 16) {
            Button {
                action()
            } label: {
                Label("Stop", systemImage: "stop.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .glassEffect()
        }
    }
}
