import SwiftUI

@Observable
class AIChatVM {
    var messages: [ChatMessage] = [
        ChatMessage(content: "Hello! I'm N1 Neural Engine running llama-3.2. How can I help you today?", isUser: false)
    ]
    var input: String = ""
    var selectedModel: String = "llama-3.2"
    var isTyping: Bool = false
    var models = ["llama-3.2", "codellama-7b", "mistral-7b", "phi-3"]

    func sendMessage() {
        let text = input.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }

        messages.append(ChatMessage(content: text, isUser: true))
        input = ""
        isTyping = true

        // Simulate response delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self else { return }
            self.isTyping = false
            let response = self.generateResponse(for: text)
            self.messages.append(response)
        }
    }

    private func generateResponse(for input: String) -> ChatMessage {
        let lower = input.lowercased()

        if lower.contains("hello") || lower.contains("hi") || lower.contains("hey") {
            return ChatMessage(content: "Hello! I'm running on PinePhone's Allwinner A64. What would you like to explore?", isUser: false)
        }
        if lower.contains("python") || lower.contains("code") {
            return ChatMessage(
                content: "Here's a Python example:",
                isUser: false,
                hasCodeBlock: true,
                codeContent: "def fibonacci(n):\n    a, b = 0, 1\n    for _ in range(n):\n        a, b = b, a + b\n    return a\n\nprint(fibonacci(10))",
                codeLanguage: "python"
            )
        }
        if lower.contains("weather") {
            return ChatMessage(content: "I don't have real-time weather data, but the PinePhone has GPS and network access for weather APIs. You could use: curl wttr.in", isUser: false)
        }
        if lower.contains("neural") || lower.contains("ai") || lower.contains("model") {
            return ChatMessage(content: "N1 Neural Engine supports multiple models:\n• llama-3.2 (3B) - General purpose\n• codellama-7b - Code generation\n• mistral-7b - Reasoning\n• phi-3 - Efficient inference\n\nAll run locally via Ollama on the A64 SoC.", isUser: false)
        }
        if lower.contains("linux") || lower.contains("kernel") {
            return ChatMessage(content: "N1OS runs a custom Linux kernel 6.1.0-n1 optimized for the Allwinner A64 SoC. It includes Mali GPU drivers, power management, and modem support for the Quectel EG25-G.", isUser: false)
        }
        if lower.contains("hardware") || lower.contains("specs") || lower.contains("pinephone") {
            return ChatMessage(content: "PinePhone Specs:\n• SoC: Allwinner A64 (4x Cortex-A53)\n• RAM: 3GB LPDDR3\n• Storage: 32GB eMMC\n• Display: 5.95\" 1440x720 IPS\n• Battery: 3000mAh\n• Modem: Quectel EG25-G", isUser: false)
        }
        if lower.contains("help") {
            return ChatMessage(content: "I can help with:\n• Programming questions\n• Linux/system info\n• Hardware specs\n• AI/ML concepts\n• General knowledge\n\nJust ask me anything!", isUser: false)
        }
        if lower.contains("rust") {
            return ChatMessage(
                content: "Here's a Rust example:",
                isUser: false,
                hasCodeBlock: true,
                codeContent: "fn main() {\n    let nums: Vec<i32> = (1..=10)\n        .filter(|x| x % 2 == 0)\n        .collect();\n    println!(\"{:?}\", nums);\n}",
                codeLanguage: "rust"
            )
        }
        if lower.contains("swift") {
            return ChatMessage(
                content: "Here's a Swift example:",
                isUser: false,
                hasCodeBlock: true,
                codeContent: "struct Point {\n    let x: Double\n    let y: Double\n    \n    func distance(to other: Point) -> Double {\n        let dx = x - other.x\n        let dy = y - other.y\n        return (dx*dx + dy*dy).squareRoot()\n    }\n}",
                codeLanguage: "swift"
            )
        }
        if lower.contains("network") || lower.contains("wifi") {
            return ChatMessage(content: "Network status:\n• WiFi: Connected (192.168.1.42)\n• Signal: -42 dBm (Excellent)\n• Modem: Quectel EG25-G (standby)\n• Bluetooth: Active, 0 paired", isUser: false)
        }
        if lower.contains("battery") || lower.contains("power") {
            return ChatMessage(content: "Battery: 84% (3000mAh Li-ion)\nEstimated: 4h 32m remaining\nCharging: Not connected\nHealth: 94% capacity", isUser: false)
        }
        if lower.contains("math") || lower.contains("calculate") {
            return ChatMessage(
                content: "Here's a calculation example:",
                isUser: false,
                hasCodeBlock: true,
                codeContent: "import math\n\n# Quadratic formula\na, b, c = 1, -5, 6\ndisc = b**2 - 4*a*c\nx1 = (-b + math.sqrt(disc)) / (2*a)\nx2 = (-b - math.sqrt(disc)) / (2*a)\nprint(f\"x = {x1}, {x2}\")",
                codeLanguage: "python"
            )
        }

        return ChatMessage(content: "That's an interesting question. On N1OS, I run locally on the PinePhone's ARM processor. While I have limited compute compared to cloud models, I can help with many tasks offline. Could you be more specific about what you need?", isUser: false)
    }

    var tokenInfo: String {
        let tokens = messages.reduce(0) { $0 + $1.content.split(separator: " ").count * 2 }
        return "\(tokens) tokens · \(selectedModel)"
    }
}
