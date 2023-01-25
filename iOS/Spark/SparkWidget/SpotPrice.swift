//
//  SpotPrice.swift
//  Spark
//
//  Created by Mikko Junnila on 25.1.2023.
//

import Foundation

public struct SpotPrice: Decodable {
    let Rank: Int?
    let DateTime: Date?
    let PriceWithTax: Float?

    init(Rank: Int?, DateTime: Date?, PriceWithTax: Float?) {
        self.Rank = Rank
        self.DateTime = DateTime
        self.PriceWithTax = PriceWithTax
    }
}
