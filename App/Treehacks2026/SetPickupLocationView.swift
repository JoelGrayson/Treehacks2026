//
//  SetPickupLocationView.swift
//  Treehacks2026
//
//  Created by Joel Grayson on 2/14/26.
//

import SwiftUI
import MapKit

struct SetPickupLocationView: View {
    let destinationName: String
    
    // Map camera centered on Stanford campus
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.42871908539299, longitude: -122.17590176790549),
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        )
    )
    
    // Draggable pickup pin location (default: near Tresidder)
    @State private var pickupCoordinate = CLLocationCoordinate2D(
        latitude: 37.4243,
        longitude: -122.1710
    )
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Search bar (shows destination, non-editable)
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.black)
                
                Text(destinationName)
                    .font(.body)
                    .foregroundColor(.black)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 49)
            .background(Color(.systemGray5))
            .clipShape(Capsule())
            .padding(.horizontal, 16)
            
            // "Tap and hold to drag" instruction
            Text("Tap and hold to drag")
                .font(.subheadline)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 24)
                .padding(.top, 8)
            
            // MARK: - Map
            Map(position: $cameraPosition) {
                // Destination marker
                Annotation(destinationName, coordinate: CLLocationCoordinate2D(latitude: 37.4225, longitude: -122.1749)) {
                    VStack(spacing: 2) {
                        Text(destinationName)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        Circle()
                            .fill(.blue)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .fill(.white)
                                    .frame(width: 8, height: 8)
                            )
                    }
                }
                
                // Draggable pickup location pin
                Annotation("Pickup Location", coordinate: pickupCoordinate) {
                    VStack(spacing: 2) {
                        Text("Pickup Location")
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundColor(.pink)
                        
                        Circle()
                            .fill(.blue)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .fill(.white)
                                    .frame(width: 8, height: 8)
                            )
                    }
                }
                
                // Car image near pickup
                Annotation("Car", coordinate: CLLocationCoordinate2D(latitude: 37.4260, longitude: -122.1755)) {
                    Image("Car")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 56)
                }
            }
            .mapStyle(.standard)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 12)
        }
        .padding(.top, 8)
        .navigationTitle("Set Pickup Location")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SetPickupLocationView(destinationName: "Huang")
    }
}
