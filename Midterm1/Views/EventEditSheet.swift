//
//  EventEditSheet.swift
//  Midterm1
//
//  Created by Aryan Palit on 11/3/25.
//


import SwiftUI
import EventKit
import EventKitUI

struct EventEditSheet: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    let task: TaskItem

    final class Coordinator: NSObject, EKEventEditViewDelegate {
        private let dismiss: DismissAction
        init(dismiss: DismissAction) { self.dismiss = dismiss }

        func eventEditViewController(_ controller: EKEventEditViewController,
                                     didCompleteWith action: EKEventEditViewAction) {
            controller.dismiss(animated: true)
            dismiss()
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(dismiss: dismiss) }

    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let store = EKEventStore()
        let controller = EKEventEditViewController()
        controller.eventStore = store
        controller.editViewDelegate = context.coordinator

      
        let event = EKEvent(eventStore: store)
        event.title = task.title
        event.notes = task.detail
        event.startDate = task.dueDate
        let duration = max(task.estimatedTime, 60 * 15) 
        event.endDate = task.dueDate.addingTimeInterval(duration)

        event.calendar = store.defaultCalendarForNewEvents

        controller.event = event
        return controller
    }

    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {}
}
