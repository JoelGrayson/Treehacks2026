//
//  WaitingForCarView.swift
//  Treehacks2026
//
//  Created by Joel Grayson on 2/14/26.
//

import SwiftUI
import MapKit

// MARK: - Ride Phase

enum RidePhase {
    case approaching
    case arrived
    case driving
    case reachedDestination
}

// MARK: - Waiting For Car View

struct WaitingForCarView: View {
    let destinationName: String?
    let pickupName: String?
    let destinationCoord: CLLocationCoordinate2D
    let pickupCoord: CLLocationCoordinate2D
    
    @State private var phase: RidePhase = .approaching
    @Environment(\.dismiss) private var dismiss
    
    // Map
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(center: stanfordCenter, latitudinalMeters: 800, longitudinalMeters: 800)
    )
    
    @State private var carCoord = CLLocationCoordinate2D(latitude: 37.4280, longitude: -122.1760)
    @State private var route: MKRoute?
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Route visualization (top half)
            routeVisualization
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // MARK: - Divider
            Divider()
            
            // MARK: - Status area (bottom half)
            statusArea
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
        }
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Send order via MQTT
            MQTTManager.shared.sendOrder(
                pickupCoordinate: pickupCoord,
                pickupName: pickupName,
                destinationCoordinate: destinationCoord,
                destinationName: destinationName
            )
            
            // Initialize car position at pickup while waiting for GPS
            carCoord = pickupCoord
            
            startApproachingTimer()
        }
        .onChange(of: MQTTManager.shared.carCoordinate?.latitude) { _, _ in
            if let newCoord = MQTTManager.shared.carCoordinate {
                withAnimation(.easeInOut(duration: 1.0)) {
                    carCoord = newCoord
                }
            }
        }
        .task {
            await fetchRoute()
        }
    }
    
    // MARK: - Route Visualization (Map)
    
    private var routeVisualization: some View {
        Map(position: $cameraPosition) {
            UserAnnotation()
            
            // Destination marker
            Annotation(destinationName ?? "Destination", coordinate: destinationCoord) {
                VStack(spacing: 2) {
                    Text("Destination: \(destinationName ?? "Selected")")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    blueDot
                }
            }
            .annotationTitles(.hidden)
            
            // Pickup marker
            Annotation(pickupName ?? "Pickup Location", coordinate: pickupCoord) {
                VStack(spacing: 2) {
                    if let pickupName {
                        Text("Pickup: \(pickupName)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Text("Pickup Location")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                
                    
                    blueDot
                }
            }
            .annotationTitles(.hidden)
            
            // Car
            Annotation("Car", coordinate: carCoord) {
                Image("Car")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 56)
            }
            .annotationTitles(.hidden)
            
            // Route line (real driving route)
            if let route {
                MapPolyline(route.polyline)
                    .stroke(.blue, lineWidth: 4)
            }
        }
        .mapStyle(.standard)
    }
    
    // MARK: - Update car position based on phase
    
    private func updateCarPosition() {
        withAnimation(.easeInOut(duration: 1.0)) {
            switch phase {
            case .approaching:
                carCoord = CLLocationCoordinate2D(latitude: 37.4280, longitude: -122.1760)
            case .arrived:
                carCoord = pickupCoord
            case .driving:
                // Midway between pickup and destination
                carCoord = CLLocationCoordinate2D(
                    latitude: (pickupCoord.latitude + destinationCoord.latitude) / 2,
                    longitude: (pickupCoord.longitude + destinationCoord.longitude) / 2
                )
            case .reachedDestination:
                carCoord = destinationCoord
            }
        }
    }
    
    // MARK: - Blue dot component
    
    private var blueDot: some View {
        Circle()
            .fill(.blue)
            .frame(width: 22, height: 22)
            .overlay(
                Circle()
                    .fill(.white)
                    .frame(width: 9, height: 9)
            )
    }
    
    // MARK: - Status Area
    
    private var statusArea: some View {
        VStack(alignment: .leading, spacing: 24) {
            switch phase {
            case .approaching:
                Text("Car approaching")
                    .font(.title3)
                    .fontWeight(.medium)
                Text("100 feet away")
                    .font(.body)
                    .foregroundColor(.secondary)
                
            case .arrived:
                Text("Car arrived")
                    .font(.title3)
                    .fontWeight(.medium)
                
                Button {
                    phase = .driving
                    updateCarPosition()
                    startDrivingTimer()
                } label: {
                    Text("Start Driving")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
            case .driving:
                Text("Car arrived")
                    .font(.title3)
                    .fontWeight(.medium)
                Text("40 feet away")
                    .font(.body)
                    .foregroundColor(.secondary)
                
            case .reachedDestination:
                HStack {
                    Spacer()
                    Text("You've arrived")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                }
                
                NavigationLink {
                    ContentView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    Text("Start New Ride")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    // MARK: - Fetch driving route
    
    private func fetchRoute() async {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: pickupCoord))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoord))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        if let response = try? await directions.calculate() {
            route = response.routes.first
        }
    }
    
    // MARK: - Timers
    
    private func startApproachingTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            phase = .arrived
            updateCarPosition()
        }
    }
    
    private func startDrivingTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            phase = .reachedDestination
            updateCarPosition()
        }
    }
}

#Preview {
    NavigationStack {
        WaitingForCarView(
            destinationName: "Tresidder",
            pickupName: "Huang",
            destinationCoord: CLLocationCoordinate2D(latitude: 37.4243, longitude: -122.1710),
            pickupCoord: CLLocationCoordinate2D(latitude: 37.4260, longitude: -122.1740)
        )
    }
}
