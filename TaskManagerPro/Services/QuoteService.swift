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

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 15

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.init(rawValue: httpResponse.statusCode == 404 ? URLError.resourceUnavailable.rawValue : URLError.badServerResponse.rawValue))
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys

        do {
            let quotes = try decoder.decode([Quote].self, from: data)
            guard let firstQuote = quotes.first else {
                throw URLError(.cannotParseResponse)
            }
            return firstQuote
        } catch let decodingError as DecodingError {
            throw decodingError
        } catch {
            throw URLError(.cannotParseResponse)
        }
    }
}
