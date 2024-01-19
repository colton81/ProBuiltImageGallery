//
//  SwiftUIView.swift
//  
//
//  Created by Colton Hillebrand on 1/18/24.
//

import SwiftUI

struct GridItemView<Loader>: View where Loader: View {
    let size: Double
    let url: URL
    let loadingView: Loader
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            CacheAsyncImage(url: url) { phase in
                if let image = phase.image {
                    image // Displays the loaded image.
                        .resizable()
                        .scaledToFit()
                } else if phase.error != nil {
                    VStack(spacing: 10) {
                        Label("", systemImage: "exclamationmark.triangle.fill")
                            .labelStyle(.iconOnly)
                            .foregroundStyle(.red)
                            .font(.title)
                        Text("Error unable to load image")
                            .font(.caption)
                    }
                } else {
                    loadingView
                }
            }
            .frame(width: size, height: size)
        }
    }
}

#Preview {
    GridItemView(
        size: 250,
        url: URL(string: "https://picsum.photos/200/300")!,
        loadingView: ProgressView()
    )
    
    
}
