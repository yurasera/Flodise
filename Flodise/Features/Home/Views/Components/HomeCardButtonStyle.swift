//
//  HomeCardButtonStyle.swift
//  Flodise
//
//  Created by Yuhaya Lissera on 03/08/26.
//

import SwiftUI

struct HomeCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.snappy(duration: 0.18), value: configuration.isPressed)
    }
}
