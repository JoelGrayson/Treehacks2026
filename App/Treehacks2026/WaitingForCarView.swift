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
    
    @State private var phase: RidePhase = .approaching
    @Environment(\.dismiss) private var dismiss
    
    // Map
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(center: stanfordCenter, latitudinalMeters: 800, longitudinalMeters: 800)
    )
    
    // Coordinates for destination, pickup, and car
    let destinationCoord = CLLocationCoordinate2D(latitude: 37.4243, longitude: -122.1710)
    let pickupCoord = CLLocationCoordinate2D(latitude: 37.4260, longitude: -122.1740)
    
    @State private var carCoord = CLLocationCoordinate2D(latitude: 37.4280, longitude: -122.1760)
    
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
            startApproachingTimer()
        }
    }
    
    // MARK: - Route Visualization (Map)
    
    private var routeVisualization: some View {
        Map(position: $cameraPosition) {
            UserAnnotation()
            
            // Destination marker
            Annotation(destinationName ?? "Destination", coordinate: destinationCoord) {
                VStack(spacing: 2) {
                    Text(destinationName ?? "Destination")
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
                    Text(pickupName ?? "Pickup Location")
                        .font(.caption)
                        .fontWeight(.medium)
                    
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
            
            // Route line
            MapPolyline(coordinates: [destinationCoord, pickupCoord])
                .stroke(.blue, lineWidth: 4)
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
        WaitingForCarView(destinationName: "Tresidder", pickupName: "Huang")
    }
}
