enum BinOp: CustomStringConvertible, CaseIterable {
  case and, or

  var description: String {
    switch self {
    case .and: "&"
    case .or: "|"
    }
  }

  var precedence: Int {
    switch self {
    case .and: 2
    case .or: 1
    }
  }

  func compute(_ lhs: Bool, _ rhs: Bool) -> Bool {
    switch self {
    case .and: lhs && rhs
    case .or: lhs || rhs
    }
  }
}

indirect enum Expr: CustomStringConvertible {
  case variable(String)
  case value(Bool)
  case not(Expr)
  case binExpr(op: BinOp, lhs: Expr, rhs: Expr)

  enum SyntaxError: Error {
    case unexpectedNumber(Int)
    case unexpectedCharacter(Character)
    case unexpectedEOF
  }

  init(_ code: String) throws {
    var pos = code.startIndex

    func unexpectedCharacterError() -> SyntaxError {
      if pos == code.endIndex {
        SyntaxError.unexpectedEOF
      } else {
        SyntaxError.unexpectedCharacter(code[pos])
      }
    }

    func parseUnary() throws -> Expr {
      if let n = code.parseInt(at: &pos) {
        let b =
          switch n {
          case 0: false
          case 1: true
          default: throw SyntaxError.unexpectedNumber(n)
          }
        return Expr.value(b)
      }
      else if code.trySkip("(", at: &pos) {
        return (try parseBinary()).0
      }
      else if code.trySkip("!", at: &pos) {
        return .not(try parseUnary())
      }
      else {
        let name = code.parseWhile(oneOf: "a"..."z", at: &pos)
        if name.isEmpty {
          throw unexpectedCharacterError()
        }
        return .variable(name)
      }
    }

    func parseBinary() throws -> (Expr, inParens: Bool) {
      code.skipWhitespace(at: &pos)
      let expr = try parseUnary()
      code.skipWhitespace(at: &pos)
      if pos == code.endIndex || code.trySkip(")", at: &pos) {
        return (expr, true)
      }
      for op in BinOp.allCases {
        if code.trySkip(op.description, at: &pos) {
          let (rhs, inParens) = try parseBinary()
          let expr: Expr = switch rhs {
            case let .binExpr(op: rhsOp, lhs: rhsLhs, rhs: rhsRhs)
              where rhsOp.precedence < op.precedence && !inParens:
                .binExpr(op: rhsOp, lhs: .binExpr(op: op, lhs: expr, rhs: rhsLhs), rhs: rhsRhs)
            default:
              .binExpr(op: op, lhs: expr, rhs: rhs)
          }
          return (expr, false) 
        }
      }
      throw unexpectedCharacterError()
    }
    
    let (expr, _) = try parseBinary()
    self = expr
  }

  var description: String {
    switch self {
    case let .variable(name): name
    case let .value(v): switch v {
        case true: "1"
        case false: "0"
      }
    case let .not(inner): "!" + inner.description
    case let .binExpr(op, lhs, rhs):
      "(\(lhs) \(op) \(rhs))"
    }
  }

  var vars: [String] {
    switch self {
    case let .variable(name): [name]
    case .value: []
    case let .not(inner): inner.vars
    case let .binExpr(_, lhs, rhs): lhs.vars + rhs.vars
    }
  }

  func compute(_ vals: [String: Bool]) -> Bool {
    switch self {
    case let .variable(name): vals[name]!
    case let .value(v): v
    case let .not(inner): inner.compute(vals)
    case let .binExpr(op, lhs, rhs):
      op.compute(
        lhs.compute(vals),
        rhs.compute(vals)
      )
    }
  }
}