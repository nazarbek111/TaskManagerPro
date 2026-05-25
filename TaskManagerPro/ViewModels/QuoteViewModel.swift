//
//  QuoteViewModel.swift
//  TaskManagerPro
//
//  Created by Nazarbek on 25.05.2026.
//

import Foundation
import Combine

@MainActor
final class QuoteViewModel: ObservableObject {
    @Published var quote: Quote?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let quoteService: QuoteServiceProtocol

    init(quoteService: QuoteServiceProtocol = QuoteService()) {
        self.quoteService = quoteService
    }

    func loadQuote() async {
        isLoading = true
        errorMessage = nil

        do {
            quote = try await quoteService.fetchQuote()
        } catch {
            errorMessage = "Could not load quote. Please try again."
        }

        isLoading = false
    }
}
