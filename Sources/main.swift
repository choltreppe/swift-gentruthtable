import Foundation

let args = CommandLine.arguments
if args.count == 2 {
  print(args)
  print(TruthTable(try Expr(args[1])))
} else {
  print("expected 'getTruthTable <EXPR>")
}