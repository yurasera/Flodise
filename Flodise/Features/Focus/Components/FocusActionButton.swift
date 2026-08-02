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
            Button("Stop Focus", action: action)
                .font(.headline)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }
}
