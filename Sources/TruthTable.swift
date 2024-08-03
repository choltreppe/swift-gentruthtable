struct TruthTable: CustomStringConvertible {
  private var vars: [String]
  private var results: [Bool]
  private var resultTitle: String

  init(_ expr: Expr) {
    self.resultTitle = expr.description
    self.vars = Array(expr.vars).sorted()
    var vals: [String: Bool] = [:]
    self.results = []
    func computeResults(_ pos: Int = 0) {
      if pos < self.vars.count {
        for val in [false, true] {
          vals[vars[pos]] = val
          computeResults(pos + 1)
        }
      }
      else {
        self.results.append(expr.compute(vals))
      }
    }
    computeResults()
  }

  var description: String {
    var tableStr = ""

    func addCell(content: String, isFirst: Bool = false) -> Int {  //returns width
      tableStr += isFirst ? "" : "|"
      tableStr += " \(content) "
      return content.count
    }

    var columnWidths = [Int]()
    for (i, name) in vars.enumerated() {
      columnWidths.append(addCell(content: name, isFirst: i == 0))
    }
    columnWidths.append(addCell(content: resultTitle))
    let rowSep = String(
      repeating: "-",
      count: columnWidths.reduce(0, +) + columnWidths.count*3 - 1
    )

    for (row, result) in self.results.enumerated() {
      tableStr += "\n" + rowSep + "\n"
      for i in 0 ..< self.vars.count {
        _ = addCell(
          content:
            (row&(1<<(self.vars.count-i-1)) == 0 ? "0" : "1") +
            String(repeating: " ", count: columnWidths[i] - 1),
          isFirst:
            i == 0
        )
      }
      _ = addCell(content: result ? "1": "0")
    }

    return tableStr
  }
}