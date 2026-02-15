//
//  CarInfoView.swift
//  Treehacks2026
//
//  Created by Joel Grayson on 2/15/26.
//

import SwiftUI
import MapKit

struct CarInfoView: View {
    private var mqtt = MQTTManager.shared
    
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(center: stanfordCenter, latitudinalMeters: 1000, longitudinalMeters: 1000)
    )
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // MARK: - Connection Status
                    connectionStatus
                    
                    // MARK: - Car Image
                    VStack(alignment: .leading, spacing: 8) {
                        Image("Car")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 176)
                        
                        Text("Honda 2018 Accord")
                            .font(.subheadline)
                    }
                    
                    Divider()
                    
                    // MARK: - Car Location Map
                    Text("Car Location")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Map(position: $cameraPosition) {
                        UserAnnotation()
                        
                        if let carCoord = mqtt.carCoordinate {
                            Annotation("Car", coordinate: carCoord) {
                                Image("Car")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 56)
                            }
                            .annotationTitles(.hidden)
                        }
                    }
                    .mapStyle(.standard)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    if let coord = mqtt.carCoordinate {
                        HStack(spacing: 16) {
                            Label(String(format: "%.6f", coord.latitude), systemImage: "location")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Label(String(format: "%.6f", coord.longitude), systemImage: "location")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    // MARK: - Latest Topic Values
                    Text("Live Data")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    if mqtt.latestMessages.isEmpty {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                    .font(.title)
                                    .foregroundColor(.secondary)
                                Text("Waiting for data from car...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 24)
                            Spacer()
                        }
                    } else {
                        ForEach(sortedTopics, id: \.self) { topic in
                            if let msg = mqtt.latestMessages[topic] {
                                topicCard(topic: topic, message: msg)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // MARK: - Message Log
                    Text("Message Log")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    if mqtt.messageLog.isEmpty {
                        Text("No messages received yet.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(mqtt.messageLog.suffix(20).reversed()) { msg in
                            logRow(message: msg)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .navigationTitle("Car Info")
        }
    }
    
    // MARK: - Sorted Topics
    
    private var sortedTopics: [String] {
        mqtt.latestMessages.keys.sorted()
    }
    
    // MARK: - Connection Status
    
    private var connectionStatus: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(mqtt.isConnected ? .green : .red)
                .frame(width: 10, height: 10)
            
            Text(mqtt.isConnected ? "Connected" : "Disconnected")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(mqtt.isConnected ? .green : .red)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(mqtt.isConnected ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
        )
    }
    
    // MARK: - Topic Card
    
    private func topicCard(topic: String, message: MQTTReceivedMessage) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            // Topic name (strip "from-car/" prefix for cleanliness)
            let shortTopic = topic.replacingOccurrences(of: "from-car/", with: "")
            
            HStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.caption)
                    .foregroundColor(.blue)
                Text(shortTopic)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // Pretty-print JSON or show raw
            Text(prettyPrint(message.payload))
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.primary)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Log Row
    
    private func logRow(message: MQTTReceivedMessage) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(message.timestamp, style: .time)
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(message.topic.replacingOccurrences(of: "from-car/", with: ""))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                
                Text(message.payload)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Pretty Print JSON
    
    private func prettyPrint(_ jsonString: String) -> String {
        guard let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data),
              let prettyData = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys]),
              let pretty = String(data: prettyData, encoding: .utf8) else {
            return jsonString
        }
        return pretty
    }
}

#Preview {
    CarInfoView()
}
