//
//  DeliveryCheckWidgetLiveActivity.swift
//  DeliveryCheckWidget
//
//  Created by 현수빈 on 10/22/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct DeliveryCheckWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct DeliveryCheckWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DeliveryCheckWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension DeliveryCheckWidgetAttributes {
    fileprivate static var preview: DeliveryCheckWidgetAttributes {
        DeliveryCheckWidgetAttributes(name: "World")
    }
}

extension DeliveryCheckWidgetAttributes.ContentState {
    fileprivate static var smiley: DeliveryCheckWidgetAttributes.ContentState {
        DeliveryCheckWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: DeliveryCheckWidgetAttributes.ContentState {
         DeliveryCheckWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: DeliveryCheckWidgetAttributes.preview) {
   DeliveryCheckWidgetLiveActivity()
} contentStates: {
    DeliveryCheckWidgetAttributes.ContentState.smiley
    DeliveryCheckWidgetAttributes.ContentState.starEyes
}
