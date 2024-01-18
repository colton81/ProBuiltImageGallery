//
//  SwiftUIView.swift
//  
//
//  Created by Colton Hillebrand on 1/18/24.
//

import SwiftUI

struct DetailView<DataModel: GridViewDataModel>: View {
    @EnvironmentObject
    var dataModel: DataModel
    let id: Int
    @State var url: URL? = nil
    
    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            ProgressView()
        }
        .task{
            url = await dataModel.fetchOriginal(id: id)
        }
    }
}
