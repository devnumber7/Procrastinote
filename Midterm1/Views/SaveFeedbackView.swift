//
//  SaveFeedbackView.swift
//  Midterm1
//
//  Created by Aryan Palit on 10/12/25.
//

import SwiftUI
import UIKit

/// A reusable feedback banner with haptic confirmation.
struct SaveFeedbackView: View {
    let message: String
    var symbol: String = "checkmark.circle.fill"
    var tint: Color = .green

    @Binding var isVisible: Bool

    var body: some View {
        if isVisible {
            Label {
                Text(message)
                    .font(.headline)
            } icon: {
                Image(systemName: symbol)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(tint, .white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
            .shadow(radius: 4)
            .transition(.move(edge: .top).combined(with: .opacity))
            .onAppear {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.spring) {
                        isVisible = false
                    }
                }
            }
        }
    }
}


