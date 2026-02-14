//
//  Treehacks2026App.swift
//  Treehacks2026
//
//  Created by Joel Grayson on 2/13/26.
//

import SwiftUI
import CoreLocation

// Requests location permission on app launch
class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
}

@main
struct Treehacks2026App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    LocationManager.shared.requestPermission()
                }
        }
    }
}
