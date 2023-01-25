//
//  SparkWidget.swift
//  SparkWidget
//
//  Created by Mikko Junnila on 25.1.2023.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    private let spotPricesNetworkService = SpotPricesNetworkService()

    func placeholder(in context: Context) -> SpotPricesForDayEntry {
        SpotPricesForDayEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SpotPricesForDayEntry) -> Void) {
        let entry = SpotPricesForDayEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let currentDate = Date()
        let nextFetchDate = Calendar.current.date(byAdding: .hour, value: 2, to: currentDate)!

        Task {
            let prices = await spotPricesNetworkService.fetchPrices()
            let sortedPrices = prices.sorted(by: { (a, b) in a.Rank ?? 0 < b.Rank ?? 0 })
            let lowestPrice = sortedPrices.first
            let highestPrice = sortedPrices.last

            let entries: [SpotPricesForDayEntry] = [
                SpotPricesForDayEntry(
                    date: currentDate,
                    lowestPrice: lowestPrice,
                    highestPrice: highestPrice
                ),
                SpotPricesForDayEntry(
                    date: nextFetchDate,
                    lowestPrice: lowestPrice,
                    highestPrice: highestPrice
                ),
            ]

            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
}

struct SpotPricesForDayEntry: TimelineEntry {
    let date: Date
    let lowestPrice: SpotPrice?
    let highestPrice: SpotPrice?
    
    init(date: Date, lowestPrice: SpotPrice? = nil, highestPrice: SpotPrice? = nil) {
        self.date = date
        self.lowestPrice = lowestPrice
        self.highestPrice = highestPrice
    }
}

func getFormattedDate(date: Date?, format: String) -> String? {
    guard let date = date else { return nil }
    let dateformat = DateFormatter()
    dateformat.dateFormat = format
    return dateformat.string(from: date)
}

struct SparkWidgetEntryView: View {
    var entry: Provider.Entry
    let formatter = DateFormatter()

    init(entry: Provider.Entry) {
        self.entry = entry

        formatter.dateStyle = .none
        formatter.timeStyle = .long
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color(red: 1, green: 1, blue: 1))

            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top, spacing: 4) {
                        Text("lowest")
                            .font(.custom("SF Pro Text", size: 14))
                            .foregroundColor(Color(red: 1, green: 1, blue: 1))
                        Text(
                            getFormattedDate(
                                date: entry.lowestPrice?.DateTime,
                                format: "HH.mm"
                            ) ?? "--"
                        )
                        .font(.custom("SF Pro Text", size: 14))
                        .foregroundColor(Color(red: 1, green: 1, blue: 1))
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                    HStack(alignment: .bottom, spacing: 4) {
                        if let lowestPrice = entry.lowestPrice?.PriceWithTax {
                            Text(String(format: "%.2f", lowestPrice * 100))
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(red: 0.45, green: 0.95, blue: 0.50))

                        } else {
                            Text("--")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(red: 0.45, green: 0.95, blue: 0.50))
                        }
                        Text("snt/kWh")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.45, green: 0.95, blue: 0.50))
                    }
                    .frame(maxWidth: .infinity, alignment: .bottomLeading)
                }

                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top, spacing: 4) {
                        Text("highest")
                            .font(.custom("SF Pro Text", size: 14))
                            .foregroundColor(Color(red: 1, green: 1, blue: 1))
                        Text(
                            getFormattedDate(
                                date: entry.highestPrice?.DateTime,
                                format: "HH.mm"
                            ) ?? "--"
                        )
                        .font(.custom("SF Pro Text", size: 14))
                        .foregroundColor(Color(red: 1, green: 1, blue: 1))
                    }
                    HStack(alignment: .bottom, spacing: 4) {
                        if let lowestPrice = entry.highestPrice?.PriceWithTax {
                            Text(String(format: "%.2f", lowestPrice * 100))
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(red: 0.98, green: 0.56, blue: 0.37))

                        } else {
                            Text("--")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(red: 0.98, green: 0.56, blue: 0.37))
                        }

                        Text("snt/kWh")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.98, green: 0.56, blue: 0.37))
                    }
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .leading)
        .padding(16)
        .background(
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 0.09, green: 0.31, blue: 0.51), location: 0.00),
                    .init(color: Color(red: 0.52, green: 0.77, blue: 1), location: 1.00),
                ]),
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )
        )
    }
}

struct SparkWidget: Widget {
    let kind: String = "SparkWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SparkWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct SparkWidget_Previews: PreviewProvider {
    static var previews: some View {
        SparkWidgetEntryView(
            entry: SpotPricesForDayEntry(
                date: Date(),
                lowestPrice: SpotPrice(Rank: 1, DateTime: Date(), PriceWithTax: 0.2743),
                highestPrice: SpotPrice(Rank: 7, DateTime: Date(), PriceWithTax: 0.5743)
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))

        SparkWidgetEntryView(
            entry: SpotPricesForDayEntry(
                date: Date()
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
