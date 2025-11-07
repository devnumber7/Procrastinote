//
//  Midterm1App.swift
//  Midterm1
//
//  Created by Aryan Palit on 10/12/25.
//

import SwiftUI
import SwiftData

/// App entry point.
///
/// This app uses SwiftData for persistence. The model container is configured
/// with two persistent model types:
/// - `TaskItem`: Represents an individual to-do/task item that can be created,
///    read, updated, and deleted by the user.
/// - `Category`: Represents a grouping or label that tasks can belong to,
///    enabling organization and filtering.
///
/// Both models are registered with the shared `.modelContainer` so instances are
/// stored on device and automatically loaded across app launches.
@main
struct Procastinote: App {


    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [TaskItem.self, Category.self]) 
        }
    }
}

