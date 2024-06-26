import SwiftUI

struct TableView: View {
  @Environment(\.theme.table) private var table
  @Environment(\.tableBorderStyle.strokeStyle.lineWidth) private var borderWidth
    
    @State
        private var scrollViewContentSize: CGSize = .zero

  private let columnAlignments: [RawTableColumnAlignment]
  private let rows: [RawTableRow]

  init(columnAlignments: [RawTableColumnAlignment], rows: [RawTableRow]) {
    self.columnAlignments = columnAlignments
    self.rows = rows
  }

  var body: some View {
    self.table.makeBody(
      configuration: .init(
        label: .init(self.label),
        content: .init(block: .table(columnAlignments: self.columnAlignments, rows: self.rows))
      )
    )
  }

  private var label: some View {
      
      ScrollView(.horizontal) {
          VStack(alignment: .leading, spacing: self.borderWidth) {
              ForEach(0..<self.rowCount, id: \.self) { row in
                  HStack(spacing: self.borderWidth) {
                      ForEach(0..<self.columnCount, id: \.self) { column in
                          TableCell(row: row, column: column, cell: self.rows[row].cells[column])
                              .frame(width: 140, alignment: .leading)
                      }
                  }
              }
          }
          .frame(maxHeight: .infinity)
          .tableDecoration(
            rowCount: self.rowCount,
            columnCount: self.columnCount,
            background: TableBackgroundView.init,
            overlay: TableBorderView.init
          )
      }
    
//      Grid(horizontalSpacing: self.borderWidth, verticalSpacing: self.borderWidth) {
//          ForEach(0..<self.rowCount, id: \.self) { row in
//              GridRow {
//                  ForEach(0..<self.columnCount, id: \.self) { column in
//                      TableCell(row: row, column: column, cell: self.rows[row].cells[column])
//                          .gridColumnAlignment(.init(self.columnAlignments[column]))
//                  }
//              }
//          }
//      }
//      .padding(self.borderWidth)
//      .tableDecoration(
//        rowCount: self.rowCount,
//        columnCount: self.columnCount,
//        background: TableBackgroundView.init,
//        overlay: TableBorderView.init
//      )
  }

  private var rowCount: Int {
    self.rows.count
  }

  private var columnCount: Int {
    self.columnAlignments.count
  }
}

extension HorizontalAlignment {
  fileprivate init(_ rawTableColumnAlignment: RawTableColumnAlignment) {
    switch rawTableColumnAlignment {
    case .none, .left:
      self = .leading
    case .center:
      self = .center
    case .right:
      self = .trailing
    }
  }
}
