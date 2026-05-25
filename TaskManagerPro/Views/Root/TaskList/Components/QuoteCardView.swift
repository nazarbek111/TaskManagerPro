//
//  QuoteCardView.swift
//  TaskManagerPro
//
//  Created by Nazarbek on 25.05.2026.
//

import SwiftUI

struct QuoteCardView: View {
    @StateObject private var viewModel = QuoteViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Daily Motivation", systemImage: "sparkles")
                    .font(.headline)

                Spacer()

                Button {
                    Task {
                        await viewModel.loadQuote()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.subheadline.weight(.semibold))
                }
            }

            if viewModel.isLoading {
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Loading quote...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundStyle(.red)
            } else if let quote = viewModel.quote {
                VStack(alignment: .leading, spacing: 8) {
                    Text("“\(quote.q)”")
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Text("- \(quote.a)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("Tap refresh to load motivation.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .glassCardStyle()
        .task {
            if viewModel.quote == nil {
                await viewModel.loadQuote()
            }
        }
    }
}
