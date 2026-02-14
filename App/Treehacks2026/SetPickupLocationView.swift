//
//  SetPickupLocationView.swift
//  Treehacks2026
//
//  Created by Joel Grayson on 2/14/26.
//

import SwiftUI
import MapKit

struct SetPickupLocationView: View {
    let destinationName: String?
    let destinationCoordinate: CLLocationCoordinate2D
    
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    @State private var completer = AddressSearchCompleter()
    @State private var isPinningOnMap = true
    @State private var pinCoordinate = stanfordCenter
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(center: stanfordCenter, latitudinalMeters: 1000, longitudinalMeters: 1000)
    )
    
    let recommendedPickups = [
        "Tresidder",
        "Lakeside",
        "ESIII (SSI Entrance)",
        "Stanford D-School"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Search bar for pickup location
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.primary)
                
                TextField("Type pickup location", text: $searchText)
                    .font(.body)
                    .focused($isSearchFocused)
                    .onChange(of: searchText) { _, newValue in
                        completer.updateSearch(query: newValue)
                    }
            }
            .padding(.horizontal, 16)
            .frame(height: 49)
            .background(Color(.systemGray5))
            .clipShape(Capsule())
            .padding(.horizontal, 24)
            
            // MARK: - "or set pin on map" / Cancel
            HStack(spacing: 6) {
                Spacer()
                
                if isPinningOnMap {
                    Button(action: {
                        isPinningOnMap = false
                        isSearchFocused = true
                    }) {
                        Text("Cancel")
                            .font(.body)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
                } else {
                    Text("or")
                        .font(.body)
                    
                    Button(action: {
                        isPinningOnMap = true
                        isSearchFocused = false
                    }) {
                        HStack(spacing: 4) {
                            Text("set pin on map")
                                .font(.body)
                            Image(systemName: "mappin")
                                .font(.body)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            
            // MARK: - Content area
            if !searchText.isEmpty {
                // Search results take priority when typing
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(completer.results, id: \.self) { result in
                            NavigationLink {
                                WaitingForCarView(destinationName: destinationName, pickupName: result.title)
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(result.title)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    
                                    if !result.subtitle.isEmpty {
                                        Text(result.subtitle)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 14)
                                .padding(.horizontal, 24)
                            }
                        }
                    }
                }
                .padding(.top, 12)
                
                Spacer()
            } else if isPinningOnMap {
                // Fixed center pin -- pan the map to move it
                Map(position: $cameraPosition) {
                    UserAnnotation()
                }
                    .mapStyle(.standard)
                    .onMapCameraChange { context in
                        pinCoordinate = context.camera.centerCoordinate
                    }
                    .overlay {
                        Image(systemName: "mappin.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                            .offset(y: -15)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 12)
                    .overlay(alignment: .bottom) {
                        NavigationLink {
                            WaitingForCarView(destinationName: destinationName, pickupName: nil)
                        } label: {
                            Text("Set Pickup Location")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.horizontal, 24)
                                .padding(.bottom, 24)
                        }
                    }
            } else if searchText.isEmpty {
                Text("Recommended Pickups")
                    .font(.body)
                    .fontWeight(.medium)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(recommendedPickups, id: \.self) { pickup in
                        NavigationLink {
                            WaitingForCarView(destinationName: destinationName, pickupName: pickup)
                        } label: {
                            Text(pickup)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 20)
                                .padding(.horizontal, 24)
                        }
                    }
                }
                .padding(.top, 8)
                
                Spacer()
            }
        }
        .padding(.top, 8)
        .navigationTitle("Set Pickup Location")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !isPinningOnMap {
                isSearchFocused = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        SetPickupLocationView(
            destinationName: "Huang",
            destinationCoordinate: CLLocationCoordinate2D(latitude: 37.4275, longitude: -122.1697)
        )
    }
}
