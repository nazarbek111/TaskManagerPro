//
//  StatisticsView.swift
//  TaskManagerPro
//
//  Created by Nazarbek on 19.03.2026.
//
import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Query private var tasks: [TaskItem]
    private let viewModel = StatisticsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Statistics")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .padding(.top, 8)

                        HStack(spacing: 16) {
                            ProgressRingView(progress: viewModel.completionRate(from: tasks))
                                .frame(width: 150, height: 150)

                            VStack(alignment: .leading, spacing: 12) {
                                Text("Completion Rate")
                                    .font(.headline)

                                Text("\(Int(viewModel.completionRate(from: tasks) * 100))%")
                                    .font(.system(size: 34, weight: .bold, design: .rounded))

                                Text("Keep moving. Consistency wins.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                        .padding(20)
                        .glassCardStyle()

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                            StatCardView(
                                title: "Total",
                                value: "\(viewModel.totalTasks(from: tasks))",
                                systemImage: "square.stack.3d.up.fill"
                            )

                            StatCardView(
                                title: "Completed",
                                value: "\(viewModel.completedTasks(from: tasks))",
                                systemImage: "checkmark.circle.fill"
                            )

                            StatCardView(
                                title: "Active",
                                value: "\(viewModel.activeTasks(from: tasks))",
                                systemImage: "bolt.fill"
                            )

                            StatCardView(
                                title: "Pinned",
                                value: "\(viewModel.pinnedTasks(from: tasks))",
                                systemImage: "pin.fill"
                            )
                        }

                        StatCardView(
                            title: "High Priority",
                            value: "\(viewModel.highPriorityCount(from: tasks))",
                            systemImage: "exclamationmark.triangle.fill"
                        )
                    }
                    .padding(.horizontal, AppTheme.screenHorizontalPadding)
                    .padding(.bottom, 24)
                }
            }
            .navigationBarHidden(true)
        }
    }
}
