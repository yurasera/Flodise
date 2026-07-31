//
//  AppRootView.swift
//  Flodise
//
//  Created by Codex on 31/07/26.
//

import SwiftUI

struct AppRootView: View {
    @State private var selectedPage: AppPage = .home

    var body: some View {
        NavigationStack {
            Group {
                switch selectedPage {
                case .home:
                    HomeView()
                case .discovery:
                    DiscoveryView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button {
                            selectedPage = .home
                        } label: {
                            Label("Home", systemImage: "house.fill")
                                .foregroundStyle(selectedPage == .home ? Color.brandPrimary : .secondary)
                        }
                        .buttonStyle(.plain)

                        Button {
                            selectedPage = .discovery
                        } label: {
                            Label("Discovery", systemImage: "sparkles")
                                .foregroundStyle(selectedPage == .discovery ? Color.brandPrimary : .secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private enum AppPage: Hashable {
    case home
    case discovery
}
