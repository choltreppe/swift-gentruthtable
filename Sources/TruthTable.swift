struct TruthTable: CustomStringConvertible {
  var vars: [String]
  var results: [Bool]
  var resultTitle: String

  init(_ expr: Expr) {
    resultTitle = expr.description
    vars = expr.vars
    var vals: [String: Bool] = [:]
    results = []
    func computeResults(_ pos: Int) {
      if pos < vars.count {
        for val in [true, false] {
          vals[vars[pos]] = val
          computeResults(pos + 1)
        }
      }
      else {
        results.append(expr.compute(vals))
      }
    }
    computeResults(0)
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

    for (row, result) in results.enumerated() {
      tableStr += "\n" + rowSep + "\n"
      for i in 0 ..< vars.count {
        _ = addCell(
          content:
            (row&(1<<(vars.count-i-1)) == 0 ? "1" : "0") +
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