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
        defer { isLoading = false }

        do {
            let fetched = try await quoteService.fetchQuote()
            self.quote = fetched
        } catch let urlError as URLError {
            switch urlError.code {
            case .notConnectedToInternet, .timedOut, .cannotFindHost, .cannotConnectToHost:
                self.errorMessage = "No internet connection. Please check your network."
            default:
                self.errorMessage = "Could not load quote. Please try again."
            }
        } catch {
            self.errorMessage = "Could not load quote. Please try again."
        }
    }
}
