import SwiftUI

struct TerminalLine: Identifiable {
    let id = UUID()
    let text: String
    let color: Color
    let isPrompt: Bool

    init(_ text: String, color: Color = Theme.textPrimary, isPrompt: Bool = false) {
        self.text = text
        self.color = color
        self.isPrompt = isPrompt
    }
}

@Observable
class TerminalVM {
    var lines: [TerminalLine] = [
        TerminalLine("N1OS Terminal v2.1.0", color: Theme.accent),
        TerminalLine("Type 'help' for available commands", color: Theme.textSecondary),
    ]
    var input: String = ""
    var commandHistory: [String] = []
    var currentTab: String = "shell" // shell or python
    var currentDir: String = "~"

    func executeCommand() {
        let cmd = input.trimmingCharacters(in: .whitespaces)
        guard !cmd.isEmpty else { return }

        commandHistory.append(cmd)
        lines.append(TerminalLine("\(promptPrefix)\(cmd)", color: Theme.success, isPrompt: true))
        input = ""

        if currentTab == "python" {
            executePython(cmd)
        } else {
            executeShell(cmd)
        }
    }

    var promptPrefix: String {
        currentTab == "python" ? ">>> " : "n1@pinephone:\(currentDir)$ "
    }

    private func executeShell(_ cmd: String) {
        let parts = cmd.split(separator: " ", maxSplits: 1).map(String.init)
        let command = parts[0].lowercased()
        let arg = parts.count > 1 ? parts[1] : ""

        switch command {
        case "help":
            addLines([
                ("Available commands:", Theme.accent),
                ("  help     - Show this help", Theme.textSecondary),
                ("  ls       - List directory", Theme.textSecondary),
                ("  cd       - Change directory", Theme.textSecondary),
                ("  pwd      - Print working directory", Theme.textSecondary),
                ("  clear    - Clear terminal", Theme.textSecondary),
                ("  neofetch - System info", Theme.textSecondary),
                ("  htop     - Process viewer", Theme.textSecondary),
                ("  whoami   - Current user", Theme.textSecondary),
                ("  date     - Current date/time", Theme.textSecondary),
                ("  uname    - System name", Theme.textSecondary),
                ("  cat      - Read file", Theme.textSecondary),
                ("  echo     - Print text", Theme.textSecondary),
                ("  free     - Memory usage", Theme.textSecondary),
                ("  df       - Disk usage", Theme.textSecondary),
                ("  ip       - Network info", Theme.textSecondary),
                ("  uptime   - System uptime", Theme.textSecondary),
                ("  systemctl - Service status", Theme.textSecondary),
                ("  ollama   - AI model info", Theme.textSecondary),
            ])
        case "ls":
            addLines([
                ("Documents/  Downloads/  Pictures/  Music/", Theme.accent),
                (".config/    .local/     neural_net.py", Theme.textPrimary),
                ("README.md   setup.sh    data.csv", Theme.textPrimary),
            ])
        case "cd":
            if arg.isEmpty || arg == "~" {
                currentDir = "~"
            } else if arg == ".." {
                currentDir = "~"
            } else {
                currentDir = "~/\(arg)"
            }
        case "pwd":
            addLine("/home/n1user\(currentDir == "~" ? "" : currentDir.replacingOccurrences(of: "~", with: ""))", Theme.textPrimary)
        case "clear":
            lines.removeAll()
        case "neofetch":
            addLines([
                ("       ▄▄▄▄▄▄▄       n1@pinephone", Theme.accent),
                ("     ▄▀       ▀▄     ──────────────", Theme.accent),
                ("    █  N  1  O  S █    OS: N1OS 2.1.0 aarch64", Theme.success),
                ("    █           █    Host: PinePhone", Theme.textPrimary),
                ("     ▀▄       ▄▀     Kernel: 6.1.0-n1", Theme.textPrimary),
                ("       ▀▀▀▀▀▀▀       Shell: n1sh 1.0", Theme.textPrimary),
                ("                      CPU: Allwinner A64 (4) @ 1.15GHz", Theme.textSecondary),
                ("                      RAM: 1.8G / 3.0G", Theme.textSecondary),
                ("                      GPU: Mali-400 MP2", Theme.textSecondary),
            ])
        case "htop":
            addLines([
                ("  PID USER    %CPU %MEM COMMAND", Theme.accent),
                ("  1   root     0.0  0.1 systemd", Theme.textPrimary),
                (" 142  n1user  12.3  8.2 ollama serve", Theme.success),
                (" 287  n1user   5.7  4.1 n1-desktop", Theme.textPrimary),
                (" 312  n1user   2.1  1.8 terminal", Theme.textPrimary),
                (" 445  n1user   0.8  2.4 browser", Theme.textSecondary),
                ("CPU: ████████░░░░░░░░ 34% | RAM: ██████████░░░░░░ 62%", Theme.warning),
            ])
        case "whoami":
            addLine("n1user", Theme.textPrimary)
        case "date":
            let f = DateFormatter()
            f.dateFormat = "EEE MMM dd HH:mm:ss yyyy"
            addLine(f.string(from: Date()), Theme.textPrimary)
        case "uname":
            addLine("N1OS 2.1.0 aarch64 PinePhone GNU/Linux", Theme.textPrimary)
        case "cat":
            if arg.isEmpty {
                addLine("cat: missing operand", Theme.danger)
            } else if arg.contains("neural_net") {
                addLines([
                    ("import torch", Theme.accent),
                    ("import torch.nn as nn", Theme.accent),
                    ("", Theme.textPrimary),
                    ("class NeuralNet(nn.Module):", Theme.success),
                    ("    def __init__(self):", Theme.textPrimary),
                    ("        super().__init__()", Theme.textPrimary),
                    ("        self.fc1 = nn.Linear(784, 128)", Theme.textPrimary),
                ])
            } else {
                addLine("cat: \(arg): No such file or directory", Theme.danger)
            }
        case "echo":
            addLine(arg, Theme.textPrimary)
        case "free":
            addLines([
                ("              total   used   free   available", Theme.accent),
                ("Mem:          3.0G   1.8G   0.8G   1.2G", Theme.textPrimary),
                ("Swap:         2.0G   0.2G   1.8G", Theme.textSecondary),
            ])
        case "df":
            addLines([
                ("Filesystem  Size  Used  Avail  Use%  Mount", Theme.accent),
                ("/dev/mmcblk0 32G   18G    14G   56%  /", Theme.textPrimary),
                ("tmpfs        1.5G  12M   1.5G    1%  /tmp", Theme.textSecondary),
            ])
        case "ip":
            addLines([
                ("wlan0: inet 192.168.1.42/24", Theme.textPrimary),
                ("        ether a4:cf:12:b8:7e:01", Theme.textSecondary),
            ])
        case "uptime":
            addLine(" 14:32:07 up 3 days, 7:42, 1 user, load: 0.34, 0.28, 0.21", Theme.textPrimary)
        case "systemctl":
            addLines([
                ("● ollama.service - Ollama LLM Server", Theme.success),
                ("   Active: active (running) since Mon", Theme.success),
                ("● n1-desktop.service - N1OS Desktop", Theme.success),
                ("   Active: active (running) since Mon", Theme.success),
                ("● bluetooth.service - Bluetooth", Theme.accent),
                ("   Active: active (running)", Theme.accent),
            ])
        case "ollama":
            addLines([
                ("NAME              SIZE    MODIFIED", Theme.accent),
                ("llama3.2:3b       2.0 GB  2 days ago", Theme.textPrimary),
                ("codellama:7b      3.8 GB  5 days ago", Theme.textPrimary),
                ("mistral:7b        4.1 GB  1 week ago", Theme.textSecondary),
            ])
        default:
            addLine("n1sh: \(command): command not found", Theme.danger)
        }
    }

    private func executePython(_ cmd: String) {
        if cmd.hasPrefix("print(") {
            let inner = cmd.dropFirst(6).dropLast()
            addLine(String(inner).replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "'", with: ""), Theme.textPrimary)
        } else if cmd.contains("+") || cmd.contains("-") || cmd.contains("*") || cmd.contains("/") {
            // Simple eval
            let cleaned = cmd.replacingOccurrences(of: " ", with: "")
            if let result = simpleEval(cleaned) {
                addLine(result, Theme.textPrimary)
            } else {
                addLine(cmd, Theme.textPrimary)
            }
        } else if cmd == "import this" {
            addLine("The Zen of Python: Beautiful is better than ugly.", Theme.accent)
        } else if cmd.hasPrefix("import") {
            // silently accept imports
        } else if cmd == "help()" {
            addLine("Type Python expressions or print() statements", Theme.textSecondary)
        } else if cmd == "exit()" {
            currentTab = "shell"
            addLine("Exiting Python REPL", Theme.textSecondary)
        } else {
            addLine(cmd, Theme.textPrimary)
        }
    }

    private func simpleEval(_ expr: String) -> String? {
        let expression = NSExpression(format: expr)
        if let result = expression.expressionValue(with: nil, context: nil) as? NSNumber {
            return "\(result)"
        }
        return nil
    }

    private func addLine(_ text: String, _ color: Color) {
        lines.append(TerminalLine(text, color: color))
    }

    private func addLines(_ items: [(String, Color)]) {
        for (text, color) in items {
            lines.append(TerminalLine(text, color: color))
        }
    }
}
