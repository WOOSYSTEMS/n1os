import SwiftUI

struct VSCodeWindow: View {
    @State private var selectedFile = "main.py"
    @State private var selectedTab = "main.py"

    private let fileTree: [(String, String, Int)] = [
        ("src/", "folder.fill", 0),
        ("  main.py", "chevron.left.forwardslash.chevron.right", 1),
        ("  utils.py", "chevron.left.forwardslash.chevron.right", 1),
        ("  config.py", "chevron.left.forwardslash.chevron.right", 1),
        ("tests/", "folder.fill", 0),
        ("  test_main.py", "chevron.left.forwardslash.chevron.right", 1),
        ("README.md", "doc.text", 0),
        (".gitignore", "doc", 0),
    ]

    private let codeFiles: [String: [(String, Color)]] = [
        "main.py": [
            ("import torch", Theme.purple),
            ("import torch.nn as nn", Theme.purple),
            ("from utils import preprocess", Theme.purple),
            ("", Theme.textPrimary),
            ("class NeuralNet(nn.Module):", Theme.accent),
            ("    \"\"\"N1 Neural Network\"\"\"", Theme.success),
            ("    def __init__(self, input_size=784):", Theme.accent),
            ("        super().__init__()", Theme.textPrimary),
            ("        self.fc1 = nn.Linear(input_size, 256)", Theme.textPrimary),
            ("        self.fc2 = nn.Linear(256, 128)", Theme.textPrimary),
            ("        self.fc3 = nn.Linear(128, 10)", Theme.textPrimary),
            ("        self.relu = nn.ReLU()", Theme.textPrimary),
            ("        self.dropout = nn.Dropout(0.2)", Theme.textPrimary),
            ("", Theme.textPrimary),
            ("    def forward(self, x):", Theme.accent),
            ("        x = self.relu(self.fc1(x))", Theme.textPrimary),
            ("        x = self.dropout(x)", Theme.textPrimary),
            ("        x = self.relu(self.fc2(x))", Theme.textPrimary),
            ("        return self.fc3(x)", Theme.warning),
            ("", Theme.textPrimary),
            ("if __name__ == \"__main__\":", Theme.purple),
            ("    model = NeuralNet()", Theme.textPrimary),
            ("    print(f\"Params: {sum(p.numel() for p in model.parameters())}\")", Theme.textPrimary),
        ],
        "utils.py": [
            ("import numpy as np", Theme.purple),
            ("from typing import List, Tuple", Theme.purple),
            ("", Theme.textPrimary),
            ("def preprocess(data: np.ndarray) -> np.ndarray:", Theme.accent),
            ("    \"\"\"Normalize and reshape input data.\"\"\"", Theme.success),
            ("    data = data.astype(np.float32) / 255.0", Theme.textPrimary),
            ("    return data.reshape(-1, 784)", Theme.textPrimary),
        ],
    ]

    var body: some View {
        HStack(spacing: 0) {
            // File tree
            VStack(alignment: .leading, spacing: 1) {
                Text("EXPLORER")
                    .font(.system(size: Theme.fontMicro, weight: .bold, design: .monospaced))
                    .foregroundStyle(Theme.textMuted)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 3)

                ScrollView {
                    VStack(alignment: .leading, spacing: 1) {
                        ForEach(Array(fileTree.enumerated()), id: \.offset) { _, item in
                            let name = item.0.trimmingCharacters(in: .whitespaces)
                            Button {
                                if !item.0.hasSuffix("/") {
                                    selectedFile = name
                                    selectedTab = name
                                }
                            } label: {
                                HStack(spacing: 3) {
                                    if item.2 > 0 {
                                        Spacer().frame(width: CGFloat(item.2) * 8)
                                    }
                                    Image(systemName: item.1)
                                        .font(.system(size: 7))
                                        .foregroundStyle(item.0.hasSuffix("/") ? Theme.warning : Theme.accent)
                                        .frame(width: 10)
                                    Text(name)
                                        .font(.system(size: Theme.fontMicro, design: .monospaced))
                                        .foregroundStyle(selectedFile == name ? Theme.textPrimary : Theme.textSecondary)
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 2)
                                .padding(.horizontal, 2)
                                .background(selectedFile == name ? Theme.accent.opacity(0.1) : Color.clear)
                            }
                        }
                    }
                }
            }
            .frame(width: 80)
            .background(Theme.bgSecondary)

            Rectangle().fill(Theme.border).frame(width: 0.5)

            // Editor area
            VStack(spacing: 0) {
                // Tab bar
                HStack(spacing: 0) {
                    tabItem(selectedTab)
                    Spacer()
                }
                .background(Theme.bgSecondary)

                // Code view
                HStack(spacing: 0) {
                    // Line numbers + code
                    ScrollView {
                        let lines = codeFiles[selectedFile] ?? [("// Empty file", Theme.textMuted)]
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                                HStack(alignment: .top, spacing: 6) {
                                    Text("\(index + 1)")
                                        .font(.system(size: Theme.fontMicro, design: .monospaced))
                                        .foregroundStyle(Theme.textMuted)
                                        .frame(width: 16, alignment: .trailing)
                                    Text(line.0)
                                        .font(.system(size: Theme.fontSmall, design: .monospaced))
                                        .foregroundStyle(line.1)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(4)
                    }

                    // Minimap
                    VStack(spacing: 0) {
                        let lines = codeFiles[selectedFile] ?? []
                        ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                            Rectangle()
                                .fill(line.1.opacity(0.3))
                                .frame(height: 1.5)
                                .frame(maxWidth: .infinity)
                        }
                        Spacer()
                    }
                    .frame(width: 16)
                    .padding(.vertical, 4)
                    .background(Theme.bgSecondary.opacity(0.5))
                }

                // Status bar
                HStack(spacing: 8) {
                    Text("Python")
                        .font(.system(size: Theme.fontMicro, design: .monospaced))
                        .foregroundStyle(Theme.textMuted)
                    Text("UTF-8")
                        .font(.system(size: Theme.fontMicro, design: .monospaced))
                        .foregroundStyle(Theme.textMuted)
                    Spacer()
                    Text("Ln 1, Col 1")
                        .font(.system(size: Theme.fontMicro, design: .monospaced))
                        .foregroundStyle(Theme.textMuted)
                }
                .padding(.horizontal, 6)
                .frame(height: 16)
                .background(Theme.accent.opacity(0.15))
            }
        }
    }

    func tabItem(_ name: String) -> some View {
        HStack(spacing: 3) {
            Image(systemName: "chevron.left.forwardslash.chevron.right")
                .font(.system(size: 6))
                .foregroundStyle(Theme.accent)
            Text(name)
                .font(.system(size: Theme.fontMicro, design: .monospaced))
                .foregroundStyle(Theme.textPrimary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Theme.bgPrimary)
    }
}
