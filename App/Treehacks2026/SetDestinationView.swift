//
//  SetDestinationView.swift
//  Treehacks2026
//
//  Created by Joel Grayson on 2/14/26.
//

import SwiftUI

struct SetDestinationView: View {
    @State private var searchText = ""
    
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
                
                HStack(spacing: 4) {
                    Text("set pin on map")
                        .font(.body)
                    Image(systemName: "mappin")
                        .font(.body)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray5))
                .clipShape(Capsule())
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            
            // MARK: - Recommended Destinations
            Text("Recommended Destinations")
                .font(.body)
                .fontWeight(.medium)
                .padding(.horizontal, 24)
                .padding(.top, 24)
            
            // Destination list
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
            
            Spacer()
        }
        .padding(.top, 8)
        .navigationTitle("Set Destination")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SetDestinationView()
    }
}
