//
//  HeroSection.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 01/07/26.
//

import SwiftUI

struct HomeHeroSection: View {
    let categories: [Category]
    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("Flocus")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.brandSecondary)

                Text("Three words.")
                    .font(.callout)
                    .foregroundStyle(Color.brandSecondary)
                Text("Three roles.")
                    .font(.callout)
                    .foregroundStyle(Color.brandSecondary)
                Text("One journey.")
                    .font(.callout)
                    .foregroundStyle(Color.brandSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.white)
            .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.brandPrimary)
    }
}

