extension String {

  func parseWhile<S: Sequence>(oneOf chars: S, at pos: inout String.Index) -> String
    where S.Element == Character
  {
    var result = ""
    while pos < self.endIndex {
      let c = self[pos]
      if !chars.contains(c) {break}
      result.append(c)
      pos = self.index(pos, offsetBy: 1)
    }
    return result
  }

  func parseWhile(oneOf chars: ClosedRange<Character>, at pos: inout String.Index) -> String {
    var result = ""
    while pos < self.endIndex {
      let c = self[pos]
      if !chars.contains(c) {break}
      result.append(c)
      pos = self.index(pos, offsetBy: 1)
    }
    return result
  }

  func skipWhitespace(at pos: inout String.Index) {
    _ = self.parseWhile(oneOf: [" ", "\t", "\n"], at: &pos)
  }

  func trySkip(_ s: String, at pos: inout String.Index) -> Bool {
    if self.distance(from: pos, to: self.endIndex) >= s.count &&
       self[pos ..< self.index(pos, offsetBy: s.count)] == s
    {
      pos = self.index(pos, offsetBy: s.count)
      return true
    }
    return false
  }

  func parseInt(at pos: inout String.Index) -> Int? {
    Int(self.parseWhile(oneOf: "0"..."9", at: &pos))
  }

}