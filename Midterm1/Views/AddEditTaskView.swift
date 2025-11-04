//
//  AddEditTaskView.swift
//  Midterm1
//
//  Created by Aryan Palit on 10/12/25.
//


//
//  AddEditTaskView.swift
//  Midterm1
//
//  Created by Aryan Palit on 10/13/25.
//

import SwiftUI
import SwiftData

///
/// A form-driven view to create a new task or edit an existing one.
///
/// Purpose:
/// - Collects task details (title, description, due date, estimated time) and an optional category.
/// - Persists changes using SwiftData via the environment `modelContext`.
/// - Provides lightweight confirmation with a top banner and auto-dismisses on save.
///
/// Idea:
/// The view initializes from an optional `taskToEdit`. If present, fields are populated for editing;
/// otherwise it creates a new `TaskItem` on save. Categories are loaded with `@Query` for selection.
/// After saving (insert or update), the context is saved, a brief success banner is shown, and the
/// view dismisses shortly after.
struct AddEditTaskView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var categories: [Category]

    /// Optional: passed when editing an existing task
    var taskToEdit: TaskItem?

    // MARK: - Local State
    @State private var title = ""
    @State private var detail = ""
    @State private var dueDate = Date()
    @State private var estimatedTime = 1.0
    @State private var selectedCategory: Category?
    @State private var showSavedBanner = false

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                // MARK: Task Info
                Section("Task Info") {
                    TextField("Title", text: $title)
                        .autocorrectionDisabled()
                    TextField("Description", text: $detail, axis: .vertical)
                        .lineLimit(3...6)
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                }

                // MARK: Category & Time
                Section("Category & Time") {
                    Picker("Category", selection: $selectedCategory) {
                        Text("None").tag(Category?.none)
                        ForEach(categories) { category in
                            Text(category.name).tag(category as Category?)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Estimated Time")
                            Spacer()
                            Text("\(estimatedTime, specifier: "%.1f") hrs")
                                .foregroundStyle(.secondary)
                        }

                        Slider(value: $estimatedTime, in: 0.1...10, step: 0.1)
                            .tint(.accentColor)
                    }
                }

                // MARK: Save Button
                Section {
                    Button {
                        saveTask()
                    } label: {
                        Label(
                            taskToEdit == nil ? "Save Task" : "Update Task",
                            systemImage: taskToEdit == nil ? "checkmark.circle.fill" : "square.and.pencil.circle.fill"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle(taskToEdit == nil ? "Add Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .overlay(alignment: .top) {
                SaveFeedbackView(
                    message: taskToEdit == nil ? "Task Saved!" : "Task Updated!",
                    isVisible: $showSavedBanner
                )
                .padding(.top, 8)
            }
            .onAppear { populateIfEditing() }
        }
    }

    // MARK: - Helpers
    private func populateIfEditing() {
        if let task = taskToEdit {
            title = task.title
            detail = task.detail ?? ""
            dueDate = task.dueDate
            estimatedTime = task.estimatedTime
            selectedCategory = task.category
        }
    }

    private func saveTask() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        if let task = taskToEdit {
            // Update existing task
            task.title = trimmedTitle
            task.detail = detail.isEmpty ? nil : detail
            task.dueDate = dueDate
            task.estimatedTime = estimatedTime
            task.category = selectedCategory
        } else {
            // Create new task
            let newTask = TaskItem(
                title: trimmedTitle,
                detail: detail.isEmpty ? nil : detail,
                dueDate: dueDate,
                estimatedTime: estimatedTime,
                category: selectedCategory
            )
            context.insert(newTask)
        }

        try? context.save()

        withAnimation(.spring) { showSavedBanner = true }

        // Auto-dismiss after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            dismiss()
        }
    }
}

