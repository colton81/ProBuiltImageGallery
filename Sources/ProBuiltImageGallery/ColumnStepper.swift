//
//  SwiftUIView.swift
//  
//
//  Created by Colton Hillebrand on 1/18/24.
//

import SwiftUI

struct ColumnStepper: View {
    let title: String
    let range: ClosedRange<Int>
    @Binding
    var columns: [GridItem]
    @State
    private var numColumns: Int
    
    init(title: String, range: ClosedRange<Int>, columns: Binding<[GridItem]>) {
        self.title = title
        self.range = range
        _columns = columns
        numColumns = columns.count
    }
    
    var body: some View {
        Stepper(title, value: $numColumns, in: range, step: 1) { _ in
            withAnimation { columns = Array(repeating: GridItem(.flexible()), count: numColumns) }
        }
    }
}

#Preview {
    ColumnStepper(
        title: "ColumnStepper",
        range: 1 ... 8,
        columns: .constant(Array(repeating: GridItem(.flexible()), count: 5))
    )
}
