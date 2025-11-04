//
//  CalendarWriter.swift
//  Midterm1
//
//  Created by Aryan Palit on 11/3/25.
//


import EventKit

@MainActor
enum CalendarWriter {
    static let store = EKEventStore()

    static func addTaskToCalendar(_ task: TaskItem) async throws -> String {
        // Request permission first (only once per install)
        try await store.requestFullAccessToEvents()

        let event = EKEvent(eventStore: store)
        event.title = task.title
        event.notes = task.detail
        event.startDate = task.dueDate
        event.endDate = task.dueDate.addingTimeInterval(60 * 60) // 1 hr duration
        event.calendar = store.defaultCalendarForNewEvents
        event.addAlarm(EKAlarm(relativeOffset: -15 * 60)) // 15 min before

        try store.save(event, span: .thisEvent)
        return event.eventIdentifier // so you can persist it
    }
}
