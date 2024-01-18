//
//  SwiftUIView.swift
//  
//
//  Created by Colton Hillebrand on 1/18/24.
//

import Foundation
import PhotosUI
import SwiftUI



public struct GridView<DataModel: GridViewDataModel>: View  {
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
    
    public init(){
        
    }
    
    public var body: some View {
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
                                         
                                                dataModel.deleteImage(item)
                                            
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
            PhotoPicker<DataModel>()
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






class MyDataModel: GridViewDataModel, ObservableObject {
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
    
    func deleteImage(_ item: MyItem) {
        Task { @MainActor [items = self.items] in
            if let index = items.firstIndex(where: { $0.IDNo == item.IDNo }) {
                self.items.remove(at: index)
            }
        }
    }
    
    func refresh() async{
        didFetch = false
        await fetchThumbnails()
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
