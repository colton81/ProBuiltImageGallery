//
//  File.swift
//  
//
//  Created by Colton Hillebrand on 1/18/24.
//

import Foundation
import SwiftUI
import PhotosUI
struct PhotoPicker<DataModel: GridViewDataModel>: UIViewControllerRepresentable {
    @EnvironmentObject
    var dataModel: DataModel
    
    /// A dismiss action provided by the environment. This may be called to dismiss this view controller.
    @Environment(\.dismiss)
    var dismiss
    
    /// Creates the picker view controller that this object represents.
    func makeUIViewController(context: UIViewControllerRepresentableContext<PhotoPicker>) -> PHPickerViewController {
        // Configure the picker.
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        // Limit to images.
        configuration.filter = .images
        // Avoid transcoding, if possible.
        configuration.preferredAssetRepresentationMode = .current
        
        let photoPickerViewController = PHPickerViewController(configuration: configuration)
        photoPickerViewController.delegate = context.coordinator
        return photoPickerViewController
    }
    
    /// Creates the coordinator that allows the picker to communicate back to this object.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    /// Updates the picker while it’s being presented.
    func updateUIViewController(_: PHPickerViewController, context _: UIViewControllerRepresentableContext<PhotoPicker>) {
        // No updates are necessary.
    }
    class Coordinator: NSObject, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
        let parent: PhotoPicker<DataModel>
        
        /// Called when one or more items have been picked, or when the picker has been canceled.
        func picker(_: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            // Dismisss the presented picker.
            parent.dismiss()
            
            guard
                let result = results.first,
                result.itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier)
            else { return }
            
            
            result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
                if let error = error {
                    print("Error loading file representation: \(error.localizedDescription)")
                } else if let url = url {
                    if let imageData = try? Data(contentsOf: url){
                        Task { @MainActor [dataModel = self.parent.dataModel] in
                            await dataModel.postImage(image: imageData, type: ImageType.from(url: url), url: url)
                            
                            
                        }
                    }
                }
                
            }
        }
        
        init(_ parent: PhotoPicker<DataModel>) {
            self.parent = parent
        }
    }
}
