//
//  FocusActionButton.swift
//  Flocus
//

import SwiftUI

struct FocusActionButton: View {
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Button("Stop Focus", action: action)
                .font(.headline)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .glassEffect()
        }
    }
}
