//
//  FilterChipsView.swift
//  TaskManagerPro
//
//  Created by Nazarbek on 19.03.2026.
//

import SwiftUI

struct FilterChipsView: View {
    @Binding var selectedFilter: TaskFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(TaskFilter.allCases) { filter in
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                            selectedFilter = filter
                        }
                    } label: {
                        Text(filter.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(selectedFilter == filter ? .white : .primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                Group {
                                    if selectedFilter == filter {
                                        Capsule().fill(Color.accentColor)
                                    } else {
                                        Capsule().fill(Color.secondary.opacity(0.12))
                                    }
                                }
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

