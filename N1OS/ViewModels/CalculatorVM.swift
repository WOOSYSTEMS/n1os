import SwiftUI

@Observable
class CalculatorVM {
    var display: String = "0"
    var history: [String] = []
    var showHistory: Bool = false

    private var currentValue: Double = 0
    private var pendingOperation: String? = nil
    private var pendingValue: Double = 0
    private var isNewInput: Bool = true

    func tap(_ button: String) {
        switch button {
        case "0"..."9":
            if isNewInput {
                display = button
                isNewInput = false
            } else {
                display = display == "0" ? button : display + button
            }
        case ".":
            if isNewInput {
                display = "0."
                isNewInput = false
            } else if !display.contains(".") {
                display += "."
            }
        case "+", "-", "×", "÷":
            currentValue = Double(display) ?? 0
            pendingOperation = button
            pendingValue = currentValue
            isNewInput = true
        case "=":
            let second = Double(display) ?? 0
            let result = calculate(pendingValue, second, pendingOperation)
            let expr = "\(formatNumber(pendingValue)) \(pendingOperation ?? "") \(formatNumber(second)) = \(formatNumber(result))"
            history.insert(expr, at: 0)
            if history.count > 10 { history.removeLast() }
            display = formatNumber(result)
            pendingOperation = nil
            isNewInput = true
        case "C":
            display = "0"
            currentValue = 0
            pendingOperation = nil
            pendingValue = 0
            isNewInput = true
        case "±":
            if let val = Double(display) {
                display = formatNumber(-val)
            }
        case "%":
            if let val = Double(display) {
                display = formatNumber(val / 100)
            }
        default:
            break
        }
    }

    private func calculate(_ a: Double, _ b: Double, _ op: String?) -> Double {
        switch op {
        case "+": return a + b
        case "-": return a - b
        case "×": return a * b
        case "÷": return b != 0 ? a / b : 0
        default: return b
        }
    }

    private func formatNumber(_ n: Double) -> String {
        if n == n.rounded() && abs(n) < 1e15 {
            return String(format: "%.0f", n)
        }
        return String(format: "%.6g", n)
    }

    static let buttons: [[String]] = [
        ["C", "±", "%", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "+"],
        ["0", ".", "="],
    ]

    func buttonColor(_ btn: String) -> Color {
        switch btn {
        case "C", "±", "%": return Theme.textSecondary
        case "+", "-", "×", "÷", "=": return Theme.accent
        default: return Theme.textPrimary
        }
    }

    func buttonBg(_ btn: String) -> Color {
        switch btn {
        case "C", "±", "%": return Theme.bgTertiary
        case "+", "-", "×", "÷", "=": return Theme.accent.opacity(0.2)
        default: return Theme.bgSecondary
        }
    }
}
