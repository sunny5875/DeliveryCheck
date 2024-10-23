//
//  DeliveryCheckWidget.swift
//  DeliveryCheckWidget
//
//  Created by 현수빈 on 10/22/24.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), items: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), items: [])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        
        Task {
            let service = FetchDataService()
            let items = try await fetchData()
            for item in items {
                try? await service.fetchStatus(item: item)
            }
            let nextRefresh = Calendar.current.date(byAdding: .hour, value: 12, to: currentDate)!
            let entry = SimpleEntry(date: nextRefresh, items: items)
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
        
    }
    
    @MainActor
    public func fetchData() async throws -> [Item] {
        let descriptor = FetchDescriptor<Item>(predicate: nil)

        let context = ModelContainer.sharedModelContainer.mainContext
        let data = try context.fetch(descriptor)
        return data
    }
    
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let items: [Item]
}

struct DeliveryCheckWidgetEntryView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    
    var entry: Provider.Entry

    var body: some View {
        Group {
            switch widgetFamily {
            case .accessoryRectangular:
                RectangularView()
            default:
                defaultView()
            }
        }
        .containerBackground(for: .widget) { }
    }
    
    func defaultView() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\((entry.items.count))")
                .font(.headline)
            +
            Text("개의 배송체크")
                .font(.caption)
           
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("👀 준비중")
                        .font(.caption)
                    Text("🛫 시작")
                        .font(.caption)
                    Text("🚀 진행중")
                        .font(.caption)
                    Text("🎁 완료")
                        .font(.caption)
                }
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Group {
                        Text("\(entry.items.filter { $0.statusCode == 0}.count)개")
                        Text("\(entry.items.filter { $0.statusCode == 1 }.count)개")
                        Text("\(entry.items.filter { $0.statusCode == 2}.count)개")
                        Text("\(entry.items.filter { $0.statusCode == 3 }.count)개")
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    func RectangularView() -> some View {
        HStack {
            VStack {
                ViewThatFits {
                    Text("준비")
                        .font(.caption)
                    Text("👀")
                        .font(.caption)
                }
                Text("\(entry.items.filter { $0.statusCode == 0}.count)")
                    .font(.subheadline)
                    .bold()
            }
           Divider()
            VStack {
                ViewThatFits {
                    Text("시작")
                        .font(.caption)
                    Text("🛫")
                        .font(.caption)
                }
                Text("\(entry.items.filter { $0.statusCode == 1}.count)")
                    .font(.subheadline)
                    .bold()
            }
            Divider()
            VStack {
                ViewThatFits {
                    Text("진행")
                        .font(.caption)
                    Text("🚀")
                        .font(.caption)
                }
                Text("\(entry.items.filter { $0.statusCode == 2}.count)")
                    .font(.subheadline)
                    .bold()
            }
            Divider()
            VStack {
                ViewThatFits {
                    Text("완료")
                        .font(.caption)
                    Text("🎁")
                        .font(.caption)
                }
                Text("\(entry.items.filter { $0.statusCode == 3}.count)")
                    .font(.subheadline)
                    .bold()
            }
        }
    }
    
}




struct DeliveryCheckWidget: Widget {
    let kind: String = "DeliveryCheckWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DeliveryCheckWidgetEntryView(entry: entry)
                .padding()
        }
        .configurationDisplayName("배송체크")
        .description("배송체크에 있는 물품 상태를 확인합니다")
        .supportedFamilies([
            .systemSmall, .systemMedium, .systemLarge,
            .accessoryRectangular
        ])
        .contentMarginsDisabled()
        .containerBackgroundRemovable(false)
    }
}
