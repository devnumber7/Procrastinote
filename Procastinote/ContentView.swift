//
//  ContentView.swift
//  Midterm1
//
//  Created by Aryan Palit on 10/12/25.
//

import SwiftUI

/// The root view of the app.
///
/// Displays a `TabView` with two primary sections:
/// - Tasks: A navigable list of tasks presented inside a `NavigationStack` via `TaskListView`.
/// - Categories: A hub for browsing and managing categories via `CategoryHubView`.
///
/// The tab view adopts `.sidebarAdaptable` style to present as a sidebar on large screens
/// (like iPad or macOS) while remaining a standard tab bar on compact devices.
struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem{ Label("Home", systemImage: "house") }
            NavigationStack { TaskListView() }
                .tabItem { Label("Tasks", systemImage: "list.bullet") }
            CategoryHubView()
                .tabItem { Label("Categories", systemImage: "folder") }
        
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}
