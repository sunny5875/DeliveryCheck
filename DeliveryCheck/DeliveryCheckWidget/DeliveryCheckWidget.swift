//
//  DeliveryCheckWidget.swift
//  DeliveryCheckWidget
//
//  Created by 현수빈 on 10/22/24.
//

import WidgetKit
import SwiftUI
import SwiftData

import ComposableArchitecture

struct Provider: TimelineProvider {
    
    
    @Dependency(\.network) var network
    @Dependency(\.swiftData) var database
    
    
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
            var items = try database.fetchAll()
            for i in 0..<items.count {
                if let new = try? await network.fetch(items[i]) {
                    items[i] = new
                }
            }
            let nextRefresh = Calendar.current.date(byAdding: .hour, value: 12, to: currentDate)!
            let entry = SimpleEntry(date: nextRefresh, items: items)
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
        
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
            case .accessoryCircular:
                CircleView()
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
                    Group {
                        Text("👀 준비중")
                        Text("🛫 시작")
                        Text("🚀 진행중")
                        Text("🎁 완료")
                    }
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
    
    
    @ViewBuilder
    func CircleView() -> some View {
        let completed = Double(entry.items.filter { $0.statusCode == 3}.count)
        let range = 0.0...Double(entry.items.count)
        
        Gauge(value: completed, in: range) {
            Text(Int(completed), format: .number)
        } currentValueLabel: {
              Text("🎁")
        }
        .gaugeStyle(.accessoryCircular)
        .frame(width: 60, height: 60)
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
            .accessoryRectangular,
            .accessoryCircular
        ])
        .contentMarginsDisabled()
        .containerBackgroundRemovable(false)
    }
}
