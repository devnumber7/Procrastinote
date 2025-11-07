//
//  ProcastinoteWidget.swift
//  ProcastinoteWidget
//
//  Created by Aryan Palit on 11/7/25.
//
import WidgetKit
import SwiftUI

// MARK: - Timeline Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: .now, progress: 0.6, completed: 6, total: 10)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: .now, progress: 0.6, completed: 6, total: 10)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        // Read from App Group defaults
        let defaults = UserDefaults(suiteName: "group.com.aryanpalit.procrastinote")
        let progress = defaults?.double(forKey: "progress") ?? 0
        let completed = defaults?.integer(forKey: "completed") ?? 0
        let total = defaults?.integer(forKey: "total") ?? 0

        // Create a single entry
        let entry = SimpleEntry(date: .now, progress: progress, completed: completed, total: total)

        // Refresh every 30 minutes (WidgetKit caches aggressively)
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        let timeline = Timeline(entries: [entry], policy: .after(next))
        completion(timeline)
    }
}

// MARK: - Entry Model
struct SimpleEntry: TimelineEntry {
    let date: Date
    let progress: Double
    let completed: Int
    let total: Int
}

// MARK: - Widget View
struct ProcrastinoteWidgetEntryView: View {
    var entry: SimpleEntry

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10)
                .foregroundStyle(.quaternary)

            Circle()
                .trim(from: 0, to: entry.progress)
                .stroke(
                    AngularGradient(colors: [.blue, .green], center: .center),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {
                Text("\(Int(entry.progress * 100))%")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.semibold)
                Text("\(entry.completed)/\(entry.total)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Widget Configuration
struct ProcastinoteWidget: Widget {
    let kind: String = "ProcrastinoteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ProcrastinoteWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Task Completion")
        .description("See your current task progress at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Widget Preview
#Preview(as: .systemSmall) {
    ProcastinoteWidget()
} timeline: {
    SimpleEntry(date: .now, progress: 0.6, completed: 6, total: 10)
}
