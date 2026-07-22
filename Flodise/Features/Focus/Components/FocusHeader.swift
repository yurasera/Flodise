//
//  FocusHeader.swift
//  Flocus
//

import SwiftUI

struct FocusHeader: View {
    let categoryName: String?
    let focusDurationText: String
    
    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Focus")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
                Text(categoryName ?? "Uncategorized")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
            }
            Spacer()

            Text(focusDurationText)
                .font(.caption)
                .fontWeight(.semibold)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
        }
    }
}
