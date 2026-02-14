//
//  ContentView.swift
//  Treehacks2026
//
//  Created by Joel Grayson on 2/13/26.
//

import SwiftUI

struct ContentView: View {
    @State private var searchText = ""
    
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
                        // TODO: Navigate to Set Destination screen
                        Text("Set Destination")
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.title2)
                                .foregroundColor(.black)
                            
                            Text("Where do you want to go?")
                                .foregroundColor(.black)
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
