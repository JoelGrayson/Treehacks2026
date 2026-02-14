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

struct SetDestinationView: View {
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    @State private var completer = AddressSearchCompleter()
    
    let recommendedDestinations = [
        "Tresidder",
        "Lakeside",
        "ESIII (SSI Entrance)",
        "Stanford D-School"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Search bar
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.black)
                
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
            
            // MARK: - "or set pin on map"
            HStack(spacing: 6) {
                Spacer()
                Text("or")
                    .font(.body)
                
                Button(action: {
                    // TODO: Present map for dropping a pin
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
            .padding(.horizontal, 24)
            .padding(.top, 8)
            
            // MARK: - Results or Recommended Destinations
            if searchText.isEmpty {
                Text("Recommended Destinations")
                    .font(.body)
                    .fontWeight(.medium)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(recommendedDestinations, id: \.self) { destination in
                        Button {
                            // TODO: Handle destination selection
                        } label: {
                            Text(destination)
                                .font(.subheadline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 20)
                                .padding(.horizontal, 24)
                        }
                    }
                }
                .padding(.top, 8)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(completer.results, id: \.self) { result in
                            Button {
                                // TODO: Handle search result selection
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(result.title)
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                    
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
            }
            
            Spacer()
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
