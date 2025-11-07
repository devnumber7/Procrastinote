//
//  HomeView.swift
//  Procastinote
//
//  Created by Aryan Palit on 11/4/25.
//

import SwiftUI
import SwiftData
import Charts
import WidgetKit


struct HomeView: View {
    @Query(sort: \TaskItem.dueDate) private var tasks: [TaskItem]

    private var totalCount: Int { tasks.count }
    private var completedCount: Int { tasks.filter { $0.status == .complete }.count }
    private var completionRate: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    private var tasksByCategory: [(String, Int)] {
        let grouped = Dictionary(grouping: tasks) { $0.category?.name ?? "Uncategorized" }
        return grouped.map { ($0.key, $0.value.count) }.sorted { $0.0 < $1.0 }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // MARK: - Completion Card
                    DonutCard(title: "Task Overview", progress: completionRate, completed: completedCount, total: totalCount)
                
                    // MARK: - Category Chart
                    ChartCard(title: "Tasks by Category") {
                        Chart(tasksByCategory, id: \.0) { item in
                            BarMark(
                                x: .value("Tasks", item.1),
                                y: .value("Category", item.0)
                            )
                            .annotation(position: .trailing) {
                                Text("\(item.1)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .chartXAxis(.hidden)
                        .chartYAxis {
                            AxisMarks(preset: .aligned, position: .leading)
                        }
                        .frame(height: CGFloat(tasksByCategory.count * 36))
                    }

                  
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }

    
    private func saveProgressToSharedDefaults(){
        let defaults = UserDefaults(suiteName: "group.com.devnumber7.procrastinote")
        defaults?.set(completionRate, forKey: "In Porgress")
        defaults?.set(completedCount, forKey: "Completed")
        defaults?.set(totalCount, forKey: "Total Tasks")
        WidgetCenter.shared.reloadAllTimelines()
    }
}



@available(iOS 18.0, *)
private struct ChartCard<Content: View>: View {
    let title: String
    let alignment: Alignment
    @ViewBuilder var content: Content

    init(title: String, alignment: Alignment = .leading, @ViewBuilder content: () -> Content) {
        self.title = title
        self.alignment = alignment
        self.content = content()
    }

    var body: some View {
        VStack(alignment: alignment.horizontal == .leading ? .leading : .center, spacing: 12) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: alignment)
            content
                .frame(maxWidth: .infinity, alignment: alignment)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: alignment)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(radius: 1)
    }
}


@available(iOS 18.0, *)
private struct ProgressCard: View {
    let title: String
    let progress: Double
    let completed: Int
    let total: Int

    var body: some View {
        ChartCard(title: title) {
            VStack(alignment: .leading, spacing: 8) {
                ProgressView(value: progress)
                    .tint(.blue)
                Text("\(completed) / \(total) completed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

@available(iOS 18.0, *)
private struct DonutCard: View {
    let title: String
    let progress: Double
    let completed: Int
    let total: Int

    @State private var animatedProgress: Double = 0

    var body: some View {
        ChartCard(title: title, alignment: .center) {
            VStack(spacing: 16) {
                ZStack {
                    // Background ring
                    Circle()
                        .stroke(lineWidth: 16)
                        .foregroundStyle(.quaternary)

                    // Animated progress ring
                    Circle()
                        .trim(from: 0, to: animatedProgress)
                        .stroke(
                            AngularGradient(
                                colors: [.blue, .green],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 16, lineCap: .round)
                        )
                    
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: animatedProgress)

                   
                    VStack(spacing: 4) {
                        Text("\(Int(progress * 100))%")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.semibold)
                        Text("\(completed)/\(total)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 160, height: 160)
                .padding(.top, 4)
            }
            .onAppear {
                animatedProgress = progress
            }
        }
    }
    

}


