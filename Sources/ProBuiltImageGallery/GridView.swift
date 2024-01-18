//
//  SwiftUIView.swift
//  
//
//  Created by Colton Hillebrand on 1/18/24.
//

import Foundation
import PhotosUI
import SwiftUI


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
    func deleteImage(id: Int) async
    func refresh() async
    func removeItem(_ item: Item)
}
struct GridView<DataModel: GridViewDataModel>: View  {

    @EnvironmentObject
    var dataModel: DataModel
    
    
    @State
    private var isAddingPhoto = false
    @State
    private var isEditing = false
    
    @State
    private var gridColumns = Array(repeating: GridItem(.flexible()), count: 3)
    @State
    private var numColumns = 3
    
    private var columnsTitle: String {
        gridColumns.count > 1 ? "\(gridColumns.count) Columns" : "1 Column"
    }
    
    
    
    var body: some View {
        VStack {
            if isEditing {
                ColumnStepper(title: columnsTitle, range: 1 ... 8, columns: $gridColumns)
                    .padding()
            }
            ScrollView {
     
                    LazyVGrid(columns: gridColumns) {
                        ForEach(dataModel.items) { item in
                            GeometryReader { geo in
                                NavigationLink(destination: DetailView<DataModel>(id: item.IDNo ?? 0).environmentObject(dataModel)) {
                                    GridItemView(size: geo.size.width, url: URL(string: item.Url ?? "")!, loadingView: ProgressView())
                                }
                            }
                            .cornerRadius(8.0)
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(alignment: .topTrailing) {
                                if isEditing {
                                    Button {
                                        withAnimation {
                                            dataModel.removeItem(item)
                                        }
                                    } label: {
                                        Image(systemName: "xmark.square.fill")
                                            .font(Font.title)
                                            .symbolRenderingMode(.palette)
                                            .foregroundStyle(.white, .red)
                                    }
                                    .offset(x: 7, y: -7)
                                }
                            }
                        }
                    }
                    .padding()
                
            }
            
        }
        .refreshable {
            await dataModel.refresh()
        }
        .navigationBarTitle("Image Gallery")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isAddingPhoto) {
           // PhotoPicker()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(isEditing ? "Done" : "Edit") {
                    withAnimation { isEditing.toggle() }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isAddingPhoto = true
                } label: {
                    Image(systemName: "plus")
                }
                .disabled(isEditing)
            }
        }
        
    }
}
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
    func makeCoordinator() -> Coordinator<DataModel> {
        Coordinator(self)
    }
    
        /// Updates the picker while it’s being presented.
    func updateUIViewController(_: PHPickerViewController, context _: UIViewControllerRepresentableContext<PhotoPicker>) {
            // No updates are necessary.
    }
}

class Coordinator<DataModel: GridViewDataModel>: NSObject, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
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
                        await dataModel.postImage(image: imageData)
                    }
                    
                }
            }
            
        }
    }
    
    init(_ parent: PhotoPicker<DataModel>) {
        self.parent = parent
    }
}


class MyDataModel: GridViewDataModel, ObservableObject {
    
    
    
    
        // Assuming MyItem conforms to GridViewItem
    typealias Item = MyItem
    @Published var ids:[Int] = []
    @Published var items: [MyItem] = []
    @Published var didFetch:Bool = false
    func fetchOriginal(id: Int) async -> URL? {
        return URL(string: "https://picsum.photos/200/300")
    }
    func fetchThumbnails() async {
        guard !didFetch else {return}
        self.items.removeAll()
            // Creating dummy data
        for i in ids {
            let randomNumber = Int.random(in: 200...300)
            let newItem = MyItem(IDNo: i, fileUrl: "https://picsum.photos/200/\(randomNumber)")
            Task{ @MainActor [items = newItem] in
                self.items.append(items)
                self.didFetch = true
            }
            
        }
    }
    func postImage(image: Data) async {
        
    }
    
    func deleteImage(id: Int) async {
        
    }
    func refresh() async{
        didFetch = false
        await fetchThumbnails()
    }
    func removeItem(_ item: MyItem) {
            // Implement the logic to remove an item from `items`
        if let index = items.firstIndex(where: { $0.IDNo == item.IDNo }) {
            items.remove(at: index)
        }
    }
}
extension MyItem: GridViewItem {
    var Url: String? {
        self.fileUrl
    }
    
        // Implement the GridViewItem protocol
}

struct MyItem: Identifiable {
    var id = UUID()
    var IDNo: Int?
    var fileUrl: String?
}

struct DemoView: View {
    @StateObject var model = MyDataModel()
    var body: some View {
        NavigationStack {
            GridView<MyDataModel>().environmentObject(model)
                .task{
                    model.ids = [1,2]
                    await model.fetchThumbnails()
                }
        }
    }
}

#Preview {
    DemoView()
}
