//
//  SetDestinationView.swift
//  Treehacks2026
//
//  Created by Joel Grayson on 2/14/26.
//

import SwiftUI
import MapKit

// MARK: - Address Search (scoped to Stanford campus)

@Observable
class AddressSearchCompleter: NSObject, MKLocalSearchCompleterDelegate {
    var results: [MKLocalSearchCompletion] = []
    
    private let completer = MKLocalSearchCompleter()
    
    // Stanford campus bounding region (2 km radius)
    private let stanfordRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.42871908539299, longitude: -122.17590176790549), //huang
        latitudinalMeters: 5000,
        longitudinalMeters: 5000
    )
    
    override init() {
        super.init()
        completer.delegate = self
        completer.region = stanfordRegion
        completer.resultTypes = [.address, .pointOfInterest]
    }
    
    func updateSearch(query: String) {
        completer.queryFragment = query
    }
    
    // MARK: MKLocalSearchCompleterDelegate
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search completer error: \(error.localizedDescription)")
    }
}

// MARK: - Set Destination View

// Stanford campus center (reusable)
let stanfordCenter = CLLocationCoordinate2D(latitude: 37.42871908539299, longitude: -122.17590176790549)

// MARK: - Recommended Locations

struct RecommendedLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

let recommendedLocations: [RecommendedLocation] = [
    RecommendedLocation(name: "Tresidder", coordinate: CLLocationCoordinate2D(latitude: 37.42469641302641, longitude: -122.17095100502956)),
    RecommendedLocation(name: "Lakeside", coordinate: CLLocationCoordinate2D(latitude: 37.42587412867754, longitude: -122.17631716496038)),
    RecommendedLocation(name: "ESIII (SSI Entrance)", coordinate: CLLocationCoordinate2D(latitude: 37.42757985311627, longitude: -122.17447190324197)),
    RecommendedLocation(name: "Stanford D-School", coordinate: CLLocationCoordinate2D(latitude: 37.42603924794793, longitude: -122.1718639572872)),
]

struct SetDestinationView: View {
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    @State private var completer = AddressSearchCompleter()
    @State private var isPinningOnMap = false
    @State private var pinCoordinate = stanfordCenter
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(center: stanfordCenter, latitudinalMeters: 1000, longitudinalMeters: 1000)
    )
    
    let recommendedDestinations = recommendedLocations
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Search bar
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.primary)
                
                TextField("Type building name/address", text: $searchText)
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
                                SetPickupLocationView(
                                    destinationName: result.title,
                                    destinationCoordinate: stanfordCenter
                                )
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
                            SetPickupLocationView(
                                destinationName: nil,
                                destinationCoordinate: pinCoordinate
                            )
                        } label: {
                            Text("Confirm Location")
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
            } else {
                Text("Recommended Destinations")
                    .font(.body)
                    .fontWeight(.medium)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(recommendedDestinations) { destination in
                        NavigationLink {
                            SetPickupLocationView(
                                destinationName: destination.name,
                                destinationCoordinate: destination.coordinate
                            )
                        } label: {
                            Text(destination.name)
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
        .navigationTitle("Set Destination")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isSearchFocused = true
        }
    }
}

#Preview {
    NavigationStack {
        SetDestinationView()
    }
}
