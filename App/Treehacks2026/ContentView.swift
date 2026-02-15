//
//  ContentView.swift
//  Treehacks2026
//
//  Created by Joel Grayson on 2/13/26.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var searchText = ""
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(center: stanfordCenter, latitudinalMeters: 1000, longitudinalMeters: 1000)
    )
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: - Order Car
                    Text("Order Car")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Search bar
                    NavigationLink {
                        SetDestinationView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.title2)
                                .foregroundColor(.primary)
                            
                            Text("Where do you want to go?")
                                .foregroundColor(.primary)
                                .font(.body)
                        }
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 49)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                    }
                    
                    Spacer()
                        .frame(height: 80)
                    
                    // MARK: - About Car
                    Text("About Car")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Car image and label
                    VStack(alignment: .leading, spacing: 8) {
                        Image("Car")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 176)
                        
                        Text("Honda 2018 Accord")
                            .font(.subheadline)
                    }
                    
                    // MARK: - Car Location Map
                    Text("Location:")
                        .font(.subheadline)
                    
                    Map(position: $cameraPosition) {
                        UserAnnotation()
                        
                        // Car marker from MQTT GPS data
                        if let carCoord = MQTTManager.shared.carCoordinate {
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
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
        }
    }
}

#Preview {
    ContentView()
}
