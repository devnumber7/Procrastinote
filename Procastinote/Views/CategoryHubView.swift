//
//  CategoryHubView.swift
//  Midterm1
//
//  Created by Aryan Palit on 10/12/25.
//

import SwiftUI
import SwiftData

/// CategoryHubView
///
/// A hub for managing task categories and viewing a quick time summary.
///
/// Purpose:
/// - Displays a summary of total estimated time per category derived from all tasks.
/// - Provides UI to create and delete categories backed by SwiftData.
/// - Gives lightweight, unobtrusive feedback via a top banner when changes are made.
///
/// The view queries `Category` and `TaskItem` models using `@Query`, derives per-category
/// totals in-memory, and presents two form sections: a time summary and a category manager.
/// Actions (add/delete) persist through the `modelContext` and briefly surface a success
/// confirmation using `SaveFeedbackView`.
struct CategoryHubView: View {
    @Environment(\.modelContext) private var context
    @Query private var categories: [Category]
    @Query private var tasks: [TaskItem]
    @State private var newCategoryName = ""
    @State private var showFeedback = false

    // MARK: - Derived totals
    private var totals: [(String, Double)] {
        Dictionary(grouping: tasks, by: { $0.category?.name ?? "Uncategorized" })
            .mapValues { group in
                group.reduce(0) { $0 + $1.estimatedTime }
            }
            .sorted { $0.key < $1.key }
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Time Summary Section
                Section {
                    if totals.isEmpty {
                        Text("No task data yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(totals, id: \.0) { name, hours in
                            HStack {
                                Text(name)
                                Spacer()
                                Text("\(hours, specifier: "%.1f") hrs")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                header: {
                    Label("Time Summary", systemImage: "clock")
                }
         
                // MARK: Manage Categories Section
                Section {
                    HStack {
                        TextField("New Category", text: $newCategoryName)
                        Button {
                            addCategory()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                        .buttonStyle(.borderless)
                    }

                    ForEach(categories) { category in
                        Text(category.name)
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { context.delete(categories[$0]) }
                        try? context.save()
                        withAnimation(.spring) { showFeedback = true }
                    }
                } header: {
                    Label("Manage Categories", systemImage: "folder")
                }
            }
            .navigationTitle("Categories")
            .overlay(alignment: .top) {
                SaveFeedbackView(
                    message: "Category updated",
                    symbol: "checkmark.circle.fill",
                    tint: .green,
                    isVisible: $showFeedback
                )
                .padding(.top, 8)
            }
        }
    }

    // MARK: - Helpers
    private func addCategory() {
        let name = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }

        let newCategory = Category(name: name)
        context.insert(newCategory)
        try? context.save()
        newCategoryName = ""
        withAnimation(.spring) { showFeedback = true }
    }
}
