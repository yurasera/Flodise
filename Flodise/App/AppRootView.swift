//
//  AppRootView.swift
//  Flodise
//
//  Created by Codex on 31/07/26.
//

import SwiftUI

struct AppRootView: View {
    @State private var selectedPage: AppPage = .home
    @State private var discoveryStore = DiscoveryStore()

    var body: some View {
        NavigationStack {
            Group {
                switch selectedPage {
                case .home:
                    HomeView()
                case .discovery:
                    DiscoveryView(store: discoveryStore)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button {
                        selectedPage = .home
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")
                                .font(.system(size: 16, weight: .medium))

                            Text("Odyssey")
                                .font(.caption2)
                        }
                        .frame(minWidth: 32)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                    }
                    .tint(selectedPage == .home ? .accentColor : .secondary)

                    Button {
                        selectedPage = .discovery
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16, weight: .medium))

                            Text("Discovery")
                                .font(.caption2)
                        }
                        .frame(minWidth: 32)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                    }
                    .tint(selectedPage == .discovery ? .accentColor : .secondary)
                }
            }
        }
    }
}

private enum AppPage: Hashable {
    case home
    case discovery
}
