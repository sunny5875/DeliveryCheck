//
//  ContentView.swift
//  DeliveryCheck
//
//  Created by 현수빈 on 10/22/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query var items: [Item]
    @Environment(\.modelContext) var modelContext
    @State private var isAdd = false

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        DetailItemView(item: item)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(DeliveryCompany(rawValue: item.carrierId)?.name ?? item.carrierId)
                                Text("운송장번호: " + item.trackingNumber)
                                    .font(.caption)
                            }
                            Spacer()
                            Text(item.statusTitle)
                                .foregroundStyle(.blue)
                                .font(.caption)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
                
            }
            .navigationTitle("택배췌크")
            .task {
                for item in items {
                    try? await fetchStatus(item: item)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: { isAdd.toggle()}) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $isAdd) {
            AddNewItemView(onAdd: { new in
                addItem(new: new)
                isAdd.toggle()
            })
        }
    }

    private func addItem(new: Item) {
        withAnimation {
            modelContext.insert(new)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
    
    private func fetchStatus(item: Item) async throws {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "apis.tracker.delivery"
        urlComponents.path = "/graphql"
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("TRACKQL-API-KEY 45458ld9m1fv5m12m660qs0jad:b808nhsv4va953s95k4r56hq86b45j6hcitch9f9n3rqg6ug2tn", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")


        let body = [
            "query": """
                   query Track($carrierId: ID!, $trackingNumber: String!) {
                       track(carrierId: $carrierId, trackingNumber: $trackingNumber) {
                           lastEvent {
                               time
                               status {
                                   code
                               }
                           }
                       }
                   }
                   """,
             "variables": [
                 "carrierId": item.carrierId,
                 "trackingNumber": item.trackingNumber
             ]
        ] as [String: Any]

        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60
        let session = URLSession(configuration: sessionConfig)

        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
            do {
                let json = try JSONDecoder().decode(Response.self, from: data)
                print(json)
                item.state = json.data.track.lastEvent.status.code
            } catch {
                print("Error parsing JSON response: \(error.localizedDescription)")
                throw error
            }
        } else {
            print("Server responded with error. Status code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
        }
    }
}
