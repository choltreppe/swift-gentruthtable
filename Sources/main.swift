import Foundation

let args = CommandLine.arguments
if args.count == 2 {
  do {
    print(TruthTable(try Expr(args[1])))
  } catch {
    print("Error: \(error)")
  }
} else {
  print("expected 'gentt <EXPR>")
}