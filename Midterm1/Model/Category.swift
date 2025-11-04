//
//  Category.swift
//  Midterm1
//
//  Created by Aryan Palit on 10/12/25.
//


import Foundation
import SwiftData

@Model
final class Category: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String


    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}
