//
//  TaskItem.swift
//  Midterm1
//
//  Created by Aryan Palit on 10/12/25.
//


import Foundation
import SwiftData

@Model
final class TaskItem: Identifiable {
    

    typealias Time = Double
    
    
    @Attribute(.unique) var id: UUID
    var title: String
    var detail: String?
    var dueDate: Date
    var estimatedTime: Double
    var status: TaskStatus
    var category: Category?
    
    var eventIdentifier : String?

    init(
        title: String,
        detail: String? = nil,
        dueDate: Date,
        estimatedTime: Time,
        category: Category? = nil,
        status: TaskStatus = .notStarted
    ) {
        self.id = UUID()
        self.title = title
        self.detail = detail
        self.dueDate = dueDate
        self.estimatedTime = estimatedTime
        self.category = category
        self.status = status
    }
}

enum TaskStatus: String, CaseIterable, Codable {
    case notStarted = "Not Started"
    case inProgress = "In Progress"
    case complete = "Complete"
}
