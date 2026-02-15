//
//  MQTTManager.swift
//  Treehacks2026
//
//  Created by Joel Grayson on 2/14/26.
//

import Foundation
import CocoaMQTT
import CoreLocation

// MARK: - Configuration

let brokerHost = Secrets.brokerHost
let brokerPort: UInt16 = 1883

// MARK: - MQTT Topics

enum MQTTTopic {
    static let commandCar = "from-phone/command-car"
    static let gpsInfo = "from-car/gps-info"
    static let fromCarWildcard = "from-car/#"
}

// MARK: - Received MQTT Message

struct MQTTReceivedMessage: Identifiable {
    let id = UUID()
    let topic: String
    let payload: String
    let timestamp: Date
}

// MARK: - Codable Payloads

struct LocationPayload: Codable {
    let latitude: Double
    let longitude: Double
    let name: String?
}

struct CommandCarPayload: Codable {
    let pickup: LocationPayload
    let destination: LocationPayload
    let timestamp: TimeInterval
}

struct GPSInfo: Codable {
    let latitude: Double
    let longitude: Double
    let timestamp: TimeInterval
}

// MARK: - MQTT Manager

@Observable
class MQTTManager: NSObject {
    static let shared = MQTTManager()
    
    // Published state
    var carCoordinate: CLLocationCoordinate2D?
    var isConnected = false
    
    // Live data from from-car/ topics
    var latestMessages: [String: MQTTReceivedMessage] = [:]  // keyed by topic
    var messageLog: [MQTTReceivedMessage] = []  // chronological log (capped)
    
    private var mqtt: CocoaMQTT?
    
    override init() {
        super.init()
    }
    
    // MARK: - Connect
    
    func connect() {
        let clientID = "ios-\(UUID().uuidString.prefix(8))"
        let client = CocoaMQTT(clientID: clientID, host: brokerHost, port: brokerPort)
        client.username = Secrets.brokerUsername
        client.password = Secrets.brokerPassword
        client.keepAlive = 60
        client.delegate = self
        client.autoReconnect = true
        client.autoReconnectTimeInterval = 3
        
        mqtt = client
        
        // Enable CocoaMQTT's built-in protocol-level debug logging
        //CocoaMQTTLogger.logger.minNLogLevel = .debug
        
        let result = client.connect()
        print("[MQTT] Connecting to \(brokerHost):\(brokerPort) as \(Secrets.brokerUsername)... connect() returned \(result)")
    }
    
    // MARK: - Publish order
    
    func sendOrder(
        pickupCoordinate: CLLocationCoordinate2D,
        pickupName: String?,
        destinationCoordinate: CLLocationCoordinate2D,
        destinationName: String?
    ) {
        let payload = CommandCarPayload(
            pickup: LocationPayload(
                latitude: pickupCoordinate.latitude,
                longitude: pickupCoordinate.longitude,
                name: pickupName
            ),
            destination: LocationPayload(
                latitude: destinationCoordinate.latitude,
                longitude: destinationCoordinate.longitude,
                name: destinationName
            ),
            timestamp: Date().timeIntervalSince1970
        )
        
        guard let data = try? JSONEncoder().encode(payload),
              let jsonString = String(data: data, encoding: .utf8) else {
            print("[MQTT] Failed to encode order payload")
            return
        }
        
        mqtt?.publish(MQTTTopic.commandCar, withString: jsonString, qos: .qos1, retained: false)
        print("[MQTT] Published order to \(MQTTTopic.commandCar): \(jsonString) under user \(Secrets.brokerUsername)")
    }
    
    // MARK: - Disconnect
    
    func disconnect() {
        mqtt?.disconnect()
    }
}

// MARK: - CocoaMQTTDelegate

extension MQTTManager: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("[MQTT] CONNACK received: \(ack)")
        if ack == .accept {
            isConnected = true
            print("[MQTT] Connected successfully! Client ID: \(mqtt.clientID)")
            
            // Subscribe to all from-car/ topics (includes gps-info and any others)
            mqtt.subscribe(MQTTTopic.fromCarWildcard, qos: .qos1)
            print("[MQTT] Subscribing to \(MQTTTopic.fromCarWildcard)")
        } else {
            print("[MQTT] Connection REJECTED: \(ack)")
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        guard let payloadString = message.string,
              let data = payloadString.data(using: .utf8) else { return }
        
        let topic = message.topic
        
        // Store every from-car/ message for the Car Info view
        if topic.hasPrefix("from-car/") {
            let received = MQTTReceivedMessage(
                topic: topic,
                payload: payloadString,
                timestamp: Date()
            )
            DispatchQueue.main.async {
                self.latestMessages[topic] = received
                self.messageLog.append(received)
                // Cap the log at 100 entries
                if self.messageLog.count > 100 {
                    self.messageLog.removeFirst(self.messageLog.count - 100)
                }
            }
        }
        
        // Parse GPS specifically for the car coordinate on the map
        if topic == MQTTTopic.gpsInfo {
            if let gpsInfo = try? JSONDecoder().decode(GPSInfo.self, from: data) {
                DispatchQueue.main.async {
                    self.carCoordinate = CLLocationCoordinate2D(
                        latitude: gpsInfo.latitude,
                        longitude: gpsInfo.longitude
                    )
                }
                print("[MQTT] Received GPS: \(gpsInfo.latitude), \(gpsInfo.longitude)")
            }
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("[MQTT] didPublishMessage callback - topic: \(message.topic), id: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("[MQTT] PUBACK received from broker for message id: \(id) ✓")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        print("[MQTT] Subscribed to topics: \(success)")
        if !failed.isEmpty {
            print("[MQTT] Failed to subscribe: \(failed)")
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        print("[MQTT] Unsubscribed from: \(topics)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {}
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {}
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        isConnected = false
        if let err {
            print("[MQTT] Disconnected with error: \(err.localizedDescription)")
        } else {
            print("[MQTT] Disconnected")
        }
    }
}
