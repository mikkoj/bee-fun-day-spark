//
//  SpotPricesNetworkService.swift
//  Spark
//
//  Created by Mikko Junnila on 25.1.2023.
//

import Foundation

public class SpotPricesNetworkService {
    func fetchPrices() async -> [SpotPrice] {
        let url = URL(string: "https://api.spot-hinta.fi/Today")!
        let urlSession = URLSession.shared
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let (data, _) = try await urlSession.data(from: url)
            let spotPrices = try decoder.decode([SpotPrice].self, from: data)
            return spotPrices
        } catch {
            debugPrint("Error loading \(url): \(String(describing: error))")
            return []
        }
    }
}
