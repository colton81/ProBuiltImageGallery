//
//  File.swift
//  
//
//  Created by Colton Hillebrand on 1/18/24.
//

import Foundation
public enum ImageType {
    case heic
    case jpeg
    case png
    case pdf
    case gif
    case tiff
    case bmp
    case ico
    case unknown
    
    public static func from(url: URL) -> ImageType {
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "heic":
            return .heic
        case "jpeg", "jpg":
            return .jpeg
        case "png":
            return .png
        case "pdf":
            return .pdf
        case "gif":
            return .gif
        case "tiff", "tif":
            return .tiff
        case "bmp":
            return .bmp
        case "ico":
            return .ico
        default:
            return .unknown
        }
    }
}



public protocol GridViewItem: Identifiable {
    var IDNo: Int? { get }
    var Url: String? {get}
    // Add other necessary properties or methods
}

public protocol GridViewDataModel:ObservableObject {
    associatedtype Item: GridViewItem
    var items: [Item] { get set }
    var ids:[Int]{get set}
    func fetchThumbnails() async
    func fetchOriginal(id: Int) async -> URL?
    func postImage(image: Data, type: ImageType, url: URL) async
    func deleteImage(_ item: Item)
    func refresh() async
    
}
