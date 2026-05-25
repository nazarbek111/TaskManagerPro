//
//  QuoteService.swift
//  TaskManagerPro
//
//  Created by Nazarbek on 25.05.2026.
//

import Foundation

protocol QuoteServiceProtocol {
    func fetchQuote() async throws -> Quote
}

final class QuoteService: QuoteServiceProtocol {
    func fetchQuote() async throws -> Quote {
        guard let url = URL(string: "https://zenquotes.io/api/random") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let quotes = try JSONDecoder().decode([Quote].self, from: data)

        guard let firstQuote = quotes.first else {
            throw URLError(.cannotParseResponse)
        }

        return firstQuote
    }
}
