//
//  File.swift
//  
//
//  Created by Colton Hillebrand on 1/18/24.
//

import Foundation
protocol GridViewItem: Identifiable {
    var IDNo: Int? { get }
    var Url: String? {get}
    // Add other necessary properties or methods
}

protocol GridViewDataModel:ObservableObject {
    associatedtype Item: GridViewItem
    var items: [Item] { get set }
    var ids:[Int]{get set}
    func fetchThumbnails() async
    func fetchOriginal(id: Int) async -> URL?
    func postImage(image: Data) async
    func deleteImage(_ item: Item)
    func refresh() async
    
}
