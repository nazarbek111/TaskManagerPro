//
//  SortMenuView.swift
//  TaskManagerPro
//
//  Created by Nazarbek on 19.03.2026.
//

import SwiftUI

struct SortMenuView: View {
    @Binding var selectedSortOption: TaskSortOption

    var body: some View {
        HStack {
            Label("Sort", systemImage: "arrow.up.arrow.down")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Spacer()

            Menu {
                Picker("Sort", selection: $selectedSortOption) {
                    ForEach(TaskSortOption.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(selectedSortOption.title)
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.bold))
                }
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.secondary.opacity(0.12), in: Capsule())
            }
        }
    }
}

