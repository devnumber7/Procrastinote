/// TaskListView.swift
/// Displays a grouped list of tasks using SwiftUI and SwiftData.
///
/// This view fetches `TaskItem` objects from the SwiftData store, groups them by
/// optional `Category`, and presents them in sections. Users can:
/// - Add new tasks
/// - Edit existing tasks
/// - Toggle completion state
/// - Delete tasks individually or clear all completed tasks
/// - Add tasks as event to the Calender
///
/// The view also shows a transient feedback banner after clearing completed tasks.

import SwiftUI
import SwiftData

/// A list view that displays tasks grouped by category, with support for adding,
/// editing, toggling completion, and batch-clearing completed items.
///
/// The view observes the SwiftData `modelContext` and a `@Query` of `TaskItem`
/// sorted by `dueDate`. UI state is managed via `@State` properties.
struct TaskListView: View {
    
    /// The SwiftData model context used to persist changes to tasks.
    @Environment(\.modelContext) private var context
    /// Live query of tasks sorted by due date.
    /// Updates automatically as the underlying store changes.
    @Query(sort: \TaskItem.dueDate) private var tasks: [TaskItem]
    /// Controls presentation of the confirmation alert for clearing completed tasks.
    @State private var showClearAlert = false
    /// Controls visibility of the  feedback banner after destructive actions.
    @State private var showFeedback = false
    /// The task currently selected for editing. When set, presents the edit sheet.
    @State private var selectedTask: TaskItem? = nil
    /// Controls presentation of the add-task sheet.
    @State private var showAddSheet = false
    /// Controls the presentation of EventKitUI in the sheet UI.
    @State private var taskToAddToCalendar : TaskItem? = nil

    /// Tasks grouped by their optional `Category`, sorted by category name.
    ///
    /// - Returns: An array of key/value pairs where the key is an optional category
    ///   and the value is the array of tasks in that category. The array is sorted
    ///   alphabetically by category name, with uncategorized tasks grouped under
    ///   "Uncategorized".
    private var groupedTasks: [(key: Category?, value: [TaskItem])] {
        let grouped: [Category?: [TaskItem]] = Dictionary(grouping: tasks, by: { $0.category })
        return grouped.sorted { lhs, rhs in
            let lhsName = lhs.key?.name ?? "Uncategorized"
            let rhsName = rhs.key?.name ?? "Uncategorized"
            return lhsName < rhsName
        }
    }
    
    
    private func addTaskToCalendar(_ task: TaskItem) {
        Task {
            do {
                let id = try await CalendarWriter.addTaskToCalendar(task)
                task.eventIdentifier = id
                try? context.save()
            } catch {
                print("Calendar write failed: \(error)")
            }
        }
    }

    /// The main content view.
    ///
    /// Presents a navigable list of tasks grouped in sections. Provides toolbar
    /// actions for adding tasks and clearing completed ones, edit and toggle
    /// gestures per row, confirmation alerts, and sheets for add/edit flows.
    var body: some View {
        
        NavigationStack {
            List {
                ForEach(groupedTasks, id: \.key?.id) { group in
                    Section(header: Text(group.key?.name ?? "Uncategorized")) {
                        ForEach(group.value) { task in
                            TaskRowView(
                                task: task,
                                onEdit: { selectedTask = task },
                                onToggle: {
                                    task.status.toggle()
                                    try? context.save()
                                }
                            )
                            .swipeActions(edge: .trailing , allowsFullSwipe: false){
                                Button { selectedTask = task }
                                label : {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                                
                                Button(role: .destructive) {
                                    context.delete(task)
                                    try? context.save()
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                Button {  taskToAddToCalendar = task }
                                label: {
                                    Label("Add to Calendar", systemImage: "calendar.badge.plus")
                                }
                                .tint(.orange)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if tasks.contains(where: { $0.status == .complete }) {
                        Button("Clear Completed") {
                            showClearAlert = true
                        }
                    }
                }
            }
            .alert("Clear All Completed?", isPresented: $showClearAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) { clearCompletedTasks() }
            } message: {
                Text("This will permanently delete all completed tasks.")
            }
            // MARK: - Sheets
            .sheet(item: $selectedTask) { task in
                AddEditTaskView(taskToEdit: task)
                    .environment(\.modelContext, context)
            }
            .sheet(isPresented: $showAddSheet) {
                AddEditTaskView()
                    .environment(\.modelContext, context)
            }
            // MARK: - Feedback Banner
            .overlay(alignment: .top) {
                SaveFeedbackView(
                    message: "Cleared completed tasks",
                    symbol: "trash.fill",
                    tint: .red,
                    isVisible: $showFeedback
                )
                .padding(.top, 8)
            }
        }
        .sheet(item: $taskToAddToCalendar){ task in
            EventEditSheet(task: task)
        }
    }

    /// Deletes all tasks whose status is `.complete` from the data store.
    private func clearCompletedTasks() {
        for task in tasks where task.status == .complete {
            context.delete(task)
        }
        try? context.save()
        withAnimation(.spring) { showFeedback = true }
    }
}

/// Toggles between `.complete` and `.notStarted`.
extension TaskStatus {
    mutating func toggle() {
        self = (self == .complete ? .notStarted : .complete)
    }
}

/// A single row representing a task with controls to toggle completion and edit.
private struct TaskRowView: View {
    /// The task model displayed by the row.
    let task: TaskItem
    /// Action invoked when the edit button is tapped.
    let onEdit: () -> Void
    /// Action invoked when the completion toggle is tapped.
    let onToggle: () -> Void

    /// The visual layout of the task row, including title, optional detail,
    /// due date, completion toggle, and edit affordance.
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: task.status == .complete ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.status == .complete ? .green : .gray)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .foregroundStyle(task.status == .complete ? .secondary : .primary)
                    .strikethrough(task.status == .complete)

                if let desc = task.detail, !desc.isEmpty {
                    Text(desc)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Text(task.dueDate, style: .date)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

        }
        .padding(.vertical, 6)
    }
}
